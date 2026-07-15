class LocationData {
  final String address;
  final String country;
  final String state;
  final String city;
  final double? latitude;
  final double? longitude;
  LocationData({
    required this.address, required this.latitude, required this.longitude, required this.country, required this.state, required this.city});
}