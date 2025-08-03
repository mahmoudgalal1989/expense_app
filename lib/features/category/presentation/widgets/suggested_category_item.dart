import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:expense_app/widgets/quanto_text.dart';

class SuggestedCategoryItem extends StatelessWidget {
  final String icon;
  final String name;
  final VoidCallback onAdd;

  const SuggestedCategoryItem({
    super.key,
    required this.icon,
    required this.name,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAdd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        child: Row(
          children: [
            QuantoText.h2(
              icon,
            ),
            const SizedBox(width: 16),
            QuantoText.bodyMedium(
              name,
              color: Colors.white,
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/svg/add_btn.svg',
              width: 28,
              height: 28,
            ),
          ],
        ),
      ),
    );
  }
}
