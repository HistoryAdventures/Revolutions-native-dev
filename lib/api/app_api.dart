import 'package:history_adventures/api/main/main.dart';

class AppAPI {
  static AppAPI _singleton;

  final MainAPI main;

  AppAPI._internal({this.main});

  factory AppAPI() {
    if (_singleton == null) {
      _singleton = AppAPI._internal(
        main: MainAPI(),
      );
    }

    return _singleton;
  }
}
