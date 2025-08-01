import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/quanto_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? prefixText;
  final String? flagIcon;
  final Widget? leading;
  final String? svgAsset;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final Color? prefixTextColor;
  final Color? subtitleColor;
  final Color? arrowColor;
  final bool showTrailingArrow;
  final Widget? trailing;

  const SettingItem({
    super.key,
    required this.title,
    this.subtitle,
    this.prefixText,
    this.flagIcon,
    this.leading,
    this.svgAsset,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.prefixTextColor,
    this.subtitleColor,
    this.arrowColor,
    this.showTrailingArrow = true,
    this.trailing,
  }) : assert(leading != null || svgAsset != null || flagIcon != null,
            'Either leading, svgAsset, or flagIcon must be provided');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (flagIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      flagIcon!,
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                else if (leading != null)
                  leading!
                else if (svgAsset != null)
                  SvgPicture.asset(
                    svgAsset!,
                    width: 36,
                    height: 36,
                  ),
                if ((leading != null || svgAsset != null || flagIcon != null) &&
                    title.isNotEmpty)
                  const SizedBox(width: 12),
                if (prefixText != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      prefixText!,
                      style: TextStyle(
                        color: prefixTextColor ?? const Color(0xFF868A8D),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ),
                if (title.isNotEmpty)
                  QuantoText(
                    title,
                    styleVariant: 'Body/B1-R',
                    color: textColor ?? Colors.white,
                  ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null)
                  QuantoText(
                    subtitle!,
                    styleVariant: 'Body/B1-R',
                    color: AppColors.textSecondaryDark,
                    textAlign: TextAlign.right,
                  ),
                if (trailing != null)
                  trailing!
                else if (onTap != null && showTrailingArrow)
                  SvgPicture.asset(
                    "assets/svg/Chevron Right.svg",
                    width: 24,
                    height: 24,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
