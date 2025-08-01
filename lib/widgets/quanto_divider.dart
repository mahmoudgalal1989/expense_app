import 'package:flutter/material.dart';
import 'package:expense_app/theme/app_colors.dart';

class QuantoDivider extends StatelessWidget {
  const QuantoDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.borderPrimaryDark,
      height: 0.5,
    );
  }
}
