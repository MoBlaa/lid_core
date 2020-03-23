
import 'package:core/domain/crypto/asymmetric/rsa.dart';
import 'package:core/domain/crypto/random.dart';
import 'package:core/domain/owner.dart';
import 'package:flutter/foundation.dart';

abstract class CryptoModule {
  Future<String> generateId(int length);
  Future<Owner> generateOwner(String id, String name);
}

class FlutterCryptoModule implements CryptoModule {
  @override
  Future<String> generateId(int length) => compute(generateRandomString, length);

  @override
  Future<Owner> generateOwner(String id, String name) => compute(genOwner, {'id': id, 'name': name});
}

Owner genOwner(Map<String, dynamic> params) {
  final rand = newRandom();
  final module = RSAModule();
  final keyPair = module.genKeyPair(rand);
  return Owner(params['id'], params['name'], module, keyPair);
}