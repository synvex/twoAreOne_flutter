import 'package:flutter/material.dart';

class SeekingOption {
  final String id;
  final String label;
  final String genderId; // e.g., '1' for Male, '2' for Female
  final String sexualityId; // e.g., '1' for Male, '2' for Female
  final IconData icon1;
  final IconData icon2;
  final Color color1;
  final Color color2;

  SeekingOption({
    required this.id,
    required this.label,
    required this.genderId,
    required this.sexualityId,
    required this.icon1,
    required this.icon2,
    required this.color1,
    required this.color2,
  });
}
