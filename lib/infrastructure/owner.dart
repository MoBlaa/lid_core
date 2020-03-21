import 'dart:convert';
import 'dart:typed_data';

import 'package:core/utils/rsa.dart';
import 'package:hive/hive.dart';
import 'package:pointycastle/export.dart';

class Owner {
  final String id;
  final String name;
  final AsymmetricKeyPair<PublicKey, PrivateKey> _keyPair;

  /// https://tools.ietf.org/html/rfc3447#appendix-A
  String get publicKeyASN1 =>
      publicKeyToASN1(this._keyPair.publicKey as RSAPublicKey);

  /// https://tools.ietf.org/html/rfc3447#appendix-A but omits the values not needed by pointycastle.
  String get privateKeyASN1 =>
      privateKeyToASN1(this._keyPair.privateKey as RSAPrivateKey);

  Owner(this.id, this.name, this._keyPair);

  Owner.fromASN1(String id, String name, Uint8List pubEncoded, Uint8List privEncoded)
      : this(id, name, AsymmetricKeyPair(
            publicKeyFromASN1(pubEncoded), privateKeyFromASN1(privEncoded)));

  static Owner fromString(String input) {
    final split = input.split("::");
    if (split.length != 4) {
      throw "Invalid String Format, has to be separated by '::'";
    }
    return Owner.fromASN1(split[0], split[1], base64.decode(split[2]), base64.decode(split[3]));
  }

  @override
  String toString() => "$id::$name::$publicKeyASN1::$privateKeyASN1";
}

class OwnerAdapter extends TypeAdapter<Owner> {
  @override
  int get typeId => 165;

  @override
  Owner read(BinaryReader reader) {
    try {
      final id = reader.readString();
      final name = reader.readString();
      final b64Public = reader.readString();
      final b64Private = reader.readString();
      return Owner.fromASN1(id, name, base64.decode(b64Public), base64.decode(b64Private));
    } catch (e) {
      print("Got error while loading owner: '$e'. Returning empty");
      return null;
    }
  }

  @override
  void write(BinaryWriter writer, Owner obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.publicKeyASN1);
    writer.writeString(obj.privateKeyASN1);
  }
}
