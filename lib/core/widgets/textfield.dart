import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:two_are_one/core/widgets/texts.dart';

class CustomInputField extends StatefulWidget {
  final String? label;
  final TextInputType? textInputType;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefixImg;
  final bool isPassword;
  final int? borderColor;
  final int? fillColor;
  final VoidCallback? onTap;
  final double? height;
  final int? textColor;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  const CustomInputField({
    super.key,
    this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.fillColor,
    this.borderColor,
    this.controller,
    this.textInputType,
    this.height,
    this.onChanged,
    this.onTap,
    this.textColor,
    this.prefixImg,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  @override
  Widget build(BuildContext context) {
    final roundedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
        color: Color(widget.borderColor ?? 0xFFFFFFFF),
        width: 1.5,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          keyboardType: widget.textInputType,
          controller: widget.controller,
          obscureText: widget.isPassword,
          textAlign: TextAlign.left,
          cursorColor: Colors.black,
          onChanged: widget.onChanged,
          style: TextStyle(color: Color(0xFF787878)),
          decoration: InputDecoration(
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            iconColor: Color(0xFF787878),
            prefixIconColor: Color(0xFF787878),
            isDense: true,
            label: widget.label != null
                ? Texts(text: widget.label!, colorHexValue: 0xFF787878)
                : null,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Color(widget.textColor ?? 0xFF787878),
              fontSize: 16,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 10),
              child:
                  widget.prefixImg ??
                  (widget.prefixIcon != null ? Icon(widget.prefixIcon) : null),
            ),
            suffixIcon: widget.suffixIcon != null
                ? InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: widget.onTap,
                    child: widget.suffixIcon,
                  )
                : null,
            filled: true,
            fillColor: Color(widget.fillColor ?? 0xFFF0EFEF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 15,
            ),
            border: roundedBorder,
            enabledBorder: roundedBorder,
            focusedBorder: roundedBorder,
            errorBorder: roundedBorder,
          ),
        ),
      ],
    );
  }
}

class TxtField extends StatelessWidget {
  final int? minLines;
  final TextEditingController? controller;
  const TxtField({super.key, this.controller, this.minLines});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      autofocus: true,
      minLines: minLines,
      autofillHints: const [AutofillHints.telephoneNumber],
      style: TextStyle(fontSize: 13, color: Colors.black),
      cursorColor: Colors.green.shade800,
      cursorHeight: 16,
      cursorWidth: 2.5,
      decoration: InputDecoration(
        hintText: "XXX-XXXXXX",
        hintStyle: TextStyle(fontSize: 13),

        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

class CircleField extends StatelessWidget {
  final TextEditingController? controller;
  const CircleField({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Pinput(
      controller: controller,
      length: 6,
      defaultPinTheme: PinTheme(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          color: Color(0xFFEEEEEE),
          shape: BoxShape.circle,
          border: Border.all(width: 1.5, color: Color(0xFF77153C)),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF727272),
        ),
      ),
      separatorBuilder: (index) => SizedBox(width: 15),
    );
  }
}
