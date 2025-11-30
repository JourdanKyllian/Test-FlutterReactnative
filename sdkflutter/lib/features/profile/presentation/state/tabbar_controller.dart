import 'package:flutter/foundation.dart';

/// Contrôleur pour gérer l'onglet sélectionné dans la bottom tabbar.
class TabControllerNotifier extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  /// Change l'index de l'onglet sélectionné dans la bottom tabbar.
  void setIndex(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }
}
