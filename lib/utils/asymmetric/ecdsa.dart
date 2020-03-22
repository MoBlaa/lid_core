
import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:core/utils/asymmetric/asymmetric_module.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/export.dart';

/// Implements following RFC standards:
class ECDSAModule extends AsymmetricModule {
  @override
  String get algorithm => "ECDSA";

  @override
  AsymmetricKeyPair<PublicKey, PrivateKey> genKeyPair(SecureRandom rnd) {
    final params = ECKeyGeneratorParameters(ECCurve_prime256v1());

    final gen = ECKeyGenerator();
    gen.init(ParametersWithRandom(params, rnd));

    return gen.generateKeyPair();
  }

  @override
  PrivateKey privateKeyFromASN1(Uint8List encoded) {
    final parser = ASN1Parser(encoded);
    final seq = parser.nextObject() as ASN1Sequence;
    final encodedKey = seq.elements[0] as ASN1Integer;
    return ECPrivateKey(encodedKey.valueAsBigInteger, ECCurve_prime256v1());
  }

  @override
  String privateKeyToASN1(PrivateKey private) {
    assert(private is ECPrivateKey);

    final seq = ASN1Sequence();
    seq.add(ASN1Integer((private as ECPrivateKey).d));
    return base64Encode(seq.encodedBytes);
  }

  @override
  PublicKey publicKeyFromASN1(Uint8List encoded) {
    final parser = ASN1Parser(encoded);
    final seq = parser.nextObject() as ASN1Sequence;

    final params = ECCurve_prime256v1();
    final curve = params.curve;
    return ECPublicKey(curve.decodePoint(seq.elements[0].contentBytes()), params);
  }

  @override
  String publicKeyToASN1(PublicKey public) {
    assert(public is ECPublicKey);

    final seq = ASN1Sequence();
    seq.add(ASN1BitString((public as ECPublicKey).Q.getEncoded()));
    return base64Encode(seq.encodedBytes);
  }

}