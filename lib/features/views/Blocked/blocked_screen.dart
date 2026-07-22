import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/data/models/visited_blocked_model.dart';

import '../../../core/widgets/back_button.dart';
import '../../../data/viewmodels/blocked_viewmodel.dart';
import 'bottom_sheet.dart';
import 'list_tiles.dart';

const String kUploadImagesBaseUrl = "https://www.twoareone.love/uploads/";

class BlockedUserScreen extends StatefulWidget {
  const BlockedUserScreen({super.key});

  @override
  State<BlockedUserScreen> createState() => _BlockedUserScreenState();
}

class _BlockedUserScreenState extends State<BlockedUserScreen> {
  final _viewModel = BlockedUserViewModel();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onModelChanged);
    _viewModel.fetchUsers(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  void _onModelChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 150 &&
        !_viewModel.isLoading &&
        _viewModel.hasMore) {
      _viewModel.fetchUsers();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onModelChanged);
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _openMenu(VisitedBlockedUserModel user) {
    UserActionBottomSheet.show(
      context,
      sheetHeight: 220,
      children: [
        SheetMenuItem(
          icon: Images(imageStr: 'assets/svg_images/Favorite/viewProfile.svg'),
          label: "View Profile",
          onTap: () {
            Navigator.of(context).pop();
            // TODO: Navigator.pushNamed(context, Routes.profileDetail, arguments: {"item": user, "blocked": true});
          },
        ),
        SheetMenuItem(
          icon: Icon(Icons.block_outlined, size: 24,),
          label: "Remove",
          isLoading: _viewModel.actionLoadingId == user.profileId,
          onTap: () async {
            final ok = await _viewModel.unblockUser(user);
            if (ok && mounted) Navigator.of(context).pop();
          },
        ),
        SizedBox(height: 100,)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;
    final showInitialLoader = vm.isLoading && vm.users.isEmpty;
    final showEmpty = !vm.isLoading && vm.users.isEmpty;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SizedBox(height: 50),
            Row(children: [
              Back_Button(onTap: () => Navigator.pop(context)),
              const SizedBox(width: 64),
              Text('Blocked', style: GoogleFonts.poltawskiNowy(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black
              ),)
            ],),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: showInitialLoader
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: () => vm.fetchUsers(refresh: true),
                child: showEmpty
                    ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 220),
                    Center(
                      child: Text(
                        "You don't block anyone",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                )
                    : ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 20, bottom: 100),
                  itemCount: vm.users.length + (vm.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= vm.users.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final user = vm.users[index];
                    return UserTile(
                      user: user,
                      imageBaseUrl: kUploadImagesBaseUrl,
                      onMenuTap: () => _openMenu(user),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}