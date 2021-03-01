import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

class AppFunctions {
  static String removeLineBreaks(String text) {
    String result = '';

    for (String ln in text.split('\n')) {
      result += ln.trim();
    }

    return result;
  }

  // set status and navigation bars' icons color to white
  static void setLightForeground() {
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  }

  // set status and navigation bars' icons color to white
  static void setDarkForeground() {
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
  }
}
