import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String svgAsset;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final Color? subtitleColor;
  final Color? arrowColor;

  const SettingItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.svgAsset,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.subtitleColor,
    this.arrowColor,
  });

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
                SvgPicture.asset(
                  svgAsset,
                  width: 36,
                  height: 36,
                ),
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
            const Spacer(),
            if (subtitle != null)
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
            SvgPicture.asset(
              'assets/svg/Chevron Right.svg',
              width: 24,
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
