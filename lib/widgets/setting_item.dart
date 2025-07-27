import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final String? svgAsset;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final Color? subtitleColor;
  final Color? arrowColor;
  final bool showTrailingArrow;
  final Widget? trailing;

  const SettingItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.svgAsset,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.subtitleColor,
    this.arrowColor,
    this.showTrailingArrow = true,
    this.trailing,
  }) : assert(leading != null || svgAsset != null,
            'Either leading or svgAsset must be provided');

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
                if (leading != null) leading!,
                if (svgAsset != null)
                  SvgPicture.asset(
                    svgAsset!,
                    width: 36,
                    height: 36,
                  ),
                if (leading != null || svgAsset != null)
                  const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Sora',
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              Text(
                subtitle!,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: subtitleColor ?? const Color(0xFF868A8D),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Sora',
                  height: 20 / 13, // line-height: 20px
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (trailing != null)
              trailing!
            else if (onTap != null && showTrailingArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(red: 255, green: 255, blue: 255, alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }
}
