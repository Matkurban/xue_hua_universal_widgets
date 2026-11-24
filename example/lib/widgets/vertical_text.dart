import 'package:flutter/widgets.dart';

/// Displays text vertically, one character per line.
class VerticalText extends StatelessWidget {
  const VerticalText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: text
          .split('')
          .map((letter) => Text(letter, textAlign: TextAlign.center))
          .toList(growable: false),
    );
  }
}
