// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';

import '../card_swiper.dart';
import 'transformer_page_view/transformer_page_view.dart';

part 'custom_layout.dart';

typedef SwiperOnTap = void Function(int index);

typedef SwiperDataBuilder<T> = Widget Function(
  BuildContext context,
  T data,
  int index,
);

/// default auto play delay
const int kDefaultAutoplayDelayMs = 3000;

///  Default auto play transition duration (in millisecond)
const int kDefaultAutoplayTransactionDuration = 300;

const int kMaxValue = 20000;
const int kMiddleValue = 10000;

enum SwiperLayout { DEFAULT, STACK, TINDER, CUSTOM }

class Swiper extends StatefulWidget {
  const Swiper({
    this.itemBuilder,
    this.indicatorLayout = PageIndicatorLayout.none,

    ///
    this.transformer,
    required this.itemCount,
    this.autoplay = false,
    this.layout = SwiperLayout.DEFAULT,
    this.autoplayDelay = kDefaultAutoplayDelayMs,
    this.autoplayDisableOnInteraction = true,
    this.duration = kDefaultAutoplayTransactionDuration,
    this.onIndexChanged,
    this.index,
    this.onTap,
    this.control,
    this.loop = true,
    this.curve = Curves.ease,
    this.scrollDirection = Axis.horizontal,
    this.axisDirection = AxisDirection.left,
    this.pagination,
    this.plugins,
    this.physics,
    this.clipBehavior = Clip.hardEdge,
    super.key,
    this.controller,
    this.customLayoutOption,

    /// since v1.0.0
    this.containerHeight,
    this.containerWidth,
    this.viewportFraction = 1.0,
    this.itemHeight,
    this.itemWidth,
    this.outer = false,
    this.scale,
    this.fade,
    this.allowImplicitScrolling = false,
    this.allowScrolling = true,
  }) : assert(
         itemBuilder != null || transformer != null,
         'itemBuilder and transformItemBuilder must not be both null',
       ),
       assert(
         !loop ||
             ((loop &&
                     layout == SwiperLayout.DEFAULT &&
                     (indicatorLayout == PageIndicatorLayout.scale ||
                         indicatorLayout == PageIndicatorLayout.color ||
                         indicatorLayout == PageIndicatorLayout.none)) ||
                 (loop && layout != SwiperLayout.DEFAULT)),
         'Only support `PageIndicatorLayout.SCALE` and `PageIndicatorLayout.COLOR`when layout==SwiperLayout.DEFAULT in loop mode',
       );

  factory Swiper.children({
    required List<Widget> children,
    bool autoplay = false,
    PageTransformer? transformer,
    int autoplayDelay = kDefaultAutoplayDelayMs,
    bool autoplayDisableOnInteraction = true,
    int duration = kDefaultAutoplayTransactionDuration,
    ValueChanged<int>? onIndexChanged,
    int? index,
    SwiperOnTap? onTap,
    bool loop = true,
    Curve curve = Curves.ease,
    Axis scrollDirection = Axis.horizontal,
    AxisDirection axisDirection = AxisDirection.left,
    SwiperPlugin? pagination,
    SwiperPlugin? control,
    List<SwiperPlugin>? plugins,
    SwiperController? controller,
    Key? key,
    CustomLayoutOption? customLayoutOption,
    ScrollPhysics? physics,
    Clip clipBehavior = Clip.hardEdge,
    double? containerHeight,
    double? containerWidth,
    double viewportFraction = 1.0,
    double? itemHeight,
    double? itemWidth,
    bool outer = false,
    double scale = 1.0,
    double? fade,
    PageIndicatorLayout indicatorLayout = PageIndicatorLayout.none,
    SwiperLayout layout = SwiperLayout.DEFAULT,
    bool allowScrolling = true,
  }) => Swiper(
    fade: fade,
    indicatorLayout: indicatorLayout,
    layout: layout,
    transformer: transformer,
    customLayoutOption: customLayoutOption,
    containerHeight: containerHeight,
    containerWidth: containerWidth,
    viewportFraction: viewportFraction,
    itemHeight: itemHeight,
    itemWidth: itemWidth,
    outer: outer,
    scale: scale,
    autoplay: autoplay,
    autoplayDelay: autoplayDelay,
    autoplayDisableOnInteraction: autoplayDisableOnInteraction,
    duration: duration,
    onIndexChanged: onIndexChanged,
    index: index,
    onTap: onTap,
    curve: curve,
    scrollDirection: scrollDirection,
    axisDirection: axisDirection,
    pagination: pagination,
    control: control,
    controller: controller,
    loop: loop,
    plugins: plugins,
    physics: physics,
    clipBehavior: clipBehavior,
    key: key,
    itemBuilder: (context, index) {
      return children[index];
    },
    itemCount: children.length,
    allowScrolling: allowScrolling,
  );

  /// If set true , the pagination will display 'outer' of the 'content' container.
  final bool outer;

  /// Inner item height, this property is valid if layout=STACK or layout=TINDER or LAYOUT=CUSTOM,
  final double? itemHeight;

  /// Inner item width, this property is valid if layout=STACK or layout=TINDER or LAYOUT=CUSTOM,
  final double? itemWidth;

  // height of the inside container,this property is valid when outer=true,otherwise the inside container size is controlled by parent widget
  final double? containerHeight;

  // width of the inside container,this property is valid when outer=true,otherwise the inside container size is controlled by parent widget
  final double? containerWidth;

  /// Build item on index
  final IndexedWidgetBuilder? itemBuilder;

  /// Support transform like Android PageView did
  /// `itemBuilder` and `transformItemBuilder` must have one not null
  final PageTransformer? transformer;

  /// count of the display items
  final int itemCount;

  final ValueChanged<int>? onIndexChanged;

  ///auto play config
  final bool autoplay;

  ///Duration of the animation between transactions (in millisecond).
  final int autoplayDelay;

  ///disable auto play when interaction
  final bool autoplayDisableOnInteraction;

  ///auto play transition duration (in millisecond)
  final int duration;

  ///horizontal/vertical
  final Axis scrollDirection;

  ///left/right for Stack Layout
  final AxisDirection axisDirection;

  ///transition curve
  final Curve curve;

  /// Set to false to disable continuous loop mode.
  final bool loop;

  ///Index number of initial slide.
  ///If not set , the `Swiper` is 'uncontrolled', which means manage index by itself
  ///If set , the `Swiper` is 'controlled', which means the index is fully managed by parent widget.
  final int? index;

  ///Called when tap
  final SwiperOnTap? onTap;

  ///The swiper pagination plugin
  final SwiperPlugin? pagination;

  ///the swiper control button plugin
  final SwiperPlugin? control;

  ///other plugins, you can custom your own plugin
  final List<SwiperPlugin>? plugins;

  ///
  final SwiperController? controller;

  final ScrollPhysics? physics;

  final Clip clipBehavior;

  ///
  final double viewportFraction;

  /// Build in layouts
  final SwiperLayout layout;

  /// this value is valid when layout == SwiperLayout.CUSTOM
  final CustomLayoutOption? customLayoutOption;

  // This value is valid when viewportFraction is set and < 1.0
  final double? scale;

  // This value is valid when viewportFraction is set and < 1.0
  final double? fade;

  final PageIndicatorLayout indicatorLayout;

  final bool allowImplicitScrolling;

  final bool allowScrolling;

  static Swiper list<T>({
    PageTransformer? transformer,
    required List<T> list,
    CustomLayoutOption? customLayoutOption,
    required SwiperDataBuilder<T> builder,
    bool autoplay = false,
    int autoplayDelay = kDefaultAutoplayDelayMs,
    bool reverse = false,
    bool autoplayDisableOnInteraction = true,
    int duration = kDefaultAutoplayTransactionDuration,
    ValueChanged<int>? onIndexChanged,
    int? index,
    SwiperOnTap? onTap,
    bool loop = true,
    Curve curve = Curves.ease,
    Axis scrollDirection = Axis.horizontal,
    AxisDirection axisDirection = AxisDirection.left,
    SwiperPlugin? pagination,
    SwiperPlugin? control,
    List<SwiperPlugin>? plugins,
    SwiperController? controller,
    Key? key,
    ScrollPhysics? physics,
    Clip clipBehavior = Clip.hardEdge,
    double? containerHeight,
    double? containerWidth,
    double viewportFraction = 1.0,
    double? itemHeight,
    double? itemWidth,
    bool outer = false,
    double scale = 1.0,
    double? fade,
    PageIndicatorLayout indicatorLayout = PageIndicatorLayout.none,
    SwiperLayout layout = SwiperLayout.DEFAULT,
    bool allowScrolling = true,
  }) => Swiper(
    fade: fade,
    indicatorLayout: indicatorLayout,
    layout: layout,
    transformer: transformer,
    customLayoutOption: customLayoutOption,
    containerHeight: containerHeight,
    containerWidth: containerWidth,
    viewportFraction: viewportFraction,
    itemHeight: itemHeight,
    itemWidth: itemWidth,
    outer: outer,
    scale: scale,
    autoplay: autoplay,
    autoplayDelay: autoplayDelay,
    autoplayDisableOnInteraction: autoplayDisableOnInteraction,
    duration: duration,
    onIndexChanged: onIndexChanged,
    index: index,
    onTap: onTap,
    curve: curve,
    key: key,
    scrollDirection: scrollDirection,
    axisDirection: axisDirection,
    pagination: pagination,
    control: control,
    controller: controller,
    loop: loop,
    plugins: plugins,
    physics: physics,
    clipBehavior: clipBehavior,
    itemBuilder: (context, index) {
      return builder(context, list[index], index);
    },
    itemCount: list.length,
    allowScrolling: allowScrolling,
  );

  @override
  State<StatefulWidget> createState() => _SwiperState();
}

abstract class _SwiperTimerMixin extends State<Swiper> {
  Timer? _timer;
  late SwiperController _controller;

  /// Created only when the caller did not supply a controller; owned (and
  /// disposed) by this state.
  SwiperController? _internalController;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? (_internalController = SwiperController());
    _controller.addListener(_onController);
    if (widget.autoplay) {
      _controller.startAutoplay();
    } else {
      _controller.stopAutoplay();
    }
  }

  void _onController() {
    final event = _controller.event;
    if (event is AutoPlaySwiperControllerEvent) {
      if (event.autoplay) {
        if (_timer == null) {
          _startAutoplay();
        }
      } else {
        _stopAutoplay();
      }
    } else if (event is IndexControllerEventBase) {
      if (event.needToResetTimer && (widget.autoplay || _timer != null)) {
        _startAutoplay();
      }
    }
  }

  @override
  void didUpdateWidget(Swiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final nextController =
          widget.controller ?? (_internalController ??= SwiperController());
      if (!identical(nextController, _controller)) {
        _controller.removeListener(_onController);
        _controller = nextController;
        _controller.addListener(_onController);
      }
      final stale = _internalController;
      if (widget.controller != null && stale != null) {
        _internalController = null;
        // Children still reference it during this frame.
        WidgetsBinding.instance.addPostFrameCallback((_) => stale.dispose());
      }
    }
    if (widget.autoplay != oldWidget.autoplay) {
      if (widget.autoplay) {
        _controller.startAutoplay();
      } else {
        _controller.stopAutoplay();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onController);
    _stopAutoplay();
    _internalController?.dispose();
    super.dispose();
  }

  void _startAutoplay() {
    _stopAutoplay();
    _timer = Timer.periodic(
      Duration(milliseconds: widget.autoplayDelay),
      _onTimer,
    );
  }

  Future<void> _onTimer(Timer timer) async {
    return _controller.next(animation: true, needToResetTimer: false);
  }

  void _stopAutoplay() {
    _timer?.cancel();
    _timer = null;
  }
}

class _SwiperState extends _SwiperTimerMixin {
  late int _activeIndex;

  TransformerPageController? _pageController;

  bool get _isPageViewLayout => widget.layout == SwiperLayout.DEFAULT;

  bool _getReverse(Swiper widget) => widget.transformer?.reverse ?? false;

  TransformerPageController _createPageController() {
    return TransformerPageController(
      initialPage: widget.index ?? widget.controller?.index ?? 0,
      loop: widget.loop,
      itemCount: widget.itemCount,
      reverse: _getReverse(widget),
      viewportFraction: widget.viewportFraction,
    );
  }

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.index ?? widget.controller?.index ?? 0;
    if (_isPageViewLayout) {
      _pageController = _createPageController();
    }
  }

  @override
  void didUpdateWidget(Swiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stale = _pageController;
    if (_isPageViewLayout) {
      if (stale == null ||
          (widget.index != oldWidget.index ||
              widget.loop != oldWidget.loop ||
              widget.itemCount != oldWidget.itemCount ||
              widget.viewportFraction != oldWidget.viewportFraction ||
              _getReverse(widget) != _getReverse(oldWidget))) {
        _pageController = _createPageController();
        if (stale != null) {
          // Give child widgets a chance to `removeListener` first.
          WidgetsBinding.instance.addPostFrameCallback((_) => stale.dispose());
        }
      }
    } else if (stale != null) {
      _pageController = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => stale.dispose());
    }
    if (widget.index != null && widget.index != _activeIndex) {
      _activeIndex = widget.index!;
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _onIndexChanged(int index) {
    setState(() {
      _activeIndex = index;
    });

    final event = _controller.event;
    if ((event is MoveIndexControllerEvent) && (event.newIndex != index)) {
      return;
    }
    widget.onIndexChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    final rawItemBuilder = widget.itemBuilder;
    final IndexedWidgetBuilder? itemBuilder =
        (onTap == null || rawItemBuilder == null)
        ? rawItemBuilder
        : (BuildContext context, int index) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(index),
            child: rawItemBuilder(context, index),
          );

    final Widget swiper;
    switch (widget.layout) {
      case SwiperLayout.STACK:
        swiper = _StackSwiper(
          loop: widget.loop,
          itemWidth: widget.itemWidth,
          itemHeight: widget.itemHeight,
          itemCount: widget.itemCount,
          itemBuilder: itemBuilder,
          index: _activeIndex,
          curve: widget.curve,
          duration: widget.duration,
          onIndexChanged: _onIndexChanged,
          controller: _controller,
          scrollDirection: widget.scrollDirection,
          axisDirection: widget.axisDirection,
        );
      case SwiperLayout.DEFAULT:
        final transformer = (widget.scale != null || widget.fade != null)
            ? ScaleAndFadeTransformer(scale: widget.scale, fade: widget.fade)
            : widget.transformer;
        final pageView = TransformerPageView(
          pageController: _pageController,
          loop: widget.loop,
          itemCount: widget.itemCount,
          itemBuilder: itemBuilder,
          transformer: transformer,
          viewportFraction: widget.viewportFraction,
          index: _activeIndex,
          duration: Duration(milliseconds: widget.duration),
          scrollDirection: widget.scrollDirection,
          onPageChanged: _onIndexChanged,
          curve: widget.curve,
          physics: widget.physics,
          clipBehavior: widget.clipBehavior,
          controller: _controller,
          allowImplicitScrolling: widget.allowImplicitScrolling,
        );
        swiper = (widget.autoplayDisableOnInteraction && widget.autoplay)
            ? NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollStartNotification) {
                    if (notification.dragDetails != null) {
                      //by human
                      if (_timer != null) _stopAutoplay();
                    }
                  } else if (notification is ScrollEndNotification) {
                    if (_timer == null) _startAutoplay();
                  }
                  return false;
                },
                child: pageView,
              )
            : pageView;
      case SwiperLayout.TINDER:
        swiper = _TinderSwiper(
          loop: widget.loop,
          itemWidth: widget.itemWidth,
          itemHeight: widget.itemHeight,
          itemCount: widget.itemCount,
          itemBuilder: itemBuilder,
          index: _activeIndex,
          curve: widget.curve,
          duration: widget.duration,
          onIndexChanged: _onIndexChanged,
          controller: _controller,
          scrollDirection: widget.scrollDirection,
        );
      case SwiperLayout.CUSTOM:
        swiper = _CustomLayoutSwiper(
          loop: widget.loop,
          option: widget.customLayoutOption!,
          itemWidth: widget.itemWidth,
          itemHeight: widget.itemHeight,
          itemCount: widget.itemCount,
          itemBuilder: itemBuilder,
          index: _activeIndex,
          curve: widget.curve,
          duration: widget.duration,
          onIndexChanged: _onIndexChanged,
          controller: _controller,
          scrollDirection: widget.scrollDirection,
          axisDirection: widget.axisDirection,
          allowScrolling: widget.allowScrolling,
        );
    }

    final control = widget.control;
    final plugins = widget.plugins;
    final pagination = widget.pagination;
    if (control == null && plugins == null && pagination == null) {
      return swiper;
    }

    final config = SwiperPluginConfig(
      outer: widget.outer,
      itemCount: widget.itemCount,
      layout: widget.layout,
      indicatorLayout: widget.indicatorLayout,
      pageController: _pageController,
      activeIndex: _activeIndex,
      scrollDirection: widget.scrollDirection,
      axisDirection: widget.axisDirection,
      controller: _controller,
      loop: widget.loop,
    );

    final stackChildren = <Widget>[
      swiper,
      if (control != null) control.build(context, config),
      if (plugins != null)
        for (final plugin in plugins) plugin.build(context, config),
    ];

    if (pagination != null) {
      if (widget.outer) {
        final content = stackChildren.length == 1
            ? swiper
            : Stack(children: stackChildren);
        //Only support bottom yet!
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.containerHeight != null || widget.containerWidth != null)
              content
            else
              Expanded(child: content),
            Align(
              alignment: Alignment.center,
              child: pagination.build(context, config),
            ),
          ],
        );
      }
      stackChildren.add(pagination.build(context, config));
    }

    return stackChildren.length == 1 ? swiper : Stack(children: stackChildren);
  }
}

abstract class _SubSwiper extends StatefulWidget {
  const _SubSwiper({
    required this.loop,
    this.itemHeight,
    this.itemWidth,
    this.duration,
    required this.curve,
    this.itemBuilder,
    required this.controller,
    this.index,
    required this.itemCount,
    this.scrollDirection = Axis.horizontal,
    this.axisDirection = AxisDirection.left,
    this.onIndexChanged,
    this.allowScrolling = true,
  });

  final IndexedWidgetBuilder? itemBuilder;
  final int itemCount;
  final int? index;
  final ValueChanged<int>? onIndexChanged;
  final SwiperController controller;
  final int? duration;
  final Curve curve;
  final double? itemWidth;
  final double? itemHeight;
  final bool loop;
  final Axis? scrollDirection;
  final AxisDirection? axisDirection;
  final bool allowScrolling;

  @override
  State<StatefulWidget> createState();

  int getCorrectIndex(int indexNeedsFix) {
    if (itemCount == 0) return 0;
    var value = indexNeedsFix % itemCount;
    if (value < 0) {
      value += itemCount;
    }
    return value;
  }
}

class _TinderSwiper extends _SubSwiper {
  const _TinderSwiper({
    required super.curve,
    super.duration,
    required super.controller,
    super.onIndexChanged,
    super.itemHeight,
    super.itemWidth,
    super.itemBuilder,
    super.index,
    required super.loop,
    required super.itemCount,
    super.scrollDirection = null,
  }) : assert(itemWidth != null && itemHeight != null);

  @override
  State<StatefulWidget> createState() {
    return _TinderState();
  }
}

class _StackSwiper extends _SubSwiper {
  const _StackSwiper({
    required super.curve,
    super.duration,
    required super.controller,
    super.onIndexChanged,
    super.itemHeight,
    super.itemWidth,
    super.itemBuilder,
    super.index,
    required super.loop,
    required super.itemCount,
    super.scrollDirection = null,
    super.axisDirection = null,
  });

  @override
  State<StatefulWidget> createState() => _StackViewState();
}

class _TinderState extends _CustomLayoutStateBase<_TinderSwiper> {
  late List<double> scales;
  late List<double> offsetsX;
  late List<double> offsetsY;
  late List<double> opacity;
  late List<double> rotates;

  @override
  void didUpdateWidget(_TinderSwiper oldWidget) {
    _updateValues();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void afterRender() {
    super.afterRender();

    _startIndex = -3;
    _animationCount = 5;
    opacity = [0.0, 0.9, 0.9, 1.0, 0.0, 0.0];
    scales = [0.80, 0.80, 0.85, 0.90, 1.0, 1.0, 1.0];
    rotates = [0.0, 0.0, 0.0, 0.0, 20.0, 25.0];
    _updateValues();
  }

  void _updateValues() {
    if (widget.scrollDirection == Axis.horizontal) {
      offsetsX = [0.0, 0.0, 0.0, 0.0, _swiperWidth, _swiperWidth];
      offsetsY = [0.0, 0.0, -5.0, -10.0, -15.0, -20.0];
    } else {
      offsetsX = [0.0, 0.0, 5.0, 10.0, 15.0, 20.0];
      offsetsY = [0.0, 0.0, 0.0, 0.0, _swiperHeight, _swiperHeight];
    }
  }

  @override
  _ItemTransform _itemTransform(int i, double animationValue) {
    return _MatrixItemTransform(
      opacity: _getValue(opacity, animationValue, i),
      angle: _getValue(rotates, animationValue, i) / 180.0,
      offset: Offset(
        _getValue(offsetsX, animationValue, i),
        _getValue(offsetsY, animationValue, i),
      ),
      scale: _getValue(scales, animationValue, i),
      alignment: widget.scrollDirection == Axis.horizontal
          ? Alignment.bottomCenter
          : Alignment.centerLeft,
    );
  }
}

class _StackViewState extends _CustomLayoutStateBase<_StackSwiper> {
  late List<double> scales;
  late List<double> offsets;
  late List<double> opacity;

  void _updateValues() {
    if (widget.scrollDirection == Axis.horizontal) {
      final space = (_swiperWidth - widget.itemWidth!) / 2;
      offsets = widget.axisDirection == AxisDirection.left
          ? [-space, -space / 3 * 2, -space / 3, 0.0, _swiperWidth]
          : [_swiperWidth, 0.0, -space / 3, -space / 3 * 2, -space];
    } else {
      final space = (_swiperHeight - widget.itemHeight!) / 2;
      offsets = [-space, -space / 3 * 2, -space / 3, 0.0, _swiperHeight];
    }
  }

  @override
  void didUpdateWidget(_StackSwiper oldWidget) {
    _updateValues();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void afterRender() {
    super.afterRender();
    final isRightSide = widget.axisDirection == AxisDirection.right;

    //length of the values array below
    _animationCount = 5;

    //Array below this line, '0' index is 1.0, which is the first item show in swiper.
    _startIndex = isRightSide ? -1 : -3;
    scales = isRightSide
        ? [1.0, 1.0, 0.9, 0.8, 0.7]
        : [0.7, 0.8, 0.9, 1.0, 1.0];
    opacity = isRightSide
        ? [1.0, 1.0, 1.0, 0.5, 0.0]
        : [0.0, 0.5, 1.0, 1.0, 1.0];

    _updateValues();
  }

  @override
  _ItemTransform _itemTransform(int i, double animationValue) {
    final f = _getValue(offsets, animationValue, i);
    final horizontal = widget.scrollDirection == Axis.horizontal;
    final towardsLeft = widget.axisDirection == AxisDirection.left;

    return _MatrixItemTransform(
      opacity: _getValue(opacity, animationValue, i),
      offset: horizontal
          ? (towardsLeft ? Offset(f, 0.0) : Offset(-f, 0.0))
          : Offset(0.0, f),
      scale: _getValue(scales, animationValue, i),
      alignment: horizontal
          ? (towardsLeft ? Alignment.centerLeft : Alignment.centerRight)
          : Alignment.topCenter,
    );
  }
}

class ScaleAndFadeTransformer extends PageTransformer {
  ScaleAndFadeTransformer({this._fade = 0.3, this._scale = 0.8});

  final double? _scale;
  final double? _fade;

  @override
  Widget transform(Widget child, TransformInfo info) {
    final position = info.position;
    var c = child;
    if (_scale != null) {
      final scaleFactor = (1 - position!.abs()) * (1 - _scale);
      final scale = _scale + scaleFactor;

      c = Transform.scale(scale: scale, child: c);
    }

    if (_fade != null) {
      final fadeFactor = (1 - position!.abs()) * (1 - _fade);
      final opacity = _fade + fadeFactor;
      c = Opacity(opacity: opacity, child: c);
    }

    return c;
  }
}
