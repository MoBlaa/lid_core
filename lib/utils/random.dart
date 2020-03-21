
import 'dart:math';

const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

String generateRandomString(int strlen) {
  final rnd = Random.secure();
  final buffer = StringBuffer();
  for (var i = 0; i < strlen; i++) {
    buffer.writeCharCode(chars[rnd.nextInt(chars.length)].codeUnitAt(0));
  }
  return buffer.toString();
}