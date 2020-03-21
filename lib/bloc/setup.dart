import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:isolate';

import 'package:core/infrastructure/owner.dart';
import 'package:core/utils/random.dart';
import 'package:core/utils/rsa.dart';
import 'package:core/utils/worker.dart';
import 'package:rxdart/rxdart.dart';

enum SetupState { WaitingForInput, GeneratingId, GeneratingOwner, Finished }

class SetupBloc {
  final _step = BehaviorSubject<SetupState>.seeded(SetupState.WaitingForInput);
  final _id = BehaviorSubject<String>();

  Stream<SetupState> get setupState => _step.stream;

  Stream<String> get id => _id.stream;

  Future<Owner> genOwner(String name) async {
    _step.add(SetupState.GeneratingId);
    final id = await runBackground(
        (strlen) => Future.value(generateRandomString(strlen)), 32);
    _id.add(id);
    _step.add(SetupState.GeneratingOwner);
    final keyPair = await runBackground((_) async {
      final random = newRandom();
      return await genKeyPair(random);
    }, null);
    _step.add(SetupState.Finished);
    return Owner(id, name, keyPair);
  }

  Future<Owner> genOwnerWorker(String name) async {
    final w = Worker('worker.js');

    _step.add(SetupState.GeneratingId);
    w.postMessage(jsonEncode(GenIdEvent(strlen: 32)));

    var cId = Completer<String>();
    w.onMessage.listen((event) => cId.complete(event.data as String));
    final id = await cId.future;
    _id.add(id);

    _step.add(SetupState.GeneratingOwner);
    w.postMessage(jsonEncode(GenOwnerEvent(id: id, name: name)));

    var cOwner = Completer<Owner>();
    w.onMessage.listen((event) {
      _step.add(SetupState.Finished);
      cOwner.complete(Owner.fromString(event.data as String));
    });
    return await cOwner.future;
  }

  Future<R> runBackground<T, R>(Future<R> Function(T) f, T message) async {
    final receivePort = ReceivePort();
    await Isolate.spawn((message) async {
      final result = await f(message);
      receivePort.sendPort.send(result);
    }, message);
    return await receivePort.first;
  }
}
