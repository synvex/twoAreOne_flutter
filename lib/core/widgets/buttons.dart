import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/texts.dart';

class Buttons extends StatelessWidget {
  final Gradient? gradient;
  final Color? color;
  final Widget? widget;
  final int? hexValue;
  final int? hex;
  final FontWeight? fontWeight;
  final double? width;
  final double? height;
  final double? opacity;
  final double? textSize;
  final double? letterSpacing;
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;

  const Buttons({super.key, this.color,
    required this.text, required this.onTap,
     this.hexValue, this.gradient, this.hex,
    this.width, this.height, this.fontWeight, this.widget, this.isLoading= false, this.textSize, this.opacity, this.letterSpacing});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Center(
          child: Container(
            width: width ?? 358,
            height: height ?? 54.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: gradient?.withOpacity(opacity ?? 1),
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1.5,
                      color: Color(hex ?? 0x00000000),
                    ),
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: isLoading ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white, // Match your text color
                  strokeWidth: 2,
                ),
              )
                  : Texts(
                letterSpacing: letterSpacing,
                fontWeight: fontWeight ?? FontWeight.w600,
                      colorHexValue: hexValue ?? 0xFFFFFFFF,
                size: textSize ?? 20, text: text,),
              ),
          ),
        ),
      ],
        );
  }
}



class TxtButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final int? colorHex;
  final FontWeight? fontWeight;
  final double? sizeTxt;
  const TxtButton({super.key,
    required this.text,
    required this.onTap, this.colorHex,
    this.sizeTxt, this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onTap,
        child: Texts(
            text: text,
            size: sizeTxt,
            fontWeight: fontWeight,
            colorHexValue: colorHex,)
    );
  }
}
