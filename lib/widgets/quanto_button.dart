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
          return AppColors.premium.withAlpha(204); // 0.8 * 255 = 204
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
    final textColor = _getTextColor(context);
    final borderSide = _getBorderSide(context);

    BoxDecoration decoration;

    if (widget.buttonType == QuantoButtonType.primary) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.isDisabled
              ? [AppColors.bgFgSecondaryDark, AppColors.bgFgSecondaryDark]
              : _isPressed
                  ? AppColors.buttonGradient // Inset/Pressed gradient
                  : AppColors.buttonGradient, // Default gradient
        ),
      );
    } else {
      final backgroundColor = _getBackgroundColor(context);
      decoration = BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(borderSide),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.isDisabled ? null : widget.onPressed,
        onTapDown:
            widget.isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: widget.isDisabled
            ? null
            : (_) => setState(() => _isPressed = false),
        onTapCancel:
            widget.isDisabled ? null : () => setState(() => _isPressed = false),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent, // Redundant for safety
            splashColor: Colors.transparent, // Redundant for safety
          ),
          child: SizedBox(
            width: widget.isExpanded ? double.infinity : null,
            height: 60, // Total height for button (56) + shadow (4)
            child: Stack(
              children: [
                // Shadow Layer: Sits behind the button.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 56, // Height of the shadow slot
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDisabled
                          ? Colors.transparent
                          : AppColors.bgInvertedSecondaryDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                // Button Face Layer: Animates on top of the shadow.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  top: _isPressed || widget.isDisabled ? 3.0 : 0.0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 56,
                    decoration: decoration,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
