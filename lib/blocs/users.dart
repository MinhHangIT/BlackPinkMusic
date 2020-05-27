import 'package:ringtone_app/model/Users.dart';
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';

class UsersBloc {
  BehaviorSubject<Users> _userData$;

  BehaviorSubject<Users> get userData$ =>
      _userData$;

  UsersBloc() {
    _userData$ = BehaviorSubject<Users>();
  }


  void dispose() {
    _userData$.close();
  }
}
