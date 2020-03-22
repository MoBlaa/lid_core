
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:core/utils/asymmetric/ecdsa.dart';
import 'package:core/utils/asymmetric/rsa.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/export.dart';

abstract class AsymmetricModule {
  static AsymmetricModule fromString(String alg) {
    AsymmetricModule module;
    switch (alg) {
      case "RSA":
        module = RSAModule();
        break;
      case "ECDSA":
        module = ECDSAModule();
        break;
      default:
        throw "Unsupported algorithm: '$alg'";
    }
    return module;
  }

  AsymmetricModule() {
    ASN1ObjectIdentifier.registerFrequentNames();
  }

  AsymmetricKeyPair<PublicKey, PrivateKey> genKeyPair(SecureRandom rnd);
  PublicKey publicKeyFromASN1(Uint8List encoded);
  PrivateKey privateKeyFromASN1(Uint8List encoded);

  String publicKeyToASN1(PublicKey public);
  String privateKeyToASN1(PrivateKey private);

  String get algorithm;
}