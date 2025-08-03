import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/quanto_text.dart';
import 'package:flutter/material.dart';

enum QuantoButtonType { primary, secondary, icon, premium }

class QuantoButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final QuantoButtonType buttonType;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final bool isDisabled;
  final bool isExpanded;

  const QuantoButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.buttonType = QuantoButtonType.primary,
    this.leftIcon,
    this.rightIcon,
    this.isDisabled = false,
    this.isExpanded = false,
  });

  @override
  State<QuantoButton> createState() => _QuantoButtonState();
}

class _QuantoButtonState extends State<QuantoButton> {
  bool _isPressed = false;

  // --- Style Getters ---

  Color _getBackgroundColor(BuildContext context) {
    if (widget.isDisabled) {
      return AppColors.bgFgSecondaryDark;
    }
    if (_isPressed) {
      switch (widget.buttonType) {
        case QuantoButtonType.primary:
          return AppColors.light50; // Slightly darker white for pressed
        case QuantoButtonType.secondary:
          return AppColors.bg15PressedDark;
        case QuantoButtonType.premium:
          return AppColors.premium.withOpacity(0.8);
        case QuantoButtonType.icon:
          return Colors.transparent;
      }
    }
    switch (widget.buttonType) {
      case QuantoButtonType.primary:
        return AppColors.bgInvertedPrimaryDark;
      case QuantoButtonType.secondary:
        return Colors.transparent;
      case QuantoButtonType.premium:
        return AppColors.premium;
      case QuantoButtonType.icon:
        return Colors.transparent;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (widget.isDisabled) {
      return AppColors.textTertiaryDark;
    }
    switch (widget.buttonType) {
      case QuantoButtonType.primary:
        return AppColors.textInvertedDark;
      case QuantoButtonType.secondary:
      case QuantoButtonType.icon:
        return AppColors.textPrimaryDark;
      case QuantoButtonType.premium:
        return AppColors.light0;
    }
  }

  BorderSide _getBorderSide(BuildContext context) {
    if (widget.isDisabled || widget.buttonType != QuantoButtonType.secondary) {
      return BorderSide.none;
    }
    return const BorderSide(color: AppColors.borderPrimaryDark);
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final textColor = _getTextColor(context);
    final borderSide = _getBorderSide(context);

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isDisabled) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (!widget.isDisabled) {
          setState(() => _isPressed = false);
          widget.onPressed?.call();
        }
      },
      onTapCancel: () {
        if (!widget.isDisabled) {
          setState(() => _isPressed = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.isExpanded ? double.infinity : null,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.fromBorderSide(borderSide),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leftIcon != null) ...[
                widget.leftIcon!,
                const SizedBox(width: 8),
              ],
              QuantoText.buttonLarge(
                widget.text,
                color: textColor,
              ),
              if (widget.rightIcon != null) ...[
                const SizedBox(width: 8),
                widget.rightIcon!,
              ],
            ],
          ),
        ),
      ),
    );
  }

}
