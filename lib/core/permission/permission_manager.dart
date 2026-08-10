import 'package:permission_handler/permission_handler.dart';
import 'package:two_are_one/core/permission/app_permissions.dart';

class PermissionManager {
  PermissionManager._();

  static final PermissionManager instance = PermissionManager._();

  final List<AppPermission> permissions = [
    AppPermission(permission: Permission.camera, required: true),
    AppPermission(permission: Permission.photos, required: true),
    AppPermission(permission: Permission.microphone, required: true),
  ];

  Future<bool> checkRequiredPermissions() async {
    for (final item in permissions) {
      if (!item.required) continue;

      final status = await item.permission.status;

      if (!status.isGranted) {
        return false;
      }
    }

    return true;
  }

  Future<bool> requestRequiredPermissions() async {
    for (final item in permissions) {
      if (!item.required) continue;

      final status = await item.permission.request();

      if (!status.isGranted) {
        return false;
      }
    }

    return true;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
