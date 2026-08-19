import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/image.dart';

class StackedUserCards extends StatelessWidget {
  const StackedUserCards({super.key});
  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double screenWidth = MediaQuery.of(context).size.width;
    const double stackHeight = 250.0;
    return SizedBox(
      height: stackHeight,
      width: screenWidth,
      child: Images(imageStr: 'assets/images/main_card.png'),
    );
  }
}









