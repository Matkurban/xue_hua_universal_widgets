import 'package:material_ui/material_ui.dart';

import 'vertical_text.dart';

/// Splits the available width with a draggable vertical divider so the left
/// [child] can be resized interactively.
class DraggableDivider extends StatefulWidget {
  const DraggableDivider({super.key, required this.child});

  final Widget child;

  @override
  State<DraggableDivider> createState() => _DraggableDividerState();
}

class _DraggableDividerState extends State<DraggableDivider> {
  static const double _dividerWidth = 10;
  static const double _minWidth = 20;

  double? _leftWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxLeftWidth = screenWidth - _minWidth - _dividerWidth;
    if (_leftWidth == null || _leftWidth! > maxLeftWidth) {
      _leftWidth = maxLeftWidth.clamp(_minWidth, screenWidth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final leftWidth =
        _leftWidth ??
        (screenWidth - _minWidth - _dividerWidth).clamp(_minWidth, screenWidth);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: leftWidth, child: widget.child),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            final newWidth = leftWidth + details.delta.dx;
            if (newWidth >= _minWidth &&
                (screenWidth - newWidth - _dividerWidth) >= _minWidth) {
              setState(() {
                _leftWidth = newWidth;
              });
            }
          },
          child: Container(color: Colors.grey, width: _dividerWidth),
        ),
        const Expanded(child: Center(child: VerticalText('Drag Test'))),
      ],
    );
  }
}
