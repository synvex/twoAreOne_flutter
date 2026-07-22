import 'package:flutter/material.dart';

class Texts extends StatelessWidget {
  final String text;
  final FontWeight? fontWeight;
  final int? colorHexValue;
  final double? size;
  final EdgeInsetsGeometry? edgeInsets;
  final int? underLineColor;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? letterSpacing;
  const Texts({
    super.key,
    required this.text,
    this.size,
    this.fontWeight,
    this.colorHexValue, this.underLineColor, this.textAlign, this.edgeInsets, this.maxLines, this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: edgeInsets ?? EdgeInsets.zero,
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        // overflow: TextOverflow.ellipsis,
        style: TextStyle(
          letterSpacing: letterSpacing,

          fontWeight: fontWeight,
          // Provided a default color if colorHexValue is null to avoid the crash
          color: colorHexValue != null ? Color(
              colorHexValue!) : Colors.black,
          fontSize: size,
        ),
      ),
    );
  }
}
class RichTexts extends StatelessWidget {
  final String? text;
  final int? colorHexValue;
  const RichTexts({super.key,  this.text, this.colorHexValue});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      //textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(colorHexValue ?? 0xFF727272),
        fontSize: 13,
        fontWeight: FontWeight.w500,
            ),

        );
  }
}
