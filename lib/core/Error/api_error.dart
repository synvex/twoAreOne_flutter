import 'package:dio/dio.dart';

class ApiError {
  final String title;
  final String message;
  final bool isNetworkError;
  final Response? response;
  final VoidCallback? retryAction;
  final String alertActionButton;

  ApiError({
    required this.title,
    required this.message,
    this.isNetworkError = false,
    this.response,
    this.retryAction,
    this.alertActionButton = 'Ok',
  });
}

typedef VoidCallback = void Function();