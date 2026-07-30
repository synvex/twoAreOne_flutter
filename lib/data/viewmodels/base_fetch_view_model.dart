import 'package:flutter/foundation.dart';
import '../../core/Error/api_error.dart';

enum ViewState { loading, success, error }

abstract class BaseFetchViewModel<T> extends ChangeNotifier {
  ViewState _state = ViewState.loading;
  ViewState get state => _state;

  T? _data;
  T? get data => _data;

  ApiError? _error;
  ApiError? get error => _error;

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get hasData => _state == ViewState.success;

  Future<void> load() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      final result = await fetchData();
      _data = result;
      _state = ViewState.success;
    } on ApiError catch (apiError) {
      _error = apiError;
      _state = ViewState.error;
    } catch (e) {
      _error = ApiError(title: 'Error', message: e.toString());
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<T> fetchData();
}