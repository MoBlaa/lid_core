import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:core/utils/asymmetric/asymmetric_module.dart';
import 'package:pointycastle/export.dart';

class RSAModule implements AsymmetricModule {
  @override
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> genKeyPair(SecureRandom rnd) {
    final params = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 12);

    final gen = RSAKeyGenerator();
    gen.init(ParametersWithRandom(params, rnd));

    return gen.generateKeyPair();
  }

  @override
  PrivateKey privateKeyFromASN1(Uint8List encoded) {
    final parser = ASN1Parser(encoded);
    final sequence = parser.nextObject() as ASN1Sequence;
    if (sequence.elements.length != 4) {
      throw "Public Key ASN.1 has to contain 4 values, got: ${sequence.elements.length}";
    }
    final modulus = sequence.elements[0] as ASN1Integer;
    final exponent = sequence.elements[1] as ASN1Integer;
    final p = sequence.elements[2] as ASN1Integer;
    final q = sequence.elements[3] as ASN1Integer;
    return RSAPrivateKey(modulus.valueAsBigInteger, exponent.valueAsBigInteger,
        p.valueAsBigInteger, q.valueAsBigInteger);
  }

  @override
  String privateKeyToASN1(PrivateKey privateKey) {
    assert(privateKey is RSAPrivateKey);
    final private = privateKey as RSAPrivateKey;

    final sequence = ASN1Sequence();
    // Add modulus -- n
    sequence.add(ASN1Integer(private.modulus));
    // Add public exponent -- e
    sequence.add(ASN1Integer(private.exponent));
    // Add prime1 -- p
    sequence.add(ASN1Integer(private.p));
    // Add prime2 -- q
    sequence.add(ASN1Integer(private.q));
    return base64.encode(sequence.encodedBytes);
  }

  @override
  PublicKey publicKeyFromASN1(Uint8List encoded) {
    final parser = ASN1Parser(encoded);
    final sequence = parser.nextObject() as ASN1Sequence;
    if (sequence.elements.length != 2) {
      throw "Public Key has to contain modulus and exponent";
    }

    final modulus = sequence.elements[0] as ASN1Integer;
    final exponent = sequence.elements[1] as ASN1Integer;
    return RSAPublicKey(modulus.valueAsBigInteger, exponent.valueAsBigInteger);
  }

  @override
  String publicKeyToASN1(PublicKey publicKey) {
    assert(publicKey is RSAPublicKey);
    final public = publicKey as RSAPublicKey;

    final sequence = ASN1Sequence();
    sequence.add(ASN1Integer(public.modulus));
    sequence.add(ASN1Integer(public.exponent));
    return base64.encode(sequence.encodedBytes);
  }

  @override
  String get algorithm => "RSA";
}

class AlgorithmId {
  final String algorithm;
  final ASN1Sequence parameters;

  AlgorithmId(this.algorithm, this.parameters);
}

class Validity {
  final DateTime notBefore;
  final DateTime notAfter;

  Validity(this.notBefore, this.notAfter);
}

class PublicKeyInfo {
  final AlgorithmId algorithm;
  final ASN1BitString subjectPublicKey;

  PublicKeyInfo(this.algorithm, this.subjectPublicKey);
}

class NameBuilder {
  ASN1Sequence _name;

  NameBuilder add(ASN1Object obj) {
    _name.add(obj);
    return this;
  }

  ASN1Sequence build() {
    return _name;
  }
}

/// Used to generate a X.509 Certificate as described in https://tools.ietf.org/html/rfc5280#section-4.1.
class RSACertGenerator {
  BigInt serialNumber;
  ASN1Sequence issuer;
  Validity validity;
  ASN1Sequence subject;
  PublicKeyInfo subjectPublicKeyInfo;
  ASN1BitString issuerUniqueIdentifier;
  ASN1BitString subjectUniqueIdentifier;

  Uint8List _signer(RSAPrivateKey privateKey, Uint8List input) {
    final signer = RSASigner(SHA256Digest(), "0609608648016503040201");
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    return signer.generateSignature(input).bytes;
  }

  Uint8List build(RSAPrivateKey privateKey) {
    if (this.serialNumber == null) {
      throw "Missing Certificate Serialnumber";
    }
    if (this.issuer == null) {
      throw "Missing Issuer";
    }
    if (this.validity == null) {
      throw "Missing validity";
    }
    if (this.subject == null) {
      throw "Missing subject";
    }
    if (this.subjectPublicKeyInfo == null ||
        this.subjectPublicKeyInfo.algorithm.algorithm == null ||
        this.subjectPublicKeyInfo.subjectPublicKey == null) {
      throw "Missing SubjectPublicKeyInfo, Algorithm Name of SubjectPublicKeyInfo or SubjectPublicKey";
    }
    if (this._signer == null) {
      throw "Missing Signer";
    }

    // TBSCertificate
    final tbsCertificate = ASN1Sequence()
      // Version -- v2 == 1
      ..add(ASN1Integer(BigInt.from(1)))
      // Serial Number
      ..add(ASN1Integer(this.serialNumber))
      // Signature Algorithm
      ..add(ASN1Sequence()
        ..add(ASN1ObjectIdentifier.fromName("sha256WithRSAEncryption"))
        ..add(ASN1Null()))
      ..add(this.issuer)
      // Validity
      ..add(ASN1Sequence()
        ..add(ASN1UtcTime(this.validity.notBefore))
        ..add(ASN1UtcTime(this.validity.notAfter)))
      ..add(this.subject)
      // PublicKeyInfo
      ..add(ASN1Sequence()
        ..add(ASN1Sequence()
          ..add(ASN1ObjectIdentifier.fromName(
              this.subjectPublicKeyInfo.algorithm.algorithm))
          ..add(this.subjectPublicKeyInfo.algorithm?.parameters ?? ASN1Null()))
        ..add(this.subjectPublicKeyInfo.subjectPublicKey))
      ..add(this.issuerUniqueIdentifier)
      ..add(this.subjectUniqueIdentifier);

    // Build actual Certificate
    final certificate = ASN1Sequence()
      ..add(tbsCertificate)
      // SignatureAlgorithm which has to be the same as tbsCertificate.signature
      ..add(ASN1Sequence()
        ..add(ASN1ObjectIdentifier.fromName("sha256WithRSAEncryption"))
        ..add(ASN1Null()))
      // Actual Signature over tbsCertificate
      ..add(
          ASN1BitString(this._signer(privateKey, tbsCertificate.encodedBytes)));
    return certificate.encodedBytes;
  }
}
