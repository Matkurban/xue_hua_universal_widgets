part of 'swiper.dart';

sealed class _ItemTransform {
  const _ItemTransform();
}

final class _MatrixItemTransform extends _ItemTransform {
  const _MatrixItemTransform({
    required this.opacity,
    required this.offset,
    required this.scale,
    required this.alignment,
    this.angle,
  });

  final double opacity;
  final double? angle;
  final Offset offset;
  final double scale;
  final Alignment alignment;
}

final class _BuildersItemTransform extends _ItemTransform {
  const _BuildersItemTransform({
    required this.builders,
    required this.index,
    required this.animationValue,
  });

  final List<TransformBuilder<dynamic>> builders;
  final int index;
  final double animationValue;
}

class _CustomLayoutSwiperItem extends StatelessWidget {
  const _CustomLayoutSwiperItem({
    required this.itemKeyValue,
    required this.transform,
    required this.itemWidth,
    required this.itemHeight,
    required this.child,
  });

  final int itemKeyValue;
  final _ItemTransform transform;
  final double? itemWidth;
  final double? itemHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sizedChild = SizedBox(
      width: itemWidth ?? double.infinity,
      height: itemHeight ?? double.infinity,
      child: child,
    );

    switch (transform) {
      case _MatrixItemTransform(
        :final opacity,
        :final angle,
        :final offset,
        :final scale,
        :final alignment,
      ):
        Widget content = Transform.translate(
          key: ValueKey<int>(itemKeyValue),
          offset: offset,
          child: Transform.scale(
            scale: scale,
            alignment: alignment,
            child: sizedChild,
          ),
        );
        if (angle != null) {
          content = Transform.rotate(angle: angle, child: content);
        }
        return Opacity(opacity: opacity.clamp(0.0, 1.0), child: content);
      case _BuildersItemTransform(
        :final builders,
        :final index,
        :final animationValue,
      ):
        Widget content = sizedChild;
        for (var i = builders.length - 1; i >= 0; --i) {
          content = builders[i].build(index, animationValue, content);
        }
        return content;
    }
  }
}

abstract class _CustomLayoutStateBase<T extends _SubSwiper> extends State<T>
    with SingleTickerProviderStateMixin {
  double _swiperWidth = 0;
  double _swiperHeight = 0;
  late Animation<double> _animation;
  late AnimationController _animationController;
  SwiperController get _controller => widget.controller;
  bool get _allowScrolling => widget.allowScrolling;
  late int _startIndex;
  int? _animationCount;
  int _currentIndex = 0;

  @override
  void initState() {
    _currentIndex = widget.index ?? 0;
    if (widget.itemWidth == null) {
      throw Exception(
        '==============\n\nwidget.itemWidth must not be null when use stack layout.\n========\n',
      );
    }

    _createAnimationController();
    _controller.addListener(_onController);
    super.initState();
  }

  void _createAnimationController() {
    _animationController = AnimationController(vsync: this, value: 0.5);
    final tween = Tween(begin: 0.0, end: 1.0);
    _animation = tween.animate(_animationController);
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_getSize);
    super.didChangeDependencies();
  }

  void _getSize(Duration _) {
    if (!mounted) return;
    afterRender();
  }

  @mustCallSuper
  void afterRender() {
    final renderObject = context.findRenderObject();
    if (renderObject == null) return;
    final size = renderObject.paintBounds.size;
    _swiperWidth = size.width;
    _swiperHeight = size.height;
    setState(() {});
  }

  @override
  void didUpdateWidget(T oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
    }

    if (widget.loop != oldWidget.loop) {
      if (!widget.loop && widget.itemCount > 0) {
        _currentIndex = _ensureIndex(_currentIndex);
      }
    }

    if (widget.axisDirection != oldWidget.axisDirection) {
      afterRender();
    }

    super.didUpdateWidget(oldWidget);
  }

  int _ensureIndex(int index) {
    if (widget.itemCount <= 0) return 0;
    var res = index % widget.itemCount;
    if (res < 0) {
      res += widget.itemCount;
    }
    return res;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _animationController.dispose();
    super.dispose();
  }

  _ItemTransform _itemTransform(int i, double animationValue);

  @override
  Widget build(BuildContext context) {
    final animationCount = _animationCount;
    if (animationCount == null) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? _) {
        final list = <Widget>[];
        final animationValue = _animation.value;
        final itemCount = widget.itemCount;
        final itemBuilder = widget.itemBuilder;

        for (var i = 0; i < animationCount && itemCount > 0; ++i) {
          final itemIndex = _currentIndex + i + _startIndex;
          if (!widget.loop && (itemIndex >= itemCount || itemIndex < 0)) {
            continue;
          }

          var realIndex = itemIndex % itemCount;
          if (realIndex < 0) {
            realIndex += itemCount;
          }

          final itemWidget = _CustomLayoutSwiperItem(
            itemKeyValue: _currentIndex + i,
            transform: _itemTransform(i, animationValue),
            itemWidth: widget.itemWidth,
            itemHeight: widget.itemHeight,
            child: itemBuilder != null
                ? itemBuilder(context, realIndex)
                : const SizedBox.shrink(),
          );

          if (widget.axisDirection == AxisDirection.right) {
            list.insert(0, itemWidget);
          } else {
            list.add(itemWidget);
          }
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: _allowScrolling ? _onPanStart : null,
          onPanEnd: _allowScrolling ? _onPanEnd : null,
          onPanUpdate: _allowScrolling ? _onPanUpdate : null,
          child: ClipRect(
            child: Center(child: Stack(children: list)),
          ),
        );
      },
    );
  }

  double _currentValue = 0.5;
  double _currentPos = 0.0;

  bool _lockScroll = false;

  Future<void> _move(double position, {int? nextIndex}) async {
    if (_lockScroll) return;
    try {
      _lockScroll = true;
      await _animationController.animateTo(
        position,
        duration: Duration(
          milliseconds: widget.duration ?? kDefaultAutoplayTransactionDuration,
        ),
        curve: widget.curve,
      );
      if (nextIndex != null) {
        widget.onIndexChanged?.call(widget.getCorrectIndex(nextIndex));
      }
    } catch (e, st) {
      log('error animating _animationController', error: e, stackTrace: st);
    } finally {
      if (nextIndex != null) {
        try {
          _animationController.value = 0.5;
        } catch (e, st) {
          log(
            'error setting _animationController.value',
            error: e,
            stackTrace: st,
          );
        }
        _currentIndex = nextIndex;
      }
      _lockScroll = false;
    }
  }

  int _getProperNewIndex(int newIndex) {
    var res = newIndex;
    if (!widget.loop && newIndex >= widget.itemCount - 1) {
      res = widget.itemCount - 1;
    } else if (!widget.loop && newIndex < 0) {
      res = 0;
    }
    return res;
  }

  Future<void> _onController() async {
    final controller = widget.controller;
    final event = controller.event;
    if (event is StepBasedIndexControllerEvent) {
      final newIndex = event.calcNextIndex(
        currentIndex: _currentIndex,
        itemCount: widget.itemCount,
        loop: widget.loop,
        reverse: false,
      );
      if (_currentIndex == newIndex) {
        event.complete();
        return;
      }
      await _move(event.targetPosition, nextIndex: newIndex);
      event.complete();
    } else if (event is MoveIndexControllerEvent) {
      final newIndex = _getProperNewIndex(event.newIndex);
      if (_currentIndex == newIndex) {
        event.complete();
        return;
      }
      await _move(event.targetPosition, nextIndex: newIndex);
      event.complete();
    }
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (_lockScroll) return;

    final velocity = widget.scrollDirection == Axis.horizontal
        ? details.velocity.pixelsPerSecond.dx
        : details.velocity.pixelsPerSecond.dy;

    if (_animationController.value >= 0.75 || velocity > 500.0) {
      if (_currentIndex <= 0 && !widget.loop) {
        return _move(0.5);
      }
      return _move(1.0, nextIndex: _currentIndex - 1);
    } else if (_animationController.value < 0.25 || velocity < -500.0) {
      if (_currentIndex >= widget.itemCount - 1 && !widget.loop) {
        return _move(0.5);
      }
      return _move(0.0, nextIndex: _currentIndex + 1);
    } else {
      return _move(0.5);
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_lockScroll) return;
    _currentValue = _animationController.value;
    _currentPos = widget.scrollDirection == Axis.horizontal
        ? details.globalPosition.dx
        : details.globalPosition.dy;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_lockScroll || _swiperWidth <= 0) return;
    var value =
        _currentValue +
        ((widget.scrollDirection == Axis.horizontal
                    ? details.globalPosition.dx
                    : details.globalPosition.dy) -
                _currentPos) /
            _swiperWidth /
            2;
    // no loop ?
    if (!widget.loop) {
      if (widget.itemCount == 1) {
        value = 0.5;
      }
      if (_currentIndex >= widget.itemCount - 1) {
        if (value < 0.5) {
          value = 0.5;
        }
      } else if (_currentIndex <= 0) {
        if (value > 0.5) {
          value = 0.5;
        }
      }
    }

    _animationController.value = value;
  }
}

double _getValue(List<double> values, double animationValue, int index) {
  var s = values[index];
  if (animationValue >= 0.5) {
    if (index < values.length - 1) {
      s = s + (values[index + 1] - s) * (animationValue - 0.5) * 2.0;
    }
  } else {
    if (index != 0) {
      s = s - (s - values[index - 1]) * (0.5 - animationValue) * 2.0;
    }
  }
  return s;
}

Offset _getOffsetValue(List<Offset> values, double animationValue, int index) {
  final s = values[index];
  var dx = s.dx;
  var dy = s.dy;
  if (animationValue >= 0.5) {
    if (index < values.length - 1) {
      dx = dx + (values[index + 1].dx - dx) * (animationValue - 0.5) * 2.0;
      dy = dy + (values[index + 1].dy - dy) * (animationValue - 0.5) * 2.0;
    }
  } else {
    if (index != 0) {
      dx = dx - (dx - values[index - 1].dx) * (0.5 - animationValue) * 2.0;
      dy = dy - (dy - values[index - 1].dy) * (0.5 - animationValue) * 2.0;
    }
  }
  return Offset(dx, dy);
}

abstract class TransformBuilder<T> {
  TransformBuilder({required this.values});

  final List<T> values;

  Widget build(int i, double animationValue, Widget widget);
}

class ScaleTransformBuilder extends TransformBuilder<double> {
  ScaleTransformBuilder({
    required super.values,
    this.alignment = Alignment.center,
  });

  final Alignment alignment;

  @override
  Widget build(int i, double animationValue, Widget widget) {
    final s = _getValue(values, animationValue, i);
    return Transform.scale(scale: s, alignment: alignment, child: widget);
  }
}

class OpacityTransformBuilder extends TransformBuilder<double> {
  OpacityTransformBuilder({required super.values});

  @override
  Widget build(int i, double animationValue, Widget widget) {
    final v = _getValue(values, animationValue, i).clamp(0.0, 1.0);
    return Opacity(opacity: v, child: widget);
  }
}

class RotateTransformBuilder extends TransformBuilder<double> {
  RotateTransformBuilder({required super.values});

  @override
  Widget build(int i, double animationValue, Widget widget) {
    final v = _getValue(values, animationValue, i);
    return Transform.rotate(angle: v, child: widget);
  }
}

class TranslateTransformBuilder extends TransformBuilder<Offset> {
  TranslateTransformBuilder({required super.values});

  @override
  Widget build(int i, double animationValue, Widget widget) {
    final s = _getOffsetValue(values, animationValue, i);
    return Transform.translate(offset: s, child: widget);
  }
}

class CustomLayoutOption {
  CustomLayoutOption({this.stateCount, required this.startIndex});

  final List<TransformBuilder<dynamic>> builders = [];
  final int startIndex;
  final int? stateCount;

  void addOpacity(List<double> values) {
    builders.add(OpacityTransformBuilder(values: values));
  }

  void addTranslate(List<Offset> values) {
    builders.add(TranslateTransformBuilder(values: values));
  }

  void addScale(List<double> values, Alignment alignment) {
    builders.add(ScaleTransformBuilder(values: values, alignment: alignment));
  }

  void addRotate(List<double> values) {
    builders.add(RotateTransformBuilder(values: values));
  }
}

class _CustomLayoutSwiper extends _SubSwiper {
  const _CustomLayoutSwiper({
    required this.option,
    super.itemWidth,
    required super.loop,
    super.itemHeight,
    super.onIndexChanged,
    super.itemBuilder,
    required super.curve,
    super.duration,
    super.index,
    required super.itemCount,
    super.scrollDirection = null,
    required super.controller,
    super.axisDirection = null,
    super.allowScrolling,
  });

  final CustomLayoutOption option;

  @override
  State<StatefulWidget> createState() {
    return _CustomLayoutState();
  }
}

class _CustomLayoutState extends _CustomLayoutStateBase<_CustomLayoutSwiper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startIndex = widget.option.startIndex;
    _animationCount = widget.option.stateCount;
  }

  @override
  void didUpdateWidget(_CustomLayoutSwiper oldWidget) {
    _startIndex = widget.option.startIndex;
    _animationCount = widget.option.stateCount;
    super.didUpdateWidget(oldWidget);
  }

  @override
  _ItemTransform _itemTransform(int index, double animationValue) {
    return _BuildersItemTransform(
      builders: widget.option.builders,
      index: index,
      animationValue: animationValue,
    );
  }
}
