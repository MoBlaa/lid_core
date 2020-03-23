import 'package:core/domain/owner.dart';
import 'package:core/infrastructure/repo.dart';
import 'package:hive/hive.dart';

class HiveRepository implements Repository {
  final Box<Owner> _ownerBox;

  HiveRepository._(this._ownerBox);

  /// Create a new Repository. In Order to use it you have to call `Hive.init`
  /// or `Hive.initFlutter`.
  static Future<Repository> create() async {
    Hive.registerAdapter(OwnerAdapter());
    final ownerBox = await Hive.openBox<Owner>("owner");
    return HiveRepository._(ownerBox);
  }

  @override
  void saveOwner(Owner owner) async {
    await this._ownerBox.put("owner", owner);
  }

  @override
  Owner loadOwner() => this._ownerBox.get("owner");

  @override
  void deleteOwner() async => await this._ownerBox.delete("owner");
}