import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'containers.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final String imageStr;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? errorText; // ADD THIS
  final Color? bgColor;

  const CustomDropdownField({
    super.key,
    required this.label,
    this.value,
    required this.imageStr,
    required this.items,
    required this.onChanged,
    this.errorText, // ADD THIS
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // WRAP in Column
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Containers(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          radius: BorderRadius.circular(30),
          hexValue: 0xFFF0EFEF,
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              initialValue: value,
              hint: Text(
                label,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(15),
              menuMaxHeight: 300,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIconConstraints: const BoxConstraints(minWidth: 50),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(right: 10),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    imageStr,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        // ERROR TEXT
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2, bottom: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

// class CustomDropdownField extends StatelessWidget {
//   final String label;
//   final String? value;
//   final String imageStr;
//   final List<String> items;
//   final ValueChanged<String?> onChanged;
//
//   const CustomDropdownField({
//     super.key,
//     required this.label,
//     this.value,
//     required this.imageStr,
//     required this.items,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Containers(
//       margin: const EdgeInsets.symmetric(vertical: 8,),
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//         // color: const Color(0xFFF0EFEF), // Match your light gray background
//         radius: BorderRadius.circular(30),
//       hexValue: 0xFFF0EFEF,
//       child: DropdownButtonHideUnderline(
//         child: DropdownButtonFormField<String>(
//           value: value,
//           hint: Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
//           isExpanded: true,
//           // Control the menu appearance
//           dropdownColor: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           menuMaxHeight: 300, // Important for 100+ items
//           icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
//           decoration: InputDecoration(
//             border: InputBorder.none,
//             prefixIconConstraints: const BoxConstraints(minWidth: 50),
//             // Custom prefix to match your image
//             prefixIcon: Container(
//               margin: const EdgeInsets.only(right: 10),
//               height: 40,
//               width: 40,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF77153C), // The dark red/purple from your image
//                 shape: BoxShape.circle,
//               ),
//               padding: const EdgeInsets.all(8),
//               child: SvgPicture.asset(
//                 imageStr,
//                 colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
//               ),
//             ),
//           ),
//           items: items.map((String item) {
//             return DropdownMenuItem<String>(
//               value: item,
//               child: Text(item, style: const TextStyle(fontSize: 16)),
//             );
//           }).toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
// }
