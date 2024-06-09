import 'package:flutter/material.dart';

class RemoveFromUsersProvider with ChangeNotifier {
  final List<String> _selectedIndexes = [];

  List<String> get selectedIndexes {
    return _selectedIndexes;
  }

  void updateButton(String indexId) {
    _selectedIndexes.add(indexId);
    notifyListeners();
  }

  void resetIndexes() {
    _selectedIndexes.clear();
    notifyListeners();
  }
}
