import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_are_one/core/back_button.dart';
import 'package:two_are_one/data/services/interested_services.dart';
import 'package:two_are_one/ui/views/favourites/widgets/favourite_tab_bar.dart';
import 'package:two_are_one/ui/views/favourites/widgets/user_list_tile.dart';
import '../../../core/app_colors.dart';
import '../../../core/profile_bottom_sheet.dart';
import '../../../core/routes/routes.dart';
import '../../../data/models/favourite_model.dart';
import '../../../data/models/interested_model.dart';
import '../../../data/services/favourite_services.dart';
import '../../viewmodels/favourite_view_model.dart';
import '../../viewmodels/interested_view_model.dart';
import '../Interested/widgets/interested_action_sheet.dart';
import '../Interested/widgets/skeleton_user_card.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/favourite_view_model.dart';
import '../Interested/widgets/user_list_tile.dart';
// Reuse the same tile component
//
// class FavouritesScreen extends StatelessWidget {
//   const FavouritesScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => FavouriteViewModel()..init(),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Column(
//             children: [
//               _buildHeader(),
//               _buildTabs(),
//               Expanded(child: _buildList()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTabs() {
//     return Consumer<FavouriteViewModel>(
//       builder: (context, vm, _) => Row(
//         children: [
//           _tabButton(context, vm, "Favourite You", FavouriteTab.favouriteYou),
//           _tabButton(context, vm, "Your Favourite", FavouriteTab.yourFavourite),
//         ],
//       ),
//     );
//   }
//
//   Widget _tabButton(BuildContext context, FavouriteViewModel vm, String label, FavouriteTab tab) {
//     bool active = vm.activeTab == tab;
//     return Expanded(
//       child: InkWell(
//         onTap: () => vm.switchTab(tab),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             border: Border(bottom: BorderSide(color: active ? Colors.black : Colors.transparent, width: 2)),
//           ),
//           child: Text(label, textAlign: TextAlign.center,
//               style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal)),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildList() {
//     return Consumer<FavouriteViewModel>(
//       builder: (context, vm, _) {
//         if (vm.isLoading && vm.currentItems.isEmpty) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (vm.currentItems.isEmpty) {
//           return const Center(child: Text("No favorites found"));
//         }
//         return ListView.builder(
//           itemCount: vm.currentItems.length,
//           itemBuilder: (context, index) {
//             final user = vm.currentItems[index];
//             return UserListTile(
//               user: user, // Ensure UserListTile handles FavouriteUserModel
//               displayName: user.fullName,
//               onMenuPressed: () { /* Open sheet */ },
//               resolvedImageUrl: '', initials: '',
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildHeader() {
//     return const Padding(
//       padding: EdgeInsets.all(20),
//       child: Text("Favorites", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//     );
//   }
// }
enum FavouriteTab { favouriteYou, yourFavourite }

class FavouriteViewModel extends ChangeNotifier {
  final FavouriteServices _repository = FavouriteServices();

  FavouriteTab _activeTab = FavouriteTab.favouriteYou;
  FavouriteTab get activeTab => _activeTab;

  final Map<FavouriteTab, List<FavouriteUserModel>> _items = {
    FavouriteTab.favouriteYou: [],
    FavouriteTab.yourFavourite: [],
  };

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<FavouriteUserModel> get currentItems => _items[_activeTab]!;

  Future<void> init() => getData();

  Future<void> getData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = _activeTab == FavouriteTab.favouriteYou
          ? await _repository.fetchFavouriteYou()
          : await _repository.fetchYourFavourite(page: 1, perPage: 10);
      _items[_activeTab] = data;
    } catch (e) {
      _errorMessage = "Failed to load favorites";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void switchTab(FavouriteTab tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    if (_items[tab]!.isEmpty) getData();
    notifyListeners();
  }

// Add methods for remove/block similar to InterestedViewModel...
}
// class FavouritesUserScreen extends StatelessWidget {
//   const FavouritesUserScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<FavouriteViewModel>(
//       create: (_) => FavouriteViewModel(repository: FavouriteServices())..init(),
//       child: const _FavouriteUserView(),
//     );
//   }
// }
//
// class _FavouriteUserView extends StatefulWidget {
//   const _FavouriteUserView();
//
//   @override
//   State<_FavouriteUserView> createState() => _FavouriteUserViewState();
// }
//
// class _FavouriteUserViewState extends State<_FavouriteUserView> {
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     // RN: `onEndReached={loadMore} onEndReachedThreshold={0.2}`
//     _scrollController.addListener(() {
//       final position = _scrollController.position;
//       if (position.pixels >= position.maxScrollExtent * 0.8) {
//         context.read<FavouriteViewModel>().loadMore();
//       }
//     });
//   }
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//   void _showErrorIfAny(BuildContext context, FavouriteViewModel vm) {
//     if (vm.errorMessage != null) {
//       final message = vm.errorMessage!;
//       vm.consumeError();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ScaffoldMessenger.of(context)
//           ..hideCurrentSnackBar()
//           ..showSnackBar(SnackBar(content: Text(message)));
//       });
//     }
//   }
//
//   void _openActionSheet(BuildContext context, FavouriteUserModel item) {
//     final vm = context.read<FavouriteViewModel>();
//     vm.selectItem(item);
//     AppBottomSheet.show(
//       context,
//       sheetHeight: 350,
//       builder: (ctx) => ChangeNotifierProvider.value(
//         value: vm,
//         child: InterestedActionSheet(
//           onViewProfile: () {
//             Navigator.of(ctx).pop();
//             vm.closeBottomSheet();
//             Navigator.of(context).pushNamed(AppRoutes.profileDetail, arguments: item);
//           },
//         ),
//       ),
//     ).whenComplete(() => vm.closeBottomSheet());
//   }  @override
//   Widget build(BuildContext context) {
//     return Consumer<FavouriteViewModel>(
//       builder: (context, vm, _) {
//         _showErrorIfAny(context, vm);
//
//         return Scaffold(
//           backgroundColor: AppColors.white,
//           body: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 40),
//               child: Column(
//                 children: [
//                   Row(children: [
//                     Back_Button(onTap: (){
//                       Navigator.pop(context);
//                     }),
//                     const SizedBox(width: 64,),
//                     Text('Favourite', style: TextStyle(fontSize: 24,
//                         fontFamily: 'Poltawski Nowy',fontWeight: FontWeight.w500),)
//                   ],),
//                   const SizedBox(height: 30,),
//                   FavouriteTabBar(
//                     activeTab: vm.activeTab,
//                     onTabSelected: (tab) => vm.switchTab(tab),
//                   ),
//
//                   Expanded(child: _buildBody(context, vm)),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildBody(BuildContext context, FavouriteViewModel vm) {
//     // RN: full-screen loader only on the very first page load.
//     if (vm.showInitialLoader) {
//       return const Padding(
//         padding: EdgeInsets.only(top: 20),
//         child: Center(child: CircularProgressIndicator(color: AppColors.black)),
//       );
//     }
//
//     return RefreshIndicator(
//       color: AppColors.black,
//       onRefresh: vm.refresh,
//       child: vm.showEmptyState
//           ? _buildEmptyState(vm)
//           : ListView.builder(
//         controller: _scrollController,
//         padding: const EdgeInsets.only(top: 20),
//         physics: const AlwaysScrollableScrollPhysics(),
//         itemCount: vm.currentItems.length + (vm.showSkeletonFooter ? 1 : 0),
//         itemBuilder: (context, index) {
//           if (index >= vm.currentItems.length) {
//             return const SkeletonFooterList();
//           }
//           final item = vm.currentItems[index];
//           return FavUserListTile(
//             user: item,
//             resolvedImageUrl: vm.resolveImageUrl(item.profilePicture),
//             initials: vm.initialsFor(item.fullName),
//             displayName: vm.capitalize(item.fullName),
//             onMenuPressed: () => _openActionSheet(context, item),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(FavouriteViewModel vm) {
//     return ListView(
//       // Wrapped in a scrollable so RefreshIndicator still works when empty,
//       // same as RN's `ListEmptyComponent` inside a refreshable `FlatList`.
//       physics: const AlwaysScrollableScrollPhysics(),
//       children: [
//         SizedBox(
//           height: MediaQuery.of(context).size.height * 0.5,
//           child: Center(
//             child: Text(
//               vm.emptyMessage,
//               style: const TextStyle(fontSize: 16, color: AppColors.black),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>(
      BuildContext context, {
        required WidgetBuilder builder,
        double sheetHeight = 420,
      }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        return SizedBox(
          width: width,
          height: sheetHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Curved white background (ported SVG path).
              CustomPaint(
                size: Size(width, sheetHeight),
                painter: CurveBackgroundPainter(),
              ),
              // Drag handle ("curve" style in RN).
              Positioned(
                top: 0,
                child: Container(
                  width: 55,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              // Content.
              Positioned(
                top: 48,
                left: 0,
                right: 0,
                bottom: 24,
                child: builder(context),
              ),
            ],
          ),
        );
      },
    );
  }
}