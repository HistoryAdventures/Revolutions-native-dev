import 'package:flutter/material.dart';
import 'package:history_adventures/ui/pages/main/main_page.dart';

void main() {
  runApp(HistoryAdventures());
}

class HistoryAdventures extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}
