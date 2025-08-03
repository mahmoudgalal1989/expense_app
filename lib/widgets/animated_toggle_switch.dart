import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/quanto_text.dart';
import 'package:flutter/material.dart';

class AnimatedToggleSwitch extends StatefulWidget {
  final List<String> values;
  final ValueChanged<int> onToggleCallback;
  final Color backgroundColor;
  final Color buttonColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  const AnimatedToggleSwitch({
    super.key,
    required this.values,
    required this.onToggleCallback,
    this.backgroundColor = AppColors.dark800,
    this.buttonColor = AppColors.dark600,
    this.selectedTextColor = AppColors.textPrimaryDark,
    this.unselectedTextColor = AppColors.textTertiaryDark,
  });

  @override
  State<AnimatedToggleSwitch> createState() => _AnimatedToggleSwitchState();
}

class _AnimatedToggleSwitchState extends State<AnimatedToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _fraction = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController)
          ..addListener(() {
            setState(() {
              _fraction = _animation.value;
            });
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the available size from parent constraints
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = 166.0;
        final height =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 40.0;
        final borderRadius = height / 2; // Always make it fully rounded
        final padding = height * 0.075; // Proportional padding (3% of height)

        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.all(padding),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: _fraction == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: (width - padding * 2) / 2,
                  height: height - padding * 2,
                  decoration: BoxDecoration(
                    color: widget.buttonColor,
                    borderRadius: BorderRadius.circular(borderRadius - padding),
                    // Add subtle shadow for depth
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  widget.values.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _animationController.animateTo(index.toDouble());
                        widget.onToggleCallback(index);
                      },
                      behavior:
                          HitTestBehavior.opaque, // Makes entire area clickable
                      child: Container(
                        height: double.infinity, // Fill the entire height
                        child: Center(
                          child: QuantoText.bodySmall(
                            widget.values[index],
                            color: _fraction.round() == index
                                ? widget.selectedTextColor
                                : widget.unselectedTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
