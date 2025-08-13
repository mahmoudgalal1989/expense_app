import 'package:flutter/material.dart';

/// A custom text widget that uses Sora font with predefined styles.
class QuantoText extends StatelessWidget {
  /// The text to display
  final String text;

  /// The text style variant to use (e.g., 'Header/H1', 'Body/B1-R')
  final String styleVariant;

  /// The text color
  final Color? color;

  /// Text alignment
  final TextAlign? textAlign;

  /// Maximum number of lines
  final int? maxLines;

  /// Text overflow behavior
  final TextOverflow? overflow;

  /// Whether the text should be selectable
  final bool selectable;

  /// Text style definitions
  static TextStyle? getTextStyle(String styleVariant, Color? color) {
    final style = _textStyles[styleVariant];
    if (style == null) return null;
    return style.copyWith(fontFamily: 'Sora', color: color);
  }

  static const Map<String, TextStyle> _textStyles = {
    // Header Styles
    'Header/H1': TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w600, // SemiBold
      height: 32.0 / 25.0, // line-height: 32px
      letterSpacing: 0,
    ),
    'Header/H2': TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600, // SemiBold
      height: 28.0 / 20.0, // line-height: 28px
      letterSpacing: 0,
    ),
    'Header/H3': TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w600, // SemiBold
      height: 32.0 / 19.0, // line-height: 32px
      letterSpacing: 0,
    ),
    'Header/H4-M': TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600, // SemiBold
      height: 24.0 / 16.0, // line-height: 24px
      letterSpacing: 0,
    ),

    'Body/B1-L': TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w300, // Light
      height: 20.0 / 13.0, // line-height: 20px
      letterSpacing: 0.01, // 1% letter spacing
    ),
    // Body Styles - Regular
    'Body/B1-R': TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400, // Regular
      height: 20.0 / 13.0, // line-height: 20px
      letterSpacing: 0.1,
    ),
    'Body/B2-R': TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400, // Regular
      height: 20.0 / 14.0, // line-height: 20px
      letterSpacing: 0.1,
    ),
    'Body/B3-R': TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400, // Regular
      height: 16.0 / 12.0, // line-height: 16px
      letterSpacing: 0.1,
    ),

    // Body Styles - Medium
    'Body/B1-M': TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500, // Medium
      height: 24.0 / 16.0,
      letterSpacing: 0.1,
    ),
    'Body/B2-M': TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500, // Medium
      height: 20.0 / 14.0,
      letterSpacing: 0.1,
    ),

    // Body Styles - SemiBold
    'Body/B1-SB': TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600, // SemiBold
      height: 24.0 / 16.0,
      letterSpacing: 0.1,
    ),
    'Body/B2-SB': TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600, // SemiBold
      height: 20.0 / 14.0,
      letterSpacing: 0.1,
    ),

    'Display/D2': TextStyle(
      fontSize: 42,
      fontWeight: FontWeight.w700, // Bold
      height: 32.0 / 25.0,
      letterSpacing: 0.1,
    ),

    // CTA Styles
    'CTA/C1': TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600, // SemiBold
      height: 24.0 / 14.0, // line-height: 24px
      letterSpacing: 0,
    ),

    // Button Styles
    'Button/Large': TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600, // SemiBold
      height: 24.0 / 16.0,
      letterSpacing: 0.1,
    ),
    'Button/Medium': TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600, // SemiBold
      height: 20.0 / 14.0,
      letterSpacing: 0.1,
    ),
    'Button/Small': TextStyle(
      fontWeight: FontWeight.w600, // Reverted to 600 - better pixel match
      fontSize: 12,
      height: 18.0 / 12.0, // 18px line height as specified
      letterSpacing: 0.1,
    ),
  };

  const QuantoText(
    this.text, {
    super.key,
    this.styleVariant = 'Body/B1-R',
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = _textStyles[styleVariant] ?? _textStyles['Body/B1-R']!;
    final textStyle = defaultStyle.copyWith(
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );

    final textWidget = Text(
      text,
      style: textStyle.copyWith(fontFamily: 'Sora'),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );

    return selectable
        ? SelectableText(
            text,
            style: textStyle.copyWith(fontFamily: 'Sora'),
            textAlign: textAlign,
            maxLines: maxLines,
          )
        : textWidget;
  }

  // Convenience constructors for common styles

  // Headers
  factory QuantoText.h1(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    bool selectable = false,
  }) {
    return QuantoText(
      text,
      styleVariant: 'Header/H1',
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      selectable: selectable,
    );
  }

  factory QuantoText.h2(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    bool selectable = false,
  }) {
    return QuantoText(
      text,
      styleVariant: 'Header/H2',
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      selectable: selectable,
    );
  }

  factory QuantoText.h3(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    bool selectable = false,
  }) {
    return QuantoText(
      text,
      styleVariant: 'Header/H3',
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      selectable: selectable,
    );
  }

  // Body Regular
  factory QuantoText.bodyLarge(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    bool selectable = false,
  }) {
    return QuantoText(
      text,
      styleVariant: 'Body/B1-R',
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      selectable: selectable,
    );
  }

  factory QuantoText.bodyMedium(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    bool selectable = false,
  }) {
    return QuantoText(
      text,
      styleVariant: 'Body/B2-R',
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      selectable: selectable,
    );
  }

  factory QuantoText.bodySmall(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    bool selectable = false,
  }) {
    return QuantoText(
      text,
      styleVariant: 'Body/B3-R',
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      selectable: selectable,
    );
  }

  // Body Medium
  factory QuantoText.mediumLarge(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    bool selectable = false,
  }) {
    return QuantoText(
      text,
      styleVariant: 'Body/B1-M',
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      selectable: selectable,
    );
  }

  // Body SemiBold
  factory QuantoText.semiBoldLarge(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    bool selectable = false,
  }) {
    return QuantoText(
      text,
      styleVariant: 'Body/B1-SB',
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      selectable: selectable,
    );
  }

  // Buttons
  factory QuantoText.buttonLarge(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return QuantoText(
      text,
      styleVariant: 'Button/Large',
      color: color,
      textAlign: textAlign,
    );
  }

  factory QuantoText.buttonMedium(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return QuantoText(
      text,
      styleVariant: 'Button/Medium',
      color: color,
      textAlign: textAlign,
    );
  }

  factory QuantoText.buttonSmall(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return QuantoText(
      text,
      styleVariant: 'Button/Small',
      color: color,
      textAlign: textAlign,
    );
  }
}
