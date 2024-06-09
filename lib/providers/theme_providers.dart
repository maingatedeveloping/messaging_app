import 'package:flutter/material.dart';
import 'package:i_chat/widgets/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  String currrentMode = 'Dark';

  ThemeData appTheme = darkMode;

  changeTheme() {
    if (appTheme == darkMode) {
      appTheme = lightMode;
    } else {
      appTheme = darkMode;
      currrentMode = 'Dark';
    }
    notifyListeners();
  }

  changeToLight() {
    appTheme = lightMode;
    currrentMode = 'Light';
    notifyListeners();
  }

  changeToDark() {
    appTheme = darkMode;
    currrentMode = 'Dark';
    notifyListeners();
  }
}
