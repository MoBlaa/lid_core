
import 'dart:isolate';

import 'package:core/infrastructure/owner.dart';
import 'package:core/utils/random.dart';
import 'package:core/utils/rsa.dart';
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
    final id = await runSimpleBackground(generateRandomString, 32);
    _id.add(id);
    _step.add(SetupState.GeneratingOwner);
    final keyPair = await runBackground(gen, Object());
    _step.add(SetupState.Finished);
    return Owner(id, name, keyPair);
  }

  Future<R> runBackground<T, R>(Future<R> Function(T) f, T message) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn((message) async {
      final result = await f(message);
      receivePort.sendPort.send(result);
    }, message);
    return await receivePort.first;
  }

  Future<R> runSimpleBackground<T, R>(R Function(T) f, T message) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn((message) async {
      final result = await f(message);
      receivePort.sendPort.send(result);
    }, message);
    return await receivePort.first;
  }
}

Future<AsymmetricKeyPair<PublicKey, PrivateKey>> gen(Object _) async {
  final random = newRandom();
  final keyPair = await genKeyPair(random);
  return keyPair;
}