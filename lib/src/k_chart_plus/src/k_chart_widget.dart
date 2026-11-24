import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../k_chart_plus.dart';
import 'renderer/base_dimension.dart';

class TimeFormat {
  static const List<String> yearMonthDay = [yyyy, '-', mm, '-', dd];
  static const List<String> yearMonthDayWithHour = [
    yyyy,
    '-',
    mm,
    '-',
    dd,
    ' ',
    HH,
    ':',
    nn,
  ];
}

typedef WidgetDetailBuilder = Widget Function(KLineEntity entity);

class KChartWidget extends StatefulWidget {
  final List<KLineEntity>? datas;
  final List<MainIndicator> mainIndicators;

  /// warning only using MA, BOLL, SAR
  final bool volHidden;
  final List<SecondaryIndicator> secondaryIndicators;

  /// SecondaryState { MACD, KDJ, RSI, WR, CCI }
  final bool isLine;
  final bool hideGrid;
  final bool showNowPrice;
  final List<String> timeFormat;
  final double mBaseHeight;
  final double? mSecondaryHeight;
  final KChartColors chartColors;
  final KChartStyle chartStyle;
  final double xFrontPadding;
  final WidgetDetailBuilder? detailBuilder;
  final int fixedLength;

  /// Drives zoom / pan / crosshair from the outside.
  ///
  /// Leave it null to let the widget own a private controller. Pass one to
  /// keep a handle on the chart — e.g. `controller.reset()` to go back to
  /// `scaleX = 1.0` with no pan and no crosshair.
  final InteractiveLayerController? controller;

  const KChartWidget(
    this.datas,
    this.chartStyle,
    this.chartColors, {
    super.key,
    this.detailBuilder,
    this.controller,
    this.xFrontPadding = 100,
    this.mainIndicators = const [],
    this.secondaryIndicators = const [],
    this.volHidden = false,
    this.isLine = false,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.timeFormat = TimeFormat.yearMonthDay,
    this.fixedLength = 2,
    this.mBaseHeight = 360,
    this.mSecondaryHeight,
  });

  @override
  State<KChartWidget> createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  final StreamController<InfoWindowEntity?> _mInfoWindowStream =
      StreamController<InfoWindowEntity?>();

  /// Only created when the caller did not supply one.
  InteractiveLayerController? _internalController;
  late InteractiveLayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        (_internalController = InteractiveLayerController());
    _controller.attach(this);
  }

  @override
  void didUpdateWidget(covariant KChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.detach();
      final stale = _internalController;
      if (widget.controller != null && stale != null) {
        _internalController = null;
        WidgetsBinding.instance.addPostFrameCallback((_) => stale.dispose());
      }
      _controller =
          widget.controller ??
          (_internalController ??= InteractiveLayerController());
      _controller.attach(this);
    }

    // A fresh (or emptied) data set invalidates the current zoom / pan.
    if ((widget.datas?.isEmpty ?? true) != (oldWidget.datas?.isEmpty ?? true)) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.detach();
    _internalController?.dispose();
    _mInfoWindowStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BaseDimension baseDimension = BaseDimension(
      mBaseHeight: widget.mBaseHeight,
      mSecondaryHeight: widget.mSecondaryHeight ?? widget.mBaseHeight * .2,
      volHidden: widget.volHidden,
      secondaryIndicators: widget.secondaryIndicators,
      mainIndicators: widget.mainIndicators,
    );
    final painter = ChartPainter(
      widget.chartStyle,
      widget.chartColors,
      baseDimension: baseDimension,
      sink: _mInfoWindowStream.sink,
      xFrontPadding: widget.xFrontPadding,
      datas: widget.datas,
      // The painter reads the view port live and repaints on its
      // notifications; interacting with the chart never rebuilds this widget.
      pointViewPort: _controller.pointViewPort,
      mainIndicators: widget.mainIndicators,
      volHidden: widget.volHidden,
      secondaryIndicators: widget.secondaryIndicators,
      isLine: widget.isLine,
      hideGrid: widget.hideGrid,
      showNowPrice: widget.showNowPrice,
      fixedLength: widget.fixedLength,
    );

    final detailBuilder = widget.detailBuilder;

    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: <Type, GestureRecognizerFactory>{
        ChartGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<ChartGestureRecognizer>(
              () => ChartGestureRecognizer(debugOwner: this),
              (ChartGestureRecognizer instance) {
                instance
                  ..onTap = _controller.handleTap
                  ..onLongPressStart = _controller.handleLongPressStart
                  ..onLongPressUpdate = _controller.handleLongPressUpdate
                  ..onLongPressEnd = _controller.handleLongPressEnd
                  ..onPanStart = _controller.handlePanStart
                  ..onPanUpdate = _controller.handlePanUpdate
                  ..onPanEnd = _controller.handlePanEnd
                  ..onScaleStart = _controller.handleScaleStart
                  ..onScaleUpdate = _controller.handleScaleUpdate
                  ..onScaleEnd = _controller.handleScaleEnd;
              },
            ),
      },
      child: Stack(
        children: <Widget>[
          RepaintBoundary(
            child: CustomPaint(
              size: Size(double.infinity, baseDimension.mDisplayHeight),
              painter: painter,
            ),
          ),
          if (detailBuilder != null)
            StreamBuilder<InfoWindowEntity?>(
              stream: _mInfoWindowStream.stream,
              builder: (context, snapshot) {
                final info = snapshot.data;
                if (widget.isLine || info == null) {
                  return const SizedBox.shrink();
                }
                final entity = info.kLineEntity;
                if (info.isLeft) {
                  return Positioned(left: 10.0, child: detailBuilder(entity));
                }
                return Positioned(right: 10.0, child: detailBuilder(entity));
              },
            ),
        ],
      ),
    );
  }
}
