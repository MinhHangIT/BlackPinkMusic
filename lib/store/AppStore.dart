import 'package:mobx/mobx.dart';

part 'AppStore.g.dart';
class AppStore = _AppStore with _$AppStore;
abstract class _AppStore with Store {
  @observable
  bool isRingtone = false;
  bool isLocal = false;
}
final AppStore store = new AppStore();