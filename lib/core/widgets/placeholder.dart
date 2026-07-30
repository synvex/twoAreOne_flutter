import 'package:flutter/cupertino.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/texts.dart';

class PlaceholderImage extends StatelessWidget {
  final double? height;
  final double? width;
  final double? size;
  const PlaceholderImage({super.key, this.height, this.width, this.size});

  @override
  Widget build(BuildContext context) {
    return Containers(
      hexValue: 0xFFFFFFFF,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Images(imageStr: 'assets/svg_images/interested.svg',
          height: height,width: width),
          Texts(text: "No-Pic",fontWeight: FontWeight.bold, size: size,)
        ],
      ),
    );
  }
}
