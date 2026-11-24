library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'carousel_controller.dart';
import 'carousel_options.dart';
import 'carousel_state.dart';
import 'utils.dart';

typedef ExtendedIndexedWidgetBuilder = Widget Function(
  BuildContext context,
  int index,
  int realIndex,
);

class CarouselSlider extends StatefulWidget {
  /// [CarouselOptions] to create a [CarouselState] with
  final CarouselOptions options;

  final bool? disableGesture;

  /// The widgets to be shown in the carousel of default constructor
  final List<Widget>? items;

  /// The widget item builder that will be used to build item on demand
  /// The third argument is the PageView's real index, can be used to cooperate
  /// with Hero.
  final ExtendedIndexedWidgetBuilder? itemBuilder;

  /// A [CarouselSliderController], used to control the carousel.
  final CarouselSliderControllerImpl _carouselController;

  final int? itemCount;

  CarouselSlider({
    required this.items,
    required this.options,
    this.disableGesture,
    CarouselSliderController? carouselController,
    super.key,
  }) : itemBuilder = null,
       itemCount = items != null ? items.length : 0,
       _carouselController = carouselController != null
           ? carouselController as CarouselSliderControllerImpl
           : CarouselSliderController() as CarouselSliderControllerImpl;

  /// The on demand item builder constructor
  CarouselSlider.builder({
    required this.itemCount,
    required this.itemBuilder,
    required this.options,
    this.disableGesture,
    CarouselSliderController? carouselController,
    super.key,
  }) : items = null,
       _carouselController = carouselController != null
           ? carouselController as CarouselSliderControllerImpl
           : CarouselSliderController() as CarouselSliderControllerImpl;

  @override
  State<CarouselSlider> createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider>
    with TickerProviderStateMixin {
  CarouselSliderControllerImpl get carouselController =>
      widget._carouselController;

  Timer? timer;

  CarouselOptions get options => widget.options;

  late final CarouselState carouselState;

  PageController? pageController;

  /// mode is related to why the page is being changed
  CarouselPageChangedReason mode = CarouselPageChangedReason.controller;

  void changeMode(CarouselPageChangedReason newMode) {
    mode = newMode;
  }

  @override
  void initState() {
    super.initState();
    carouselState = CarouselState(options, clearTimer, resumeTimer, changeMode);

    carouselState.itemCount = widget.itemCount;
    carouselController.state = carouselState;
    carouselState.initialPage = widget.options.initialPage;
    carouselState.realPage = options.enableInfiniteScroll
        ? carouselState.realPage + carouselState.initialPage
        : carouselState.initialPage;
    handleAutoPlay();

    pageController = PageController(
      viewportFraction: options.viewportFraction,
      initialPage: carouselState.realPage,
    );

    carouselState.pageController = pageController;
  }

  @override
  void didUpdateWidget(CarouselSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    carouselState.options = options;
    carouselState.itemCount = widget.itemCount;

    // A different controller may have been handed in: bind it to this state.
    if (!identical(oldWidget._carouselController, carouselController)) {
      carouselController.state = carouselState;
    }

    // Only a viewport change requires a new PageController. Recreating it on
    // every rebuild used to leak controllers and jump back to the first page.
    if (oldWidget.options.viewportFraction != options.viewportFraction) {
      final oldController = pageController;
      final currentPage = (oldController != null && oldController.hasClients)
          ? (oldController.page?.round() ?? carouselState.realPage)
          : carouselState.realPage;
      pageController = PageController(
        viewportFraction: options.viewportFraction,
        initialPage: currentPage,
      );
      carouselState.pageController = pageController;
      // Dispose after the PageView has detached from the old controller.
      if (oldController != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => oldController.dispose(),
        );
      }
    }

    if (oldWidget.options.autoPlayInterval != options.autoPlayInterval) {
      clearTimer();
    }
    handleAutoPlay();
  }

  Timer? getTimer() {
    if (!widget.options.autoPlay) return null;
    return Timer.periodic(widget.options.autoPlayInterval, (_) {
      if (!mounted) {
        clearTimer();
        return;
      }

      final route = ModalRoute.of(context);
      if (route?.isCurrent == false) {
        return;
      }

      final controller = carouselState.pageController;
      if (controller == null || !controller.hasClients) return;
      final currentPage = controller.page;
      if (currentPage == null) return;

      final CarouselPageChangedReason previousReason = mode;
      changeMode(CarouselPageChangedReason.timed);
      int nextPage = currentPage.round() + 1;
      final int itemCount = widget.itemCount ?? widget.items?.length ?? 0;

      if (nextPage >= itemCount &&
          widget.options.enableInfiniteScroll == false) {
        if (widget.options.pauseAutoPlayInFiniteScroll) {
          clearTimer();
          return;
        }
        nextPage = 0;
      }

      controller
          .animateToPage(
            nextPage,
            duration: widget.options.autoPlayAnimationDuration,
            curve: widget.options.autoPlayCurve,
          )
          .then((_) => changeMode(previousReason));
    });
  }

  void clearTimer() {
    timer?.cancel();
    timer = null;
  }

  void resumeTimer() {
    timer ??= getTimer();
  }

  void handleAutoPlay() {
    final bool autoPlayEnabled = widget.options.autoPlay;

    if (autoPlayEnabled && timer != null) return;

    clearTimer();
    if (autoPlayEnabled) {
      resumeTimer();
    }
  }

  void onStart() {
    changeMode(CarouselPageChangedReason.manual);
  }

  void onPanDown() {
    if (widget.options.pauseAutoPlayOnTouch) {
      clearTimer();
    }

    changeMode(CarouselPageChangedReason.manual);
  }

  void onPanUp() {
    if (widget.options.pauseAutoPlayOnTouch) {
      resumeTimer();
    }
  }

  @override
  void dispose() {
    clearTimer();
    pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final pageController = carouselState.pageController!;

    final pageView = PageView.builder(
      padEnds: options.padEnds,
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        overscroll: false,
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
        },
      ),
      clipBehavior: options.clipBehavior,
      physics: options.scrollPhysics,
      scrollDirection: options.scrollDirection,
      pageSnapping: options.pageSnapping,
      controller: pageController,
      reverse: options.reverse,
      itemCount: options.enableInfiniteScroll ? null : widget.itemCount,
      key: options.pageViewKey,
      onPageChanged: (int index) {
        final int currentPage = getRealIndex(
          index + carouselState.initialPage,
          carouselState.realPage,
          widget.itemCount,
        );
        widget.options.onPageChanged?.call(currentPage, mode);
      },
      itemBuilder: (BuildContext context, int idx) {
        final int index = getRealIndex(
          idx + carouselState.initialPage,
          carouselState.realPage,
          widget.itemCount,
        );

        final items = widget.items;
        final Widget item;
        if (items != null) {
          item = items.isNotEmpty ? items[index] : const SizedBox.shrink();
        } else {
          item = (widget.itemCount ?? 0) > 0
              ? widget.itemBuilder!(context, index, idx)
              : const SizedBox.shrink();
        }

        return AnimatedBuilder(
          animation: pageController,
          child: item,
          builder: (BuildContext context, Widget? child) {
            double distortionValue = 1.0;
            // if `enlargeCenterPage` is true, we must calculate the carousel
            // item's height to display the visual effect
            double itemOffset = 0;
            if (options.enlargeCenterPage == true) {
              // pageController.page can only be accessed after the first
              // build, so in the first build we calculate the itemOffset
              // manually
              final position = pageController.position;
              if (position.hasPixels && position.hasContentDimensions) {
                final page = pageController.page;
                if (page != null) {
                  itemOffset = page - idx;
                }
              } else {
                final BuildContext storageContext =
                    position.context.storageContext;
                final double? previousSavedPosition = PageStorage.maybeOf(
                  storageContext,
                )?.readState(storageContext) as double?;
                if (previousSavedPosition != null) {
                  itemOffset = previousSavedPosition - idx.toDouble();
                } else {
                  itemOffset =
                      carouselState.realPage.toDouble() - idx.toDouble();
                }
              }

              // Invert the item offset for right-to-left layouts.
              if (Directionality.of(context) == TextDirection.rtl) {
                itemOffset = -itemOffset;
              }

              final double enlargeFactor = options.enlargeFactor.clamp(
                0.0,
                1.0,
              );
              final double distortionRatio =
                  (1 - (itemOffset.abs() * enlargeFactor)).clamp(0.0, 1.0);
              distortionValue = Curves.easeOut.transform(distortionRatio);
            }

            final bool horizontal = options.scrollDirection == Axis.horizontal;
            final double itemHeight =
                options.height ?? screenWidth * (1 / options.aspectRatio);
            final double? width = horizontal
                ? null
                : distortionValue * screenWidth;
            final double? height = horizontal
                ? distortionValue * itemHeight
                : null;

            final Widget enlarged;
            switch (options.enlargeStrategy) {
              case CenterPageEnlargeStrategy.height:
                enlarged = SizedBox(width: width, height: height, child: child);
              case CenterPageEnlargeStrategy.zoom:
                final Alignment alignment;
                if (itemOffset > 0) {
                  alignment = horizontal
                      ? Alignment.centerRight
                      : Alignment.bottomCenter;
                } else {
                  alignment = horizontal
                      ? Alignment.centerLeft
                      : Alignment.topCenter;
                }
                enlarged = Transform.scale(
                  scale: distortionValue,
                  alignment: alignment,
                  child: child,
                );
              case CenterPageEnlargeStrategy.scale:
                enlarged = Transform.scale(
                  scale: distortionValue,
                  child: SizedBox(width: width, height: height, child: child),
                );
            }

            return options.disableCenter ? enlarged : Center(child: enlarged);
          },
        );
      },
    );

    final Widget content = NotificationListener<ScrollUpdateNotification>(
      onNotification: (ScrollUpdateNotification notification) {
        final onScrolled = widget.options.onScrolled;
        if (onScrolled != null) {
          onScrolled(carouselState.pageController?.page);
        }
        return false;
      },
      child: options.height != null
          ? SizedBox(height: options.height, child: pageView)
          : AspectRatio(aspectRatio: options.aspectRatio, child: pageView),
    );

    if (widget.disableGesture == true) {
      return content;
    }

    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        _MultipleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_MultipleGestureRecognizer>(
              () => _MultipleGestureRecognizer(),
              (_MultipleGestureRecognizer instance) {
                instance
                  ..onStart = (_) {
                    onStart();
                  }
                  ..onDown = (_) {
                    onPanDown();
                  }
                  ..onEnd = (_) {
                    onPanUp();
                  }
                  ..onCancel = onPanUp;
              },
            ),
      },
      child: content,
    );
  }
}

class _MultipleGestureRecognizer extends PanGestureRecognizer {}
