// lib/features/views/settings/widgets/settings_item.dart
//
// Flutter port of RN's `SettingsItem` (a small helper component declared
// at the bottom of `SettingsScreen/index.js`). Used for the "Privacy
// Policy" / "Terms of Use" rows.

import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isLast;
  final VoidCallback onPressed;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0x33B9B9B9),
              width: isLast ? 0 : 1.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.black54, size: 22),
          ],
        ),
      ),
    );
  }
}