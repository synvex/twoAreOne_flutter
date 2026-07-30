import 'package:flutter/material.dart';
import 'package:two_are_one/data/models/visited_blocked_model.dart';

class UserTile extends StatelessWidget {
  final VisitedBlockedUserModel user;
  final String imageBaseUrl;
  final VoidCallback onMenuTap;
  const UserTile({
    super.key,
    required this.user,
    required this.imageBaseUrl,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x99F0F0F0),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          ClipOval(
            child: user.hasImage
                ? Image.network(
                    "$imageBaseUrl${user.profilePicture}",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _InitialsAvatar(user: user),
                  )
                : _InitialsAvatar(user: user),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.fullName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          GestureDetector(
            onTap: onMenuTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Text(
                "⋯",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final VisitedBlockedUserModel user;
  const _InitialsAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFC89CAB),
        shape: BoxShape.circle,
      ),
      child: Text(
        user.initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
