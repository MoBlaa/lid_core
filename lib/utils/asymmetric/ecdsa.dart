
import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:core/utils/asymmetric/asymmetric_module.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/export.dart';

/// Implements following RFC standards:
class ECDSAModule extends AsymmetricModule {
  static get params => ECCurve_secp521r1();

  @override
  String get algorithm => "ECDSA";

  @override
  AsymmetricKeyPair<PublicKey, PrivateKey> genKeyPair(SecureRandom rnd) {
    final p = ECKeyGeneratorParameters(params);

    final gen = ECKeyGenerator();
    gen.init(ParametersWithRandom(p, rnd));

    return gen.generateKeyPair();
  }

  @override
  PrivateKey privateKeyFromASN1(Uint8List encoded) {
    final parser = ASN1Parser(encoded);
    final seq = parser.nextObject() as ASN1Sequence;
    final encodedKey = seq.elements[0] as ASN1Integer;
    return ECPrivateKey(encodedKey.valueAsBigInteger, params);
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

    final p = params;
    final curve = p.curve;
    return ECPublicKey(curve.decodePoint(seq.elements[0].contentBytes()), p);
  }

  @override
  String publicKeyToASN1(PublicKey public) {
    assert(public is ECPublicKey);

    final seq = ASN1Sequence();
    seq.add(ASN1BitString((public as ECPublicKey).Q.getEncoded()));
    return base64Encode(seq.encodedBytes);
  }

}