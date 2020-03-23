import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

String generateRandomString(int strlen) {
  final rnd = Random.secure();
  final buffer = StringBuffer();
  for (var i = 0; i < strlen; i++) {
    buffer.writeCharCode(chars[rnd.nextInt(chars.length)].codeUnitAt(0));
  }
  return buffer.toString();
}

SecureRandom newRandom() {
  final rnd = FortunaRandom();
  final random = Random.secure();
  final seed = List<int>.generate(32, (_) => random.nextInt(256));
  rnd.seed(KeyParameter(Uint8List.fromList(seed)));
  return rnd;
}