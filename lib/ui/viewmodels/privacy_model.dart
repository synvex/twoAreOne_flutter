

import '../../data/end_points.dart';
import '../../data/models/t_and_c_model.dart';
import '../../data/services/Api_Helper/api_manager.dart';
import 'base_fetch_view_model.dart';

/// Owns all Privacy Policy screen state/business logic. The View only reads
/// `viewModel.state` / `viewModel.data` and calls `viewModel.load()` —
/// it never talks to ApiManager directly.
class PrivacyPolicyViewModel extends BaseFetchViewModel<PageContentModel> {
  @override
  Future<PageContentModel> fetchData() async {
    final response = await Api_Manager.instance.fetch(ApiEndpoints.privacyPolicy);
    final json = response.data['data'] as Map<String, dynamic>;
    return PageContentModel.fromJson(json);
  }
}