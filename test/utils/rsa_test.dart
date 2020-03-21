
import 'package:asn1lib/asn1lib.dart';
import 'package:core/utils/rsa.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/export.dart';

void main() {
  test('Test Signature generation', () {
    ASN1ObjectIdentifier.registerFrequentNames();

    final owner = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromName("cn"))
      ..add(ASN1PrintableString("Mo Blaa"));

    // Generate KeyPair
    final keyPair = genKeyPair(newRandom());
    final publicKey = keyPair.publicKey as RSAPublicKey;
    final privateKey = keyPair.privateKey as RSAPrivateKey;

    // Encode public key to include
    final encodedPubKey = ASN1Sequence();
    encodedPubKey.add(ASN1Integer(publicKey.modulus));
    encodedPubKey.add(ASN1Integer(publicKey.exponent));

    final builder = RSACertGenerator()
        ..serialNumber = BigInt.two
        ..issuer = owner
        ..subject = owner
        ..validity = Validity(DateTime.now(), DateTime.now().add(Duration(days: 365)))
        ..subjectPublicKeyInfo = PublicKeyInfo(
          AlgorithmId("rsaEncryption", null),
          ASN1BitString(encodedPubKey.encodedBytes)
        )
        ..issuerUniqueIdentifier = ASN1BitString([1])
        ..subjectUniqueIdentifier = ASN1BitString([2]);
    final encoded = builder.build(privateKey);

    // Then parse
    final parser = ASN1Parser(encoded);
    final certificate = parser.nextObject() as ASN1Sequence;
    expect(certificate.elements.length, 3);
    
    final tbsCertificate = certificate.elements[0] as ASN1Sequence;
    final signature = (certificate.elements[2] as ASN1BitString).contentBytes();
    
    final verifier = RSASigner(SHA256Digest(), "0609608648016503040201");
    verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
    expect(verifier.verifySignature(tbsCertificate.encodedBytes, RSASignature(signature)), true);
  });
}