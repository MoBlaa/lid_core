import 'dart:convert';
import 'dart:typed_data';

import 'package:core/utils/asymmetric/asymmetric_module.dart';
import 'package:hive/hive.dart';
import 'package:pointycastle/export.dart';

class Owner {
  final String id;
  final String name;
  final AsymmetricModule module;
  final AsymmetricKeyPair<PublicKey, PrivateKey> _keyPair;

  /// https://tools.ietf.org/html/rfc3447#appendix-A
  String get publicKeyASN1 =>
      module.publicKeyToASN1(this._keyPair.publicKey);

  /// https://tools.ietf.org/html/rfc3447#appendix-A but omits the values not needed by pointycastle.
  String get privateKeyASN1 =>
      module.privateKeyToASN1(this._keyPair.privateKey);

  Owner(this.id, this.name, this.module, this._keyPair);

  Owner.fromASN1(String id, String name, AsymmetricModule module,
      Uint8List pubEncoded, Uint8List privEncoded)
      : this(
            id,
            name,
            module,
            AsymmetricKeyPair(module.publicKeyFromASN1(pubEncoded),
                module.privateKeyFromASN1(privEncoded)));

  static Owner fromString(String input) {
    final split = input.split("::");
    if (split.length != 5) {
      throw "Invalid String Format, has to be separated by '::'";
    }
    final module = AsymmetricModule.fromString(split[2]);
    return Owner.fromASN1(split[0], split[1], module, base64.decode(split[3]),
        base64.decode(split[4]));
  }

  @override
  String toString() => "$id::$name::${module.algorithm}::$publicKeyASN1::$privateKeyASN1";
}

class OwnerAdapter extends TypeAdapter<Owner> {
  @override
  int get typeId => 165;

  @override
  Owner read(BinaryReader reader) {
    try {
      final alg = reader.readString();
      final module = AsymmetricModule.fromString(alg);
      final id = reader.readString();
      final name = reader.readString();
      final b64Public = reader.readString();
      final b64Private = reader.readString();
      return Owner.fromASN1(id, name, module, base64.decode(b64Public),
          base64.decode(b64Private));
    } catch (e) {
      print("Got error while loading owner: '$e'. Returning empty");
      return null;
    }
  }

  @override
  void write(BinaryWriter writer, Owner obj) {
    writer.writeString(obj.module.algorithm);
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.publicKeyASN1);
    writer.writeString(obj.privateKeyASN1);
  }
}
