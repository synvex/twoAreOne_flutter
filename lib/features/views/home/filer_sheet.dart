import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/texts.dart';

const String kGoogleApiKey = "AIzaSyCqZ38paEOdX0SnqU0u6wBlEasNIwKRNe0";

class FilterBottomSheet extends StatefulWidget {
  final void Function(Map<String, dynamic> filters) onApply;
  final VoidCallback? onReset;
  final Map<String, dynamic>?
  initialFilters; // RN ki tarah initial state pass karne ke liye

  const FilterBottomSheet({
    super.key,
    required this.onApply,
    this.onReset,
    this.initialFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String selectedGender = "Men";

  RangeValues _distanceRange = const RangeValues(0, 3000);
  RangeValues _ageRange = const RangeValues(15, 90);

  String _country = "";
  String _city = "";
  final TextEditingController _locationController = TextEditingController();
  List<Map<String, dynamic>> _placeSuggestions = [];
  Timer? _debounce;
  bool _searchingPlaces = false;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    if (f != null) {
      selectedGender = (f["gender"] ?? "men").toString() == "women"
          ? "Women"
          : "Men";

      final ageStr = (f["age_range"] ?? "").toString();
      if (ageStr.contains(",")) {
        final parts = ageStr.split(",");
        _ageRange = RangeValues(
          double.tryParse(parts[0]) ?? 15,
          double.tryParse(parts[1]) ?? 90,
        );
      }

      final distStr = (f["distance_range"] ?? "").toString();
      if (distStr.contains(",")) {
        final parts = distStr.split(",");
        _distanceRange = RangeValues(
          double.tryParse(parts[0]) ?? 0,
          double.tryParse(parts[1]) ?? 3000,
        );
      }

      _country = f["country"] ?? "";
      _city = f["city"] ?? "";
      _locationController.text = _city;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _locationController.dispose();
    super.dispose();
  }

  //  Google Places Autocomplete call
  void _onLocationChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.trim().isEmpty) {
        setState(() => _placeSuggestions = []);
        return;
      }
      setState(() => _searchingPlaces = true);
      try {
        final url = Uri.parse(
          "https://maps.googleapis.com/maps/api/place/autocomplete/json"
          "?input=${Uri.encodeComponent(query)}&language=en&key=$kGoogleApiKey",
        );
        final res = await http.get(url);
        final data = jsonDecode(res.body);
        final predictions = (data["predictions"] as List?) ?? [];
        setState(() {
          _placeSuggestions = predictions
              .map(
                (p) => {
                  "description": p["description"],
                  "place_id": p["place_id"],
                },
              )
              .cast<Map<String, dynamic>>()
              .toList();
        });
      } catch (_) {
        setState(() => _placeSuggestions = []);
      } finally {
        setState(() => _searchingPlaces = false);
      }
    });
  }

  // Place select hone par details fetch karo (RN onPress + address_components jaisa)
  Future<void> _onSelectPlace(String placeId, String description) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _placeSuggestions = [];
      _locationController.text = description;
    });
    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId&fields=address_component&key=$kGoogleApiKey",
      );
      final res = await http.get(url);
      final data = jsonDecode(res.body);
      final components = (data["result"]?["address_components"] as List?) ?? [];

      String getComponent(String type) {
        for (final c in components) {
          final types = (c["types"] as List).cast<String>();
          if (types.contains(type)) return c["long_name"] ?? "";
        }
        return "";
      }

      final country = getComponent("country");
      final city = getComponent("locality").isNotEmpty
          ? getComponent("locality")
          : getComponent("administrative_area_level_2");

      setState(() {
        _country = country;
        _city = city;
      });
    } catch (_) {
      // silently ignore, RN version bhi try/catch ke baghair error handle nahi karta
    }
  }

  @override
  Widget build(BuildContext context) {
    double sheetHeight = 680; // location suggestions ke liye thora extra space

    return Container(
      height: sheetHeight,
      color: Colors.transparent,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, sheetHeight),
            painter: FilterBackgroundPainter(),
          ),
          Positioned(
            top: 5,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: Container(
              width: 55,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Texts(text: "Filter", size: 24)),
                  const SizedBox(height: 30),

                  // GENDER TOGGLE
                  Containers(
                    wHeight: 58,
                    padding: const EdgeInsets.all(4),
                    radius: BorderRadius.circular(30),
                    hexValue: 0xFFF8F8F8,
                    child: Row(
                      children: [
                        _buildToggleItem(
                          "Men",
                          () => setState(() => selectedGender = 'Men'),
                        ),
                        _buildToggleItem(
                          "Women",
                          () => setState(() => selectedGender = 'Women'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Texts(
                    text: "Locations",
                    size: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 10),
                  Containers(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    hexValue: 0xFFF3F3F3,
                    radius: BorderRadius.circular(30),
                    child: Row(
                      children: [
                        const Images(
                          imageStr: 'assets/svg_images/locationImg.svg',
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _locationController,
                            onChanged: _onLocationChanged,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: "Search location",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_searchingPlaces)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),

                  if (_placeSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _placeSuggestions.length,
                        separatorBuilder: (_, _) =>
                            Divider(height: 0.5, color: Colors.grey.shade300),
                        itemBuilder: (context, index) {
                          final item = _placeSuggestions[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              item["description"],
                              style: const TextStyle(fontSize: 13),
                            ),
                            onTap: () => _onSelectPlace(
                              item["place_id"],
                              item["description"],
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 25),
                  _sliderHeader(
                    "Distance",
                    "${_distanceRange.start.toInt()} - ${_distanceRange.end.toInt()} Miles",
                  ),
                  RangeSlider(
                    values: _distanceRange,
                    min: 0,
                    max: 3000, // ✅ RN jaisa max 3000
                    divisions: 300,
                    activeColor: const Color(0xFF77153C),
                    inactiveColor: const Color(0xFFEEEEEE),
                    onChanged: (val) => setState(() => _distanceRange = val),
                  ),

                  const SizedBox(height: 20),
                  // ✅ Age ab RANGE hai, single value nahi (RN jaisa)
                  _sliderHeader(
                    "Age",
                    "${_ageRange.start.toInt()} - ${_ageRange.end.toInt()} Years",
                  ),
                  RangeSlider(
                    values: _ageRange,
                    min: 15,
                    max: 90,
                    divisions: 75,
                    activeColor: const Color(0xFF77153C),
                    inactiveColor: const Color(0xFFEEEEEE),
                    onChanged: (val) => setState(() => _ageRange = val),
                  ),

                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: MainButtonWidget(
                          height: 55,
                          text: "Reset",
                          hexValue: 0xFF77153C,
                          onTap: () {
                            setState(() {
                              selectedGender = "Men";
                              _distanceRange = const RangeValues(0, 3000);
                              _ageRange = const RangeValues(15, 90);
                              _country = "";
                              _city = "";
                              _locationController.clear();
                              _placeSuggestions = [];
                            });
                            widget.onReset?.call();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: MainButtonWidget(
                          height: 55,
                          text: "Apply",
                          hexValue: 0xFFFFFFFF,
                          onTap: () {
                            // ✅ RN jaisa exact same shape / "min,max" string format
                            final filters = {
                              "gender": selectedGender.toLowerCase(),
                              "age_range":
                                  "${_ageRange.start.toInt()},${_ageRange.end.toInt()}",
                              "distance_range":
                                  "${_distanceRange.start.toInt()},${_distanceRange.end.toInt()}",
                              "country": _country,
                              "city": _city,
                              "isCalled": true,
                            };
                            widget.onApply(filters);
                            Navigator.pop(context);
                          },
                          gradient: const LinearGradient(
                            colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, VoidCallback onTap) {
    bool isSelected = selectedGender == title;
    return Expanded(
      child: MainButtonWidget(
        height: 50,
        text: title,
        onTap: onTap,
        hexValue: isSelected ? 0xFFFFFFFF : 0xFF8E8E8E,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF477CB6), Color(0xFFDD276F)],
              )
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
      ..color = Colors.black.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    double w = size.width;
    double h = size.height;
    path.moveTo(45, 0);
    path.lineTo(w * 0.35, 0);
    path.cubicTo(w * 0.42, 0, w * 0.41, 36, w * 0.5, 36);
    path.cubicTo(w * 0.59, 37, w * 0.57, 0, w * 0.64, 0);
    path.lineTo(w - 45, 0);
    path.quadraticBezierTo(w, 0, w, 45);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.lineTo(0, 45);
    path.quadraticBezierTo(0, 0, 45, 0);
    path.close();

    canvas.drawPath(path.shift(const Offset(0, -2)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
