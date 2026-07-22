
import 'package:flutter/material.dart';

import 'package:two_are_one/core/widgets/image.dart';

class StepperField extends StatelessWidget {
  final String label;
  final String displayValue;
  final String imageStr;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const StepperField({super.key,
    required this.label,
    required this.displayValue,
    required this.imageStr,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 30, height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF77153C), shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Images(imageStr: imageStr),
            ),
          ),
          const SizedBox(width: 12),

          // Label
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
          ),

          // Decrement button
          GestureDetector(
            onTap: onDecrement,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)],
              ),
              child: const Icon(Icons.remove, size: 16, color: Color(0xFF77153C)),
            ),
          ),
          const SizedBox(width: 10),

          // Value
          Text(
            displayValue,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          const SizedBox(width: 10),

          // Increment button
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF77153C),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)],
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}