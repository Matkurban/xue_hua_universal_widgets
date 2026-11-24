import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show InputDecoration;

/// Shared font-size fitting logic for [AutoSizeTextField] and [AutoSizeTextFormField].
class AutoSizeTextFieldFitter {
  const AutoSizeTextFieldFitter._();

  static const double defaultFontSize = 14.0;
  static final RegExp _wordWrapRegExp = RegExp(r'\s+');

  static void sanityCheck({
    required Key? key,
    required Key? textFieldKey,
    required List<double>? presetFontSizes,
    required double stepGranularity,
    required double minFontSize,
    required double maxFontSize,
  }) {
    assert(
      key == null || key != textFieldKey,
      'Key and textKey cannot be the same.',
    );

    if (presetFontSizes == null) {
      assert(
        stepGranularity >= 0.1,
        'StepGranularity has to be greater than or equal to 0.1. It is not a good idea to resize the font with a higher accuracy.',
      );
      assert(
        minFontSize >= 0,
        'MinFontSize has to be greater than or equal to 0.',
      );
      assert(maxFontSize > 0, 'MaxFontSize has to be greater than 0.');
      assert(
        minFontSize <= maxFontSize,
        'MinFontSize has to be smaller or equal than maxFontSize.',
      );
      assert(
        minFontSize / stepGranularity % 1 == 0,
        'MinFontSize has to be multiples of stepGranularity.',
      );
      if (maxFontSize != double.infinity) {
        assert(
          maxFontSize / stepGranularity % 1 == 0,
          'MaxFontSize has to be multiples of stepGranularity.',
        );
      }
    } else {
      assert(presetFontSizes.isNotEmpty, 'PresetFontSizes has to be nonempty.');
    }
  }

  static ({double fontSize, bool textFits, double textSpanWidth})
  calculateFontSize({
    required BuildContext context,
    required BoxConstraints constraints,
    required TextStyle style,
    required int? maxLines,
    required TextSpan? textSpan,
    required String data,
    required List<double>? presetFontSizes,
    required double minFontSize,
    required double maxFontSize,
    required double stepGranularity,
    required InputDecoration decoration,
    required bool wrapWords,
    required TextAlign textAlign,
    required TextDirection? textDirection,
    required Locale? locale,
    required StrutStyle? strutStyle,
    required double? minWidth,
  }) {
    final span = TextSpan(
      style: textSpan?.style ?? style,
      text: textSpan?.text ?? data,
      children: textSpan?.children,
      recognizer: textSpan?.recognizer,
    );

    final userScale = MediaQuery.textScalerOf(context).scale(1.0);
    final baseFontSize = style.fontSize ?? defaultFontSize;
    double textSpanWidth = minWidth ?? 0.0;

    int left;
    int right;

    final reversedPreset = presetFontSizes?.reversed.toList(growable: false);
    if (reversedPreset == null) {
      final num defaultClampedSize = baseFontSize.clamp(
        minFontSize,
        maxFontSize,
      );
      final defaultScale = defaultClampedSize * userScale / baseFontSize;
      final fitCheck = _checkTextFits(
        text: span,
        scale: defaultScale,
        maxLines: maxLines,
        constraints: constraints,
        decoration: decoration,
        wrapWords: wrapWords,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        strutStyle: strutStyle,
        minWidth: minWidth,
      );
      textSpanWidth = fitCheck.textSpanWidth;
      if (fitCheck.fits) {
        return (
          fontSize: defaultClampedSize * userScale,
          textFits: true,
          textSpanWidth: textSpanWidth,
        );
      }

      left = (minFontSize / stepGranularity).floor();
      right = (defaultClampedSize / stepGranularity).ceil();
    } else {
      left = 0;
      right = reversedPreset.length - 1;
    }

    var lastValueFits = false;
    while (left <= right) {
      final mid = left + ((right - left) >> 1);
      final double scale;
      if (reversedPreset == null) {
        scale = mid * userScale * stepGranularity / baseFontSize;
      } else {
        scale = reversedPreset[mid] * userScale / baseFontSize;
      }

      final fitCheck = _checkTextFits(
        text: span,
        scale: scale,
        maxLines: maxLines,
        constraints: constraints,
        decoration: decoration,
        wrapWords: wrapWords,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        strutStyle: strutStyle,
        minWidth: minWidth,
      );
      textSpanWidth = fitCheck.textSpanWidth;

      if (fitCheck.fits) {
        left = mid + 1;
        lastValueFits = true;
      } else {
        right = mid - 1;
        if (maxLines == null) left = right - 1;
      }
    }

    if (!lastValueFits) {
      right += 1;
    }

    final double fontSize;
    if (reversedPreset == null) {
      fontSize = right * userScale * stepGranularity;
    } else {
      final safeIndex = right.clamp(0, reversedPreset.length - 1);
      fontSize = reversedPreset[safeIndex] * userScale;
    }

    return (
      fontSize: fontSize,
      textFits: lastValueFits,
      textSpanWidth: textSpanWidth,
    );
  }

  static ({bool fits, double textSpanWidth}) _checkTextFits({
    required TextSpan text,
    required double scale,
    required int? maxLines,
    required BoxConstraints constraints,
    required InputDecoration decoration,
    required bool wrapWords,
    required TextAlign textAlign,
    required TextDirection? textDirection,
    required Locale? locale,
    required StrutStyle? strutStyle,
    required double? minWidth,
  }) {
    double constraintWidth = constraints.maxWidth;
    double constraintHeight = constraints.maxHeight;
    final contentPadding = decoration.contentPadding;
    if (contentPadding != null) {
      constraintWidth -= contentPadding.horizontal;
      constraintHeight -= contentPadding.vertical;
    }

    double textSpanWidth = minWidth ?? 0.0;

    if (!wrapWords) {
      final List<String?> words = text.toPlainText().split(_wordWrapRegExp);

      if (decoration.prefixText != null) {
        words.add(decoration.prefixText);
      }
      if (decoration.suffixText != null) {
        words.add(decoration.suffixText);
      }

      final wordWrapTp = TextPainter(
        text: TextSpan(style: text.style, text: words.join('\n')),
        textAlign: textAlign,
        textDirection: textDirection ?? TextDirection.ltr,
        textScaler: TextScaler.linear(scale),
        maxLines: words.length,
        locale: locale,
        strutStyle: strutStyle,
      );

      wordWrapTp.layout(maxWidth: constraintWidth);
      final double width = contentPadding != null
          ? wordWrapTp.width + contentPadding.horizontal
          : wordWrapTp.width;
      textSpanWidth = math.max(width, minWidth ?? 0.0);
      final bool exceeded =
          wordWrapTp.didExceedMaxLines ||
          wordWrapTp.width > constraints.maxWidth;
      wordWrapTp.dispose();

      if (exceeded) {
        return (fits: false, textSpanWidth: textSpanWidth);
      }
    }

    String word = text.toPlainText();

    if (word.isNotEmpty) {
      final textContents = text.text ?? '';
      word = textContents.replaceAll('\n', ' \n');
      if (textContents.isNotEmpty &&
          textContents.codeUnitAt(textContents.length - 1) != 10 &&
          textContents.codeUnitAt(textContents.length - 1) != 32) {
        word += ' ';
      }
    }

    word += decoration.prefixText ?? '';
    word += decoration.suffixText ?? '';

    final tp = TextPainter(
      text: TextSpan(
        text: word,
        recognizer: text.recognizer,
        children: text.children,
        semanticsLabel: text.semanticsLabel,
        style: text.style,
      ),
      textAlign: textAlign,
      textDirection: textDirection ?? TextDirection.ltr,
      textScaler: TextScaler.linear(scale),
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
    );

    tp.layout(maxWidth: constraintWidth);
    final double width = contentPadding != null
        ? tp.width + contentPadding.horizontal
        : tp.width;
    final double height = contentPadding != null
        ? tp.height + contentPadding.vertical
        : tp.height;
    tp.dispose();

    textSpanWidth = math.max(width, minWidth ?? 0.0);

    final bool fits = maxLines == null
        ? height < constraintHeight
        : width < constraintWidth;
    return (fits: fits, textSpanWidth: textSpanWidth);
  }
}
