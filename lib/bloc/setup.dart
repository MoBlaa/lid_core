
import 'package:core/infrastructure/owner.dart';
import 'package:core/utils/random.dart';
import 'package:core/utils/rsa.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/api.dart';
import 'package:rxdart/rxdart.dart';

enum SetupState {
  WaitingForInput, GeneratingId, GeneratingOwner, Finished
}

class SetupBloc {
  final _step = BehaviorSubject<SetupState>.seeded(SetupState.WaitingForInput);
  final _id = BehaviorSubject<String>();

  Stream<SetupState> get setupState => _step.stream;
  Stream<String> get id => _id.stream;

  Future<Owner> generate(String name) async {
    _step.add(SetupState.GeneratingId);
    final id = await compute(generateRandomString, 32);
    _id.add(id);
    _step.add(SetupState.GeneratingOwner);
    final keyPair = await compute(gen, null);
    _step.add(SetupState.Finished);
    return Owner(id, name, keyPair);
  }
}

Future<AsymmetricKeyPair<PublicKey, PrivateKey>> gen(Object _) async {
  final random = newRandom();
  final keyPair = await genKeyPair(random);
  return keyPair;
}