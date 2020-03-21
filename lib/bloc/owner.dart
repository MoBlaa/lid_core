import 'package:core/infrastructure/repo.dart';

class OwnerPageBloc {
  final Repository _repo;

  OwnerPageBloc(this._repo);

  void deleteOwner() {
    this._repo.deleteOwner();
  }
}