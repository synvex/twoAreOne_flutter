import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/textfield.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/models/location_data.dart';

class LocationSelectorField extends StatefulWidget {
  final String? labels;
  final int? fillColor;
  final String? hintText;
  final int? selectedClr;
  final Function(LocationData) onLocationSelected;

  final VoidCallback? onLocationCleared;

  const LocationSelectorField({
    super.key,
    this.labels,
    required this.onLocationSelected,
    this.onLocationCleared,
    this.fillColor,
    this.hintText, this.selectedClr,
  });

  @override
  State<LocationSelectorField> createState() => _LocationSelectorFieldState();
}

class _LocationSelectorFieldState extends State<LocationSelectorField> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _showSuggestions = false;
  bool _isLoading = false;
  String? _locationError;
  bool _hasValidSelection = false;

  static const String _apiKey = "AIzaSyCqZ38paEOdX0SnqU0u6wBlEasNIwKRNe0";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (_hasValidSelection) {
      _hasValidSelection = false;
      widget.onLocationCleared?.call();
    }
    if (_locationError != null) {
      setState(() => _locationError = null);
    }

    if (query.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
            "?input=${Uri.encodeComponent(query)}"
            "&key=$_apiKey"
            "&types=geocode",
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'TwoAreOne_App'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final predictions = (data['predictions'] as List?) ?? [];
        setState(() {
          _suggestions = predictions;
          _showSuggestions = predictions.isNotEmpty;
        });
      } else {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
    } catch (e) {
      debugPrint("Location Search Error: $e");
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _getPlaceDetails(String placeId, String displayName) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/details/json"
            "?place_id=$placeId"
            "&fields=geometry,address_components"
            "&key=$_apiKey",
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        _setError("No match found");
        return;
      }

      final data = json.decode(response.body);
      if (data['status'] != 'OK') {
        _setError("No match found");
        return;
      }

      final result = data['result'];
      final geometry = result['geometry']['location'];
      final components = (result['address_components'] as List?) ?? [];

      String country = '';
      String state = '';
      String city = '';

      for (var component in components) {
        final types = component['types'] as List;
        if (types.contains('country')) {
          country = component['long_name'];
        } else if (types.contains('administrative_area_level_1')) {
          state = component['long_name'];
        } else if (types.contains('locality') ||
            types.contains('administrative_area_level_2')) {
          city = component['long_name'];
        }
      }

      // A bare country pick (e.g. "United States", "Pakistan",
      // "United Kingdom") has no administrative_area_level_1 — reject it.
      if (state.isEmpty) {
        _setError(
          "No match found. Please select a city or state, not just a country.",
        );
        return;
      }

      final locationData = LocationData(
        address: displayName,
        country: country,
        state: state,
        city: city,
        latitude: geometry['lat'],
        longitude: geometry['lng'],
      );

      setState(() {
        _locationError = null;
        _controller.text = displayName;
        _hasValidSelection = true;
      });

      widget.onLocationSelected(locationData);
    } catch (e) {
      debugPrint("Place Details Error: $e");
      _setError("No match found");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _locationError = message;
      _showSuggestions = false;
      _hasValidSelection = false;
    });
    widget.onLocationCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInputField(
          fillColor: widget.fillColor ?? 0xFFF0EFEF,
          label: widget.labels,
          controller: _controller,
          selectedColor: widget.selectedClr ?? 0xFF000000,
          onChanged: _onSearchChanged,
          prefixImg: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Images(
              imageStr: "assets/svg_images/locationImg.svg",
              height: 20,
              width: 20,
            ),
          ),
          hintText: widget.hintText ?? 'Search',
          textColor: 0xFF4D4D4D,
        ),
        if (_showSuggestions)
          Containers(
            margin: const EdgeInsets.only(top: 5),
            radius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            hexValue: 0xFFFFFFFF,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) =>
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                final String displayName = item['description'];
                return ListTile(
                  title: Texts(
                    text: displayName,
                    size: 14,
                    colorHexValue: 0xFF4D4D4D,
                  ),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    setState(() => _showSuggestions = false);
                    _getPlaceDetails(item['place_id'], displayName);
                  },
                );
              },
            ),
          ),
        if (_locationError != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              _locationError!,
              style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 13),
            ),
          ),
      ],
    );
  }
}