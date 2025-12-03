import 'package:flutter/material.dart';

abstract class LineChartChangeNotifier<T> extends ChangeNotifier {
  T? x;
  bool isTouched = false;

  LineChartChangeNotifier({required this.x});

  void setX(T? value) {
    x = value;
    notifyListeners();
  }

  void setTouched(bool value) {
    isTouched = value;
    notifyListeners();
  }

  void updateTouch(T? value, bool touched) {
    x = value;
    isTouched = touched;
    notifyListeners();
  }
}
