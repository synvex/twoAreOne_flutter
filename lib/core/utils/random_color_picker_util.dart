import 'package:flutter/material.dart';

class RandomColorPickerUtil {
  RandomColorPickerUtil._();

  static const List<Color> _colors = [
    Color(0xFFFFCDD2),
    Color(0xFFF8BBD0),
    Color(0xFFE1BEE7),
    Color(0xFFD1C4E9),
    Color(0xFFC5CAE9),
    Color(0xFFBBDEFB),
    Color(0xFFB3E5FC),
    Color(0xFFB2EBF2),
    Color(0xFFB2DFDB),
    Color(0xFFC8E6C9),
    Color(0xFFDCEDC8),
    Color(0xFFF0F4C3),
    Color(0xFFFFF9C4),
    Color(0xFFFFECB3),
    Color(0xFFFFE0B2),
    Color(0xFFFFCCBC),
    Color(0xFFD7CCC8),
    Color(0xFFCFD8DC),
  ];

  static Color getColor(String key) {
    return _colors[key.hashCode.abs() % _colors.length];
  }
}
