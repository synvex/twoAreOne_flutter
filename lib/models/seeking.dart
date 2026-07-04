import 'package:flutter/material.dart';

class SeekingOption {
  final String id;
  final String label;
  final String gender;
  final String sexuality;
  final IconData icon1;
  final IconData icon2;
  final Color color1;
  final Color color2;

  SeekingOption({
    required this.id,
    required this.label,
    required this.gender,
    required this.sexuality,
    required this.icon1,
    required this.icon2,
    required this.color1,
    required this.color2,
  });
}