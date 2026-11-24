import 'package:material_ui/material_ui.dart';

import '../card_swiper.dart';

class SwiperControl extends SwiperPlugin {
  const SwiperControl({
    this.iconPrevious = Icons.arrow_back_ios,
    this.iconNext = Icons.arrow_forward_ios,
    this.color,
    this.disableColor,
    this.key,
    this.size = 30.0,
    this.padding = const EdgeInsets.all(5.0),
  });

  /// IconData for previous
  final IconData iconPrevious;

  /// IconData for next
  final IconData iconNext;

  /// Icon size
  final double size;

  /// Icon normal color, the theme's [ThemeData.primaryColor] by default.
  final Color? color;

  /// If set loop=false on Swiper, this color will be used when swiper reaches the boundary.
  /// The theme's [ThemeData.disabledColor] by default.
  final Color? disableColor;

  final EdgeInsetsGeometry padding;

  final Key? key;

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    final themeData = Theme.of(context);

    final activeColor = color ?? themeData.primaryColor;
    final disabledColor = disableColor ?? themeData.disabledColor;
    final Color prevColor;
    final Color nextColor;

    if (config.loop) {
      prevColor = nextColor = activeColor;
    } else {
      final hasNext = config.activeIndex < config.itemCount - 1;
      final hasPrev = config.activeIndex > 0;
      prevColor = hasPrev ? activeColor : disabledColor;
      nextColor = hasNext ? activeColor : disabledColor;
    }

    final isHorizontal = config.scrollDirection == Axis.horizontal;
    final quarterTurns = isHorizontal ? 0 : -3;

    return SizedBox.expand(
      child: Flex(
        key: key,
        direction: config.scrollDirection,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _SwiperControlButton(
            controller: config.controller,
            color: prevColor,
            iconData: iconPrevious,
            quarterTurns: quarterTurns,
            previous: true,
            size: size,
            padding: padding,
          ),
          _SwiperControlButton(
            controller: config.controller,
            color: nextColor,
            iconData: iconNext,
            quarterTurns: quarterTurns,
            previous: false,
            size: size,
            padding: padding,
          ),
        ],
      ),
    );
  }
}

class _SwiperControlButton extends StatelessWidget {
  const _SwiperControlButton({
    required this.controller,
    required this.color,
    required this.iconData,
    required this.quarterTurns,
    required this.previous,
    required this.size,
    required this.padding,
  });

  final SwiperController controller;
  final Color color;
  final IconData iconData;
  final int quarterTurns;
  final bool previous;
  final double size;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (previous) {
          await controller.previous(animation: true);
        } else {
          await controller.next(animation: true);
        }
      },
      child: Padding(
        padding: padding,
        child: RotatedBox(
          quarterTurns: quarterTurns,
          child: Icon(
            iconData,
            semanticLabel: previous ? 'Previous' : 'Next',
            size: size,
            color: color,
          ),
        ),
      ),
    );
  }
}
