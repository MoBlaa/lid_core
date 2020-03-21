import 'package:hive/hive.dart';

import 'owner.dart';

class Repository {
  final Box<Owner> _ownerBox;
  
  Repository._(this._ownerBox);

  /// Create a new Repository. In Order to use it you have to call `Hive.init`
  /// or `Hive.initFlutter`.
  static Future<Repository> create() async {
    Hive.registerAdapter(OwnerAdapter());
    final ownerBox = await Hive.openBox<Owner>("owner");
    return Repository._(ownerBox);
  }

  void saveOwner(Owner owner) async {
    await this._ownerBox.put("owner", owner);
  }

  Owner loadOwner() => this._ownerBox.get("owner");

  void deleteOwner() async => await this._ownerBox.delete("owner");
}