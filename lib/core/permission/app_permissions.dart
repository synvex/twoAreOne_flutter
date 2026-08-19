import 'package:permission_handler/permission_handler.dart';

class AppPermission {
  final Permission permission;
  final bool required;

  const AppPermission({required this.permission, required this.required});
}
