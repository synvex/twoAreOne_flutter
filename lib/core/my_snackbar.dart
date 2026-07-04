import 'package:flutter/material.dart';
import 'package:two_are_one/core/texts.dart';

class MySnackBar extends StatelessWidget {
  final String text;
  const MySnackBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SnackBar(content: Texts(
          text: text)),
    );
  }
}
