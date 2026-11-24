import 'package:material_ui/material_ui.dart';
import 'package:xue_hua_universal_widgets/xue_hua_universal_widgets.dart';

import '../widgets/demo_section.dart';
import '../widgets/demo_switch_chip.dart';

enum _PaginationKind { dots, fraction, rect, custom }

class CardSwiperPage extends StatefulWidget {
  const CardSwiperPage({super.key});

  @override
  State<CardSwiperPage> createState() => _CardSwiperPageState();
}

class _CardSwiperPageState extends State<CardSwiperPage> {
  static const List<Color> _cardColors = [
    Color(0xFF00897B),
    Color(0xFF3949AB),
    Color(0xFFD81B60),
    Color(0xFFFB8C00),
    Color(0xFF5E35B1),
  ];

  final SwiperController _controller = SwiperController();

  SwiperLayout _layout = SwiperLayout.DEFAULT;
  _PaginationKind _paginationKind = _PaginationKind.dots;
  PageIndicatorLayout _indicatorLayout = PageIndicatorLayout.scale;

  bool _loop = true;
  bool _autoplay = false;
  bool _outerPagination = false;
  bool _showControl = true;
  bool _useScaleFade = true;
  Axis _scrollDirection = Axis.horizontal;
  AxisDirection _axisDirection = AxisDirection.left;

  int _activeIndex = 0;
  String _lastTapMessage = '点击卡片触发 onTap';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool supportsLoopIndicator =
        _indicatorLayout == PageIndicatorLayout.none ||
        _indicatorLayout == PageIndicatorLayout.scale ||
        _indicatorLayout == PageIndicatorLayout.color;
    final bool effectiveLoop =
        _layout == SwiperLayout.DEFAULT && !supportsLoopIndicator
        ? false
        : _loop;

    final CustomLayoutOption customOption =
        CustomLayoutOption(startIndex: -1, stateCount: 3)
          ..addRotate([-0.25, 0.0, 0.25])
          ..addTranslate(const [
            Offset(-220.0, -20.0),
            Offset.zero,
            Offset(220.0, -20.0),
          ])
          ..addScale([0.85, 1.0, 0.85], Alignment.center)
          ..addOpacity([0.6, 1.0, 0.6]);

    final SwiperPlugin paginationPlugin;
    switch (_paginationKind) {
      case _PaginationKind.dots:
        paginationPlugin = const SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            activeColor: Colors.teal,
            color: Colors.black26,
          ),
        );
      case _PaginationKind.fraction:
        paginationPlugin = const SwiperPagination(
          builder: FractionPaginationBuilder(
            activeColor: Colors.teal,
            color: Colors.black54,
            fontSize: 16,
            activeFontSize: 24,
          ),
        );
      case _PaginationKind.rect:
        paginationPlugin = const SwiperPagination(
          builder: RectSwiperPaginationBuilder(
            activeColor: Colors.teal,
            color: Colors.black26,
            size: Size(14, 4),
            activeSize: Size(24, 5),
          ),
        );
      case _PaginationKind.custom:
        paginationPlugin = SwiperPagination(
          builder: SwiperCustomPagination(
            builder: (context, config) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Text(
                    'Custom ${config.activeIndex + 1} / ${config.itemCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            },
          ),
        );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('CardSwiper')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            DemoSection(
              title: '交互式主画廊 (DEFAULT / STACK / TINDER / CUSTOM)',
              subtitle: '当前索引: $_activeIndex | $_lastTapMessage',
              child: Column(
                children: [
                  SizedBox(
                    height: 230,
                    child: Swiper(
                      key: ValueKey(
                        '${_layout.name}-${_indicatorLayout.name}-$effectiveLoop-$_scrollDirection-$_axisDirection',
                      ),
                      controller: _controller,
                      itemCount: _cardColors.length,
                      layout: _layout,
                      loop: effectiveLoop,
                      autoplay: _autoplay,
                      autoplayDelay: 2500,
                      outer: _outerPagination,
                      scrollDirection: _scrollDirection,
                      axisDirection: _axisDirection,
                      viewportFraction:
                          _layout == SwiperLayout.DEFAULT && _useScaleFade
                          ? 0.82
                          : 1.0,
                      scale: _layout == SwiperLayout.DEFAULT && _useScaleFade
                          ? 0.9
                          : null,
                      fade: _layout == SwiperLayout.DEFAULT && _useScaleFade
                          ? 0.6
                          : null,
                      itemWidth: 240,
                      itemHeight: 170,
                      customLayoutOption: _layout == SwiperLayout.CUSTOM
                          ? customOption
                          : null,
                      indicatorLayout: _indicatorLayout,
                      pagination: paginationPlugin,
                      control: _showControl
                          ? const SwiperControl(color: Colors.teal)
                          : null,
                      onIndexChanged: (index) {
                        setState(() => _activeIndex = index);
                      },
                      onTap: (index) {
                        setState(() {
                          _lastTapMessage = '点击了卡片 #${index + 1}';
                        });
                      },
                      itemBuilder: (context, index) {
                        return _SwiperCard(
                          index: index,
                          label: _layout.name,
                          color: _cardColors[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => _controller.previous(),
                        child: const Text('previous()'),
                      ),
                      OutlinedButton(
                        onPressed: () => _controller.next(),
                        child: const Text('next()'),
                      ),
                      OutlinedButton(
                        onPressed: () => _controller.move(0),
                        child: const Text('move(0)'),
                      ),
                      OutlinedButton(
                        onPressed: () => _controller.move(3),
                        child: const Text('move(3)'),
                      ),
                      OutlinedButton(
                        onPressed: _controller.startAutoplay,
                        child: const Text('startAutoplay'),
                      ),
                      OutlinedButton(
                        onPressed: _controller.stopAutoplay,
                        child: const Text('stopAutoplay'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DemoSection(
              title: '布局模式、分页样式与指示器动画配置',
              subtitle: '注意：slide / warm / drop 动效指示器会自动切换为非循环模式',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<SwiperLayout>(
                    segments: const [
                      ButtonSegment(
                        value: SwiperLayout.DEFAULT,
                        label: Text('DEFAULT'),
                      ),
                      ButtonSegment(
                        value: SwiperLayout.STACK,
                        label: Text('STACK'),
                      ),
                      ButtonSegment(
                        value: SwiperLayout.TINDER,
                        label: Text('TINDER'),
                      ),
                      ButtonSegment(
                        value: SwiperLayout.CUSTOM,
                        label: Text('CUSTOM'),
                      ),
                    ],
                    selected: {_layout},
                    onSelectionChanged: (s) =>
                        setState(() => _layout = s.first),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<_PaginationKind>(
                    segments: const [
                      ButtonSegment(
                        value: _PaginationKind.dots,
                        label: Text('Dots'),
                      ),
                      ButtonSegment(
                        value: _PaginationKind.fraction,
                        label: Text('Fraction'),
                      ),
                      ButtonSegment(
                        value: _PaginationKind.rect,
                        label: Text('Rect'),
                      ),
                      ButtonSegment(
                        value: _PaginationKind.custom,
                        label: Text('Custom'),
                      ),
                    ],
                    selected: {_paginationKind},
                    onSelectionChanged: (s) =>
                        setState(() => _paginationKind = s.first),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final indicator in PageIndicatorLayout.values)
                        ChoiceChip(
                          label: Text('ind: ${indicator.name}'),
                          selected: _indicatorLayout == indicator,
                          onSelected: (_) =>
                              setState(() => _indicatorLayout = indicator),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      DemoSwitchChip(
                        label: 'loop',
                        value: effectiveLoop,
                        onChanged: (v) => setState(() => _loop = v),
                      ),
                      DemoSwitchChip(
                        label: 'autoplay',
                        value: _autoplay,
                        onChanged: (v) => setState(() => _autoplay = v),
                      ),
                      DemoSwitchChip(
                        label: 'outer pagination',
                        value: _outerPagination,
                        onChanged: (v) => setState(() => _outerPagination = v),
                      ),
                      DemoSwitchChip(
                        label: 'SwiperControl',
                        value: _showControl,
                        onChanged: (v) => setState(() => _showControl = v),
                      ),
                      DemoSwitchChip(
                        label: 'scale & fade',
                        value: _useScaleFade,
                        onChanged: (v) => setState(() => _useScaleFade = v),
                      ),
                      DemoSwitchChip(
                        label: _scrollDirection == Axis.horizontal
                            ? '方向: 水平'
                            : '方向: 垂直',
                        value: _scrollDirection == Axis.vertical,
                        onChanged: (v) => setState(
                          () => _scrollDirection = v
                              ? Axis.vertical
                              : Axis.horizontal,
                        ),
                      ),
                      if (_layout == SwiperLayout.STACK)
                        DemoSwitchChip(
                          label: 'axis: ${_axisDirection.name}',
                          value: _axisDirection == AxisDirection.right,
                          onChanged: (v) => setState(
                            () => _axisDirection = v
                                ? AxisDirection.right
                                : AxisDirection.left,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            DemoSection(
              title: '便捷构造：Swiper.children 与 Swiper.list<T>',
              subtitle: '展示静态子组件列表与泛型数据源构造器',
              child: Column(
                children: [
                  SizedBox(
                    height: 90,
                    child: Swiper.children(
                      pagination: const SwiperPagination(
                        builder: SwiperPagination.rect,
                      ),
                      children: [
                        _SwiperCard(
                          index: 0,
                          label: 'Swiper.children',
                          color: _cardColors[0],
                        ),
                        _SwiperCard(
                          index: 1,
                          label: 'Swiper.children',
                          color: _cardColors[1],
                        ),
                        _SwiperCard(
                          index: 2,
                          label: 'Swiper.children',
                          color: _cardColors[2],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: Swiper.list<String>(
                      list: const ['Alpha', 'Beta', 'Gamma'],
                      pagination: const SwiperPagination(
                        builder: SwiperPagination.fraction,
                      ),
                      builder: (context, data, index) {
                        return _SwiperCard(
                          index: index,
                          label: 'Swiper.list: $data',
                          color: _cardColors[(index + 2) % _cardColors.length],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwiperCard extends StatelessWidget {
  const _SwiperCard({
    required this.index,
    required this.label,
    required this.color,
  });

  final int index;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Card ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
