import 'package:flutter/material.dart';

class Back_Button extends StatelessWidget {
  final VoidCallback onTap;
  const Back_Button({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(0xFF786C65),
            width: 1.2,
          ),
          color: Colors.transparent,
        ),
        child:  Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Color(0xFF786C65),
        size: 33,
      ),
      ),
    );
  }
}
