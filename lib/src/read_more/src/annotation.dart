import 'package:flutter/widgets.dart';

/// Defines a customizable pattern within text, such as hashtags, URLs, or mentions.
///
/// Enables applying custom styles and interactions to matched patterns,
/// enhancing text interactivity. Utilize this class to highlight specific text
/// segments or to add clickable functionality, facilitating navigation or other actions.
@immutable
class Annotation {
  const Annotation({required this.regExp, required this.spanBuilder});

  final RegExp regExp;
  final TextSpan Function({required String text, required TextStyle textStyle})
  spanBuilder;
}
