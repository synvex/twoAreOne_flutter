import 'package:flutter/material.dart';
import 'package:two_are_one/core/containers.dart';
import 'package:two_are_one/core/texts.dart';
import 'package:two_are_one/core/buttons.dart';

class FilterBottomSheet extends StatefulWidget {
  final void Function(Map<String, dynamic> filters) onApply; // ✅ returns filter data
  final VoidCallback? onReset;                                // ✅ optional reset

  const FilterBottomSheet({super.key, required this.onApply, this.onReset});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {

  String selectedGender = "Men";
  RangeValues _distanceRange = const RangeValues(0, 3000);
  double _age = 26;

  @override
  Widget build(BuildContext context) {
    // Increase height to 600 to ensure everything fits
    double sheetHeight = 600;

    return Container(
      height: sheetHeight,
      color: Colors.transparent,
      child: Stack(
        children: [
          // 1. BACKGROUND PAINTER
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, sheetHeight),
            painter: FilterBackgroundPainter(),
          ),

          // 2. TOP HANDLE (NOTCH)
          Positioned(
            top: 15,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // 3. MAIN CONTENT
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Texts(text: "Filter", size: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 30),

                // GENDER TOGGLE (Men / Women)
                Containers(
                  wHeight: 55,
                  padding: const EdgeInsets.all(4),
                    radius: BorderRadius.circular(30),
                  hexValue: 0xFFF8F8F8,
                  child: Row(
                    children: [
                      _buildToggleItem("Men", () => setState(() => selectedGender = 'Men')),
                      _buildToggleItem("Women", () => setState(() => selectedGender = 'Women')),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                const Texts(text: "Locations", size: 14, fontWeight: FontWeight.w600),
                const SizedBox(height: 10),

                // LOCATION FIELD
                Containers(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  hexValue: 0xFFF3F3F3,
                  radius: BorderRadius.circular(30),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 20),
                      SizedBox(width: 10),
                      Texts(text: "Las Vegas Valley, Nevada", size: 12, colorHexValue: 0xFF8E8E8E),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                _sliderHeader("Distance", "${_distanceRange.end.toInt()} Miles"),
                RangeSlider(
                  values: _distanceRange,
                  max: 5000,
                  divisions: 50,
                  activeColor: const Color(0xFF77153C),
                  inactiveColor: const Color(0xFFEEEEEE),
                  onChanged: (val) => setState(() => _distanceRange = val),
                ),

                const SizedBox(height: 20),
                _sliderHeader("Age", _age.toInt().toString()),
                Slider(
                  value: _age,
                  min: 18,
                  max: 80,
                  activeColor: const Color(0xFF77153C),
                  inactiveColor: const Color(0xFFEEEEEE),
                  onChanged: (val) => setState(() => _age = val),
                ),

                const Spacer(), // Pushes buttons to the bottom
                // 4. ACTION BUTTONS (Reset & Apply)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // RESET BUTTON (Outline style)
                    Expanded(
                      child: Buttons(
                        height: 55,
                        text: "Reset",
                        hexValue: 0xFF77153C, // Burgundy Text
                        onTap: () {
                          setState(() {
                            selectedGender = "Men";
                            _distanceRange = const RangeValues(0, 3000);
                            _age = 26;
                          });
                          widget.onReset?.call();   // ✅ notify parent to reset its filterParams too
                          Navigator.pop(context);   // ✅ close sheet after reset
                        },
                        // If your button widget supports border, add it there.
                        // Otherwise, ensure 'gradient' being null shows a white/transparent background.
                      ),
                    ),
                    const SizedBox(width: 15),
                    // APPLY BUTTON (Full Gradient)
                    Expanded(
                      child: Buttons(
                        height: 55,
                        text: "Apply",
                        hexValue: 0xFFFFFFFF, // White Text
                        onTap: () {
                          final filters = {
                            "gender": selectedGender.toLowerCase(),  // "men" or "women"
                            "age_range": _age.toInt().toString(),
                            "distance_range": _distanceRange.end.toInt().toString(),
                            "country": "",  // extend later if you add location field
                            "city": "",
                          };
                          widget.onApply(filters);   // send data back to parent
                          Navigator.pop(context);}, // Then close
                        gradient: const LinearGradient(
                          colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30), // Bottom safe area padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, VoidCallback onTap) {
    bool isSelected = selectedGender == title;
    return Expanded(
      child: Buttons(
        height: 50,
        text: title,
        onTap: onTap,
        hexValue: isSelected ? 0xFFFFFFFF : 0xFF8E8E8E,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        gradient: isSelected
            ? const LinearGradient(colors: [Color(0xFF477CB6), Color(0xFFDD276F)])
            : null,
      ),
    );
  }

  Widget _sliderHeader(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Texts(text: title, size: 14, fontWeight: FontWeight.w600),
        Texts(text: value, size: 14, colorHexValue: 0xFF8E8E8E),
      ],
    );
  }
}



class FilterBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    double w = size.width;
    double h = size.height;

    // Translated from React Native SVG Path logic
    path.moveTo(45, 0);
    path.lineTo(w * 0.35, 0);

    // The Center Dip (Notch)
    path.cubicTo(w * 0.42, 0, w * 0.41, 36, w * 0.5, 36);
    path.cubicTo(w * 0.59, 36, w * 0.56, 0, w * 0.65, 0);

    path.lineTo(w - 45, 0);
    path.quadraticBezierTo(w, 0, w, 45); // Right corner
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.lineTo(0, 45);
    path.quadraticBezierTo(0, 0, 45, 0); // Left corner
    path.close();

    canvas.drawPath(path.shift(const Offset(0, -2)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}