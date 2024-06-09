import 'package:flutter/material.dart';

class ViewProfileProvider with ChangeNotifier {
  bool _showPic = false;

  bool get showPic {
    return _showPic;
  }

  void closeProfilePic() {
    _showPic = !_showPic;
    notifyListeners();
  }
}
