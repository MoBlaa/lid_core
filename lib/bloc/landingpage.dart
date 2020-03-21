import 'package:core/infrastructure/owner.dart';
import 'package:core/infrastructure/repo.dart';
import 'package:rxdart/rxdart.dart';

class LandingPageBloc {
  final _owner = BehaviorSubject<Owner>();

  final Repository _repo;

  Stream<Owner> get owner => _owner.stream;

  LandingPageBloc(this._repo) {
    _owner.add(this._repo.loadOwner());
  }

  void setOwner(Owner owner) {
    this._repo.saveOwner(owner);
    this._owner.add(owner);
  }
}