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
  final Function(LocationData) onLocationSelected;

  const LocationSelectorField({
    super.key,
    this.labels,
    required this.onLocationSelected,
    this.fillColor,
  });

  @override
  State<LocationSelectorField> createState() => _LocationSelectorFieldState();
}

class _LocationSelectorFieldState extends State<LocationSelectorField> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _showSuggestions = false;
  bool _isLoading = false;

  static const String _apiKey = "AIzaSyCqZ38paEOdX0SnqU0u6wBlEasNIwKRNe0";

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      // _suggestions = _allLocations
      //     .where(
      //         (loc) => loc.toLowerCase().contains(
      //             query.toLowerCase()))
      //     .toList();
      // _showSuggestions = _suggestions.isNotEmpty;
    });
    //
    try {
      // Free OpenStreetMap API (Nominatim)
      // final url = Uri.parse(
      //     "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5"
      // );

      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=${Uri.encodeComponent(query)}"
        "&key=$_apiKey"
        "&types=geocode",
      );
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'TwoAreOne_App', // Required by OSM policy
        },
      );

      if (response.statusCode == 200) {
        // final List data = json.decode(response.body);
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _suggestions = data['predictions'];
          _showSuggestions = _suggestions.isNotEmpty;
        });
      } else {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
    } catch (e) {
      debugPrint("Location Search Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getPlaceDetails(String placeId, String displayName) async {
    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId"
        "&fields=geometry,address_components"
        "&key=$_apiKey",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry']['location'];
          final components = result['address_components'] as List;

          // Extract address parts from components
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

          final locationData = LocationData(
            address: displayName,
            country: country,
            state: state,
            city: city,
            latitude: geometry['lat'],
            longitude: geometry['lng'],
          );

          widget.onLocationSelected(locationData);
        }
      }
    } catch (e) {
      debugPrint("Place Details Error: $e");
    }
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
          onChanged: _onSearchChanged,
          prefixImg: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Images(
              imageStr: "assets/svg_images/locationImg.svg",

              height: 20,
              width: 20,
            ),
          ),
          hintText: 'Search',
        ),
        // 3. Suggestions List
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
                // final String displayName = item['display_name'];
                final String displayName = item['description'];
                final address = item['address'] ?? {};
                return ListTile(
                  title: Texts(
                    // text: _suggestions[index],
                    text: displayName,
                    size: 14,
                    colorHexValue: 0xFF4D4D4D,
                  ),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _controller.text = displayName;
                    // final addressMap = item['address'] ?? {};
                    // final selectedAddress = _suggestions[index];
                    // _controller.text = selectedAddress;
                    // final locationData = LocationData(
                    // //  address: selectedAddress,
                    //   address: displayName,
                    //   // country: selectedAddress.split(',').last.trim(),
                    //   country: addressMap['country'] ?? '',
                    //   state: addressMap['state'] ?? '',
                    //   // city: selectedAddress.split(',').first.trim(),
                    //   city: addressMap['city'] ?? addressMap['town'] ?? "",
                    //   latitude: double.tryParse(item['lat']?? '0') ?? 0.0,
                    //   longitude: double.tryParse(item['lon']?? '0')?? 0.0,
                    // );
                    _controller.text = displayName;
                    // Pass the structured live record back to SignUpPage state
                    // widget.onLocationSelected(locationData);
                    setState(() {
                      _showSuggestions = false;
                    });
                    _getPlaceDetails(item['place_id'], displayName);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
