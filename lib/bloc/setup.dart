import 'dart:async';

import 'package:core/core.dart';
import 'package:core/infrastructure/owner.dart';
import 'package:core/utils/random.dart';
import 'package:core/utils/rsa.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

enum SetupState { WaitingForInput, GeneratingId, GeneratingOwner, Finished }

class SetupBloc {
  final _step = BehaviorSubject<SetupState>.seeded(SetupState.WaitingForInput);
  final _id = BehaviorSubject<String>();

  Stream<SetupState> get setupState => _step.stream;

  Stream<String> get id => _id.stream;

  Future<Owner> generate(String name) async {
    _step.add(SetupState.GeneratingId);
    final id = kIsWeb ? await generateId(32) : await compute(generateRandomString, 32);
    _id.add(id);
    _step.add(SetupState.GeneratingOwner);
    final owner = kIsWeb ? await generateOwner(id, name) : await compute(genOwner, {'id': id, 'name': name});
    _step.add(SetupState.Finished);
    return owner;
  }
}

Owner genOwner(Map<String, dynamic> params) {
  final rand = newRandom();
  final keyPair = genKeyPair(rand);
  return Owner(params['id'], params['name'], keyPair);
}
