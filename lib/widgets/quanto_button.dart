import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/quanto_text.dart';
import 'package:flutter/material.dart';

enum QuantoButtonType { primary, secondary, icon, premium }

enum QuantoButtonSize { large, medium, small }

class QuantoButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final QuantoButtonType buttonType;
  final QuantoButtonSize size;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final bool isDisabled;
  final bool isExpanded;

  const QuantoButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.buttonType = QuantoButtonType.primary,
    this.size = QuantoButtonSize.large,
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
        return AppColors.bgInvertedPrimaryDark; // Original white
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
        return AppColors.textInvertedDark; // Original dark text
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

  // --- Size Helper Methods ---

  double _getButtonWidth() {
    switch (widget.size) {
      case QuantoButtonSize.large:
        return 343;
      case QuantoButtonSize.medium:
        return 78;
      case QuantoButtonSize.small:
        return 53; // Original size to match reference image dimensions
    }
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case QuantoButtonSize.large:
        return 56;
      case QuantoButtonSize.medium:
        return 48;
      case QuantoButtonSize.small:
        return 38;
    }
  }

  double _getTotalHeight() {
    return _getButtonHeight() + 4;
  }

  Widget _getTextWidget(String text, Color color) {
    switch (widget.size) {
      case QuantoButtonSize.large:
        return QuantoText.buttonLarge(text, color: color);
      case QuantoButtonSize.medium:
        return QuantoText.buttonMedium(text, color: color);
      case QuantoButtonSize.small:
        return QuantoText.buttonSmall(text, color: color);
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final textColor = _getTextColor(context);
    final borderSide = _getBorderSide(context);

    BoxDecoration decoration;
    if (widget.buttonType == QuantoButtonType.primary && !widget.isDisabled) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEFF2F6), // #EFF2F6 at start
            Color(0xFFDFDFDF), // #DFDFDF at end
          ],
        ),
        border: Border.all(
          width: 2.0,
          color: Colors.transparent, // We'll use a gradient border overlay
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
            width: widget.isExpanded ? double.infinity : _getButtonWidth(),
            height: _getTotalHeight(),
            child: Stack(
              children: [
                // Shadow Layer: Sits behind the button.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _getButtonHeight(),
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
                    height: _getButtonHeight(),
                    decoration: decoration,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.leftIcon != null) ...[
                            widget.leftIcon!,
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _getTextWidget(widget.text, textColor),
                            ),
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
