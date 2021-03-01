import 'package:history_adventures/management/main/main.dart';

class AppModel {
  static AppModel _singleton;

  final MainActions mainActions;

  AppModel._internal({
    this.mainActions,
  });

  factory AppModel() {
    if (_singleton == null) {
      _singleton = AppModel._internal(
        mainActions: MainActions(),
      );
    }

    return _singleton;
  }
}
