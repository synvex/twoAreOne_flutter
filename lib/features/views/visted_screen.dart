import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/data/models/visited_blocked_model.dart';
import '../../data/viewmodels/visited_view_model.dart';
import 'Blocked/bottom_sheet.dart';
import 'Blocked/list_tiles.dart';

const String kUploadImagesBaseUrl = "https://www.twoareone.love/uploads/";

class VisitedUserScreen extends StatefulWidget {
  const VisitedUserScreen({super.key});

  @override
  State<VisitedUserScreen> createState() => _VisitedUserScreenState();
}

class _VisitedUserScreenState extends State<VisitedUserScreen> {
  final _viewModel = VisitedUserViewModel();
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
      sheetHeight: 300,
      children: [
        SheetMenuItem(
          icon: Images(imageStr: 'assets/svg_images/Profile/view_profile.svg'),
          label: "View Profile",
          onTap: () {
            Navigator.of(context).pop();
            // TODO: Navigator.pushNamed(context, Routes.profileDetail, arguments: {"item": user});
          },
        ),
        SheetMenuItem(
          icon: Icon(Icons.block_outlined),
          label: "Block Profile",
          isLoading: _viewModel.actionLoadingId == user.profileId,
          onTap: () async {
            final ok = await _viewModel.blockUser(user);
            if (ok && mounted) Navigator.of(context).pop();
          },
        ),
        SheetMenuItem(
          icon: Icon(Icons.close),
          label: "Remove from Visited",
          isLoading: _viewModel.actionLoadingId == user.profileId,
          onTap: () async {
            final ok = await _viewModel.removeVisited(user);
            if (ok && mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;
    final showInitialLoader = vm.isLoading && vm.users.isEmpty;
    final showEmpty = !vm.isLoading && vm.users.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Visited Users", style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
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
                  "No visited users found.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          )
              : ListView.builder(
            controller: _scrollController,
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
    );
  }
}