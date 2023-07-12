import 'package:flutter/material.dart';

class UserImageProvider extends ChangeNotifier {
  String? _imagePath;

  String? get imagePath => _imagePath;

  void setImagePath(String? imagePath) {
    _imagePath = imagePath;
    notifyListeners();
  }
}
