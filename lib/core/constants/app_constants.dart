/// Global constants ported from the RN `global/constants.js`.
class AppConstants {
  AppConstants._();
  static const String baseUrl = 'https://www.twoareone.love/';

  /// Ported 1:1 from RN `constants.js` -> `Upload_Images`.
  static const String uploadImagesUrl = 'https://www.twoareone.love/uploads/';

  static const int perPage = 10;
  static const int skeletonCount = 2;
}

class AppConstant {
  AppConstant._();

  // ---- NetworkContants.js ----
  static const String domainUrl = 'https://www.twoareone.love/api/';
  static const String apiUrl = 'https://www.twoareone.love/api/';
  static const String uploadImagesUrl = 'https://www.twoareone.love/uploads/';

  // socket url used by ChatSocketProvider.js
  static const String socketUrl = 'wss://mepower.us/ws';

  static const String googleApiKey = 'AIzaSyCqZ38paEOdX0SnqU0u6wBlEasNIwKRNe0';
}

class AppRegex {
  AppRegex._();

  static final RegExp email = RegExp(
    r"^[A-Z0-9a-z\._%+-]+@([A-Za-z0-9-]+\.)+[A-Za-z]{2,4}$",
    caseSensitive: false,
  );
  static final RegExp password = RegExp(
    r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&])[A-Za-z\d$@$!%*?&]{8,}$",
  );
  static final RegExp numberOnly = RegExp(r'^[0-9]+$');
  static final RegExp alphabetOnly = RegExp(r'^[A-Za-z]+$');
  static final RegExp name = RegExp(r"^([a-zA-Z\-_]+( |')?)+$");

  static bool validate(String text, RegExp regex) => regex.hasMatch(text);
  static bool isInvalid(String text, RegExp regex) => !regex.hasMatch(text);
}

/// Port of `weightOptions` / `heightOptions` / `genderOptions` / `ageOptions`.
class AppOptions {
  AppOptions._();
  static final List<Map<String, String>> weightOptions = List.generate(
    440 - 66 + 1,
    (i) => {'label': '${66 + i} lbs', 'value': '${66 + i}'},
  );
  static const List<Map<String, String>> heightOptions = [
    {'label': "4'10", 'value': '4.10'},
    {'label': "4'11", 'value': '4.11'},
    {'label': "5'0", 'value': '5.0'},
    {'label': "5'1", 'value': '5.1'},
    {'label': "5'2", 'value': '5.2'},
    {'label': "5'3", 'value': '5.3'},
    {'label': "5'4", 'value': '5.4'},
    {'label': "5'5", 'value': '5.5'},
    {'label': "5'6", 'value': '5.6'},
    {'label': "5'7", 'value': '5.7'},
    {'label': "5'8", 'value': '5.8'},
    {'label': "5'9", 'value': '5.9'},
    {'label': "5'10", 'value': '5.10'},
    {'label': "5'11", 'value': '5.11'},
    {'label': "6'0", 'value': '6.0'},
    {'label': "6'1", 'value': '6.1'},
    {'label': "6'2", 'value': '6.2'},
    {'label': "6'3", 'value': '6.3'},
    {'label': "6'4", 'value': '6.4'},
    {'label': "6'5", 'value': '6.5'},
    {'label': "6'6", 'value': '6.6'},
    {'label': "6'7", 'value': '6.7'},
    {'label': "6'8", 'value': '6.8'},
    {'label': "6'9", 'value': '6.9'},
    {'label': "6'10", 'value': '6.10'},
    {'label': "6'11", 'value': '6.11'},
    {'label': "7'0", 'value': '7.0'},
    {'label': "7'1", 'value': '7.1'},
    {'label': "7'2", 'value': '7.2'},
    {'label': "7'3", 'value': '7.3'},
    {'label': "7'4", 'value': '7.4'},
    {'label': "7'5", 'value': '7.5'},
    {'label': "7'6", 'value': '7.6'},
  ];
  static const List<Map<String, String>> genderOptions = [
    {'label': 'Male', 'value': 'male'},
    {'label': 'Female', 'value': 'female'},
  ];
  static final List<Map<String, String>> ageOptions = List.generate(
    88,
    (i) => {'label': '${i + 13}', 'value': '${i + 13}'},
  );
}
