// lib/features/views/settings/widgets/editable_item.dart
//
// Flutter port of RN's `EditableItem` (a small helper component declared
// at the bottom of `SettingsScreen/index.js`). Used for the "Change
// Email" / "Change Password" / "Change Number" rows.

import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/texts.dart';

/// RN uses `ellipsizeMode='middle'` (native to RN's `<Text>`), which has no
/// built-in Flutter equivalent — Flutter's `TextOverflow` only clips at the
/// end. This keeps the start and end of a long value visible (useful for
/// emails/phone numbers) by trimming out the middle instead, matching RN's
/// visual behavior instead of just truncating the tail.
String _middleEllipsis(String text, {int maxChars = 22}) {
  if (text.length <= maxChars) return text;
  final keep = (maxChars - 1) ~/ 2;
  return '${text.substring(0, keep)}…${text.substring(text.length - keep)}';
}

class EditableItem extends StatelessWidget {
  final Widget icon;
  final String value;
  final String? subValue;
  final bool secure;
  final bool isLast;
  final VoidCallback onPressed;

  const EditableItem({
    super.key,
    required this.icon,
    required this.value,
    required this.onPressed,
    this.subValue,
    this.secure = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    // RN: `{secure ? '***************' : subValue}` with 4 leading spaces,
    // then RN's `ellipsizeMode='middle'` — see `_middleEllipsis` above.
    final rawSub = secure ? '***************' : (subValue ?? '');
    final displayed = '    ${_middleEllipsis(rawSub)}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0x33B9B9B9),
            width: isLast ? 0 : 1.5,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 10),
              Texts(
                text: value,
                  size: 12,
                  fontWeight: FontWeight.w500,
                  colorHexValue: 0xFF000000,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 32),
                  child: Text(
                    displayed,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: onPressed,
              icon: const Images(imageStr: 'assets/Settings/editIcon.svg'),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              splashRadius: 18,
            ),
          ),
        ],
      ),
    );
  }
}