import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final Color? color;
  const CustomDivider({super.key, this.color});
  @override
  Widget build(BuildContext context) {

    return SizedBox(
         height: 32,
        child:  VerticalDivider(color: color ?? Colors.white24,width: 10,thickness: 1,));
  }
}
