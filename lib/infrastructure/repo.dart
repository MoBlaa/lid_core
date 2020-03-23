import 'package:core/domain/owner.dart';

abstract class Repository {
  void saveOwner(Owner owner);
  Owner loadOwner();
  void deleteOwner();
}