import 'package:flutter/material.dart';
import 'package:two_are_one/data/models/notification_model.dart';
import 'package:two_are_one/data/services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool isLoading = false;

  List<NotificationModel> notificationList = [];

  Future<void> fetchNotifications() async {
    try {
      isLoading = true;
      notifyListeners();

      notificationList = await _notificationService.fetchNotifications();
      print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^66");
      print(notificationList);
    } catch (e) {
      debugPrint("Notification Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
