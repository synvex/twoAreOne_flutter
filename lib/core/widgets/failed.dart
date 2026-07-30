import 'package:flutter/material.dart';

import 'package:two_are_one/core/widgets/image.dart';
// import 'package:two_are_one/core/containers.dart';
// import 'package:two_are_one/core/image.dart';

class FailedWidget extends StatelessWidget {
  const FailedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: 160,
      child: Images(imageStr: "assets/svg_images/error.svg"),
    );
  }

}
