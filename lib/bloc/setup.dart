import 'dart:async';

import 'package:core/domain/crypto/module.dart';
import 'package:core/domain/owner.dart';
import 'package:rxdart/rxdart.dart';

enum SetupState { WaitingForInput, GeneratingId, GeneratingOwner, Finished }

class SetupBloc {
  final _step = BehaviorSubject<SetupState>.seeded(SetupState.WaitingForInput);
  final _id = BehaviorSubject<String>();
  final CryptoModule _cryptoModule;

  Stream<SetupState> get setupState => _step.stream;

  Stream<String> get id => _id.stream;

  SetupBloc(this._cryptoModule);

  Future<Owner> generate(String name) async {
    _step.add(SetupState.GeneratingId);
    final id = await _cryptoModule.generateId(32);
    _id.add(id);
    _step.add(SetupState.GeneratingOwner);
    final owner = await _cryptoModule.generateOwner(id, name);
    _step.add(SetupState.Finished);
    return owner;
  }
}
