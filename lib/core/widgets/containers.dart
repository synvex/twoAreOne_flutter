import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Containers extends StatelessWidget {
  final int hexValue;
  final BorderRadiusGeometry? radius;
  final Widget? child;
  final double? wHeight;
  final double? wWidth;
  final double? opacityValue;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BoxShape? shape;
  final Border? border;
  final AlignmentGeometry? alignment;
  final List<BoxShadow>? boxShadow;

  const Containers({
    super.key,
    required this.hexValue,
    this.radius,
    this.child,
    this.opacityValue,
    this.wHeight,
    this.wWidth,
    this.margin,
    this.padding,
    this.shape,
    this.border,
    this.alignment,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      margin: margin,
      padding: padding,
      width: wWidth, // Removed the forced screen percentage default
      height: wHeight, // Removed the forced screen percentage default
      decoration: BoxDecoration(
        color: Color(hexValue).withValues(alpha: opacityValue ?? 1.0),
        borderRadius: radius,
        boxShadow: boxShadow,
        shape: shape ?? BoxShape.rectangle,
        border: border,
      ),
      child: child,
    );
  }
}
