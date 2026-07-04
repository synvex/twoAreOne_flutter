import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Images extends StatelessWidget {
  final String imageStr;
  final double? height;
  final double? width;
  final Color? color;

  const Images({
    super.key,
    required this.imageStr,
    this.height,
    this.width, 
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (imageStr.endsWith('.svg')) {
      return SvgPicture.asset(
        imageStr,
        height: height,
        width: width,
        colorFilter: color != null ? ColorFilter.mode(
            color!, BlendMode.srcIn) : null,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        imageStr,
        height: height,
        width: width,
        color: color,
        fit: BoxFit.contain,
      );
    }
  }
}

class Avatar extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final String imageStr;
  final Color? color;
  const Avatar(
      {super.key, this.top, this.bottom,
        this.left, this.right, required this.size,
        required this.imageStr, this.color});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: AssetImage(imageStr),
              ),
        ),
      ),
    );
  }
}
