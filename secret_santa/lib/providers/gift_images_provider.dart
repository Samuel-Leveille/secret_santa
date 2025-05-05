import 'package:flutter/material.dart';
import 'dart:typed_data';

class GiftImagesProvider extends ChangeNotifier {
  final List<Uint8List> _giftImages = [];

  List<Uint8List> get giftImages => _giftImages;

  void addImage(Uint8List image) {
    _giftImages.add(image);
    notifyListeners();
  }

  void removeImage(int index) {
    _giftImages.removeAt(index);
    notifyListeners();
  }

  void removeAllImage() {
    for (int i = _giftImages.length; i != 0; i--) {
      _giftImages.removeAt(i - 1);
    }
    notifyListeners();
  }
}
