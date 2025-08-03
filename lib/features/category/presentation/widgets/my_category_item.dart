import 'package:flutter/material.dart';
import 'package:expense_app/widgets/quanto_text.dart';

class MyCategoryItem extends StatelessWidget {
  final String icon;
  final String name;
  final Color borderColor;
  final VoidCallback? onTap;

  const MyCategoryItem({
    super.key,
    required this.icon,
    required this.name,
    required this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Center(
                child: QuantoText.h2(icon),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuantoText.bodyMedium(
                name,
                color: Colors.white,
              ),
            ),
            const Icon(
              Icons.drag_handle,
              color: Colors.white54,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
