import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});
  @override
  Widget build(BuildContext context) {

    return const SizedBox(
        height: 32,
        child:  VerticalDivider(color: Colors.white24,width: 10,thickness: 1,));
  }
}
