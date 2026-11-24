import 'package:material_ui/material_ui.dart';
import 'package:xue_hua_universal_widgets/xue_hua_universal_widgets.dart';

import '../widgets/demo_section.dart';
import '../widgets/demo_switch_chip.dart';

class CarouselSliderPage extends StatefulWidget {
  const CarouselSliderPage({super.key});

  @override
  State<CarouselSliderPage> createState() => _CarouselSliderPageState();
}

class _CarouselSliderPageState extends State<CarouselSliderPage> {
  static const List<Color> _slideColors = [
    Color(0xFF00897B),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFF4511E),
    Color(0xFF43A047),
  ];

  final CarouselSliderController _controller = CarouselSliderController();

  bool _autoPlay = false;
  bool _enableInfiniteScroll = true;
  bool _enlargeCenterPage = true;
  bool _reverse = false;
  bool _disableGesture = false;
  Axis _scrollDirection = Axis.horizontal;
  CenterPageEnlargeStrategy _enlargeStrategy = CenterPageEnlargeStrategy.scale;
  double _viewportFraction = 0.8;

  int _currentIndex = 0;
  CarouselPageChangedReason? _lastReason;
  double? _lastScrolledValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CarouselSlider')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            DemoSection(
              title: '交互式主轮播 (CarouselSlider + CarouselOptions)',
              subtitle:
                  '当前页: $_currentIndex | 触发原因: ${_lastReason?.name ?? "-"} | onScrolled: ${_lastScrolledValue?.toStringAsFixed(2) ?? "-"}',
              child: Column(
                children: [
                  CarouselSlider(
                    carouselController: _controller,
                    disableGesture: _disableGesture,
                    options: CarouselOptions(
                      height: 180,
                      viewportFraction: _viewportFraction,
                      enableInfiniteScroll: _enableInfiniteScroll,
                      reverse: _reverse,
                      autoPlay: _autoPlay,
                      autoPlayInterval: const Duration(seconds: 2),
                      enlargeCenterPage: _enlargeCenterPage,
                      enlargeStrategy: _enlargeStrategy,
                      enlargeFactor: 0.3,
                      scrollDirection: _scrollDirection,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                          _lastReason = reason;
                        });
                      },
                      onScrolled: (value) {
                        setState(() => _lastScrolledValue = value);
                      },
                    ),
                    items: List<Widget>.generate(
                      _slideColors.length,
                      (index) => _CarouselSlideCard(
                        title: 'Slide ${index + 1}',
                        subtitle: 'items 模式 · ${_enlargeStrategy.name}',
                        color: _slideColors[index],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _controller.previousPage(),
                        icon: const Icon(Icons.chevron_left, size: 18),
                        label: const Text('上一页'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _controller.nextPage(),
                        icon: const Icon(Icons.chevron_right, size: 18),
                        label: const Text('下一页'),
                      ),
                      OutlinedButton(
                        onPressed: () => _controller.jumpToPage(0),
                        child: const Text('jump(0)'),
                      ),
                      OutlinedButton(
                        onPressed: () => _controller.animateToPage(3),
                        child: const Text('animate(3)'),
                      ),
                      OutlinedButton(
                        onPressed: _controller.startAutoPlay,
                        child: const Text('startAutoPlay'),
                      ),
                      OutlinedButton(
                        onPressed: _controller.stopAutoPlay,
                        child: const Text('stopAutoPlay'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DemoSection(
              title: 'CarouselOptions 配置项切换',
              subtitle: '覆盖所有核心轮播参数与居中放大策略',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      DemoSwitchChip(
                        label: 'autoPlay',
                        value: _autoPlay,
                        onChanged: (v) => setState(() => _autoPlay = v),
                      ),
                      DemoSwitchChip(
                        label: 'infiniteScroll',
                        value: _enableInfiniteScroll,
                        onChanged: (v) =>
                            setState(() => _enableInfiniteScroll = v),
                      ),
                      DemoSwitchChip(
                        label: 'enlargeCenterPage',
                        value: _enlargeCenterPage,
                        onChanged: (v) =>
                            setState(() => _enlargeCenterPage = v),
                      ),
                      DemoSwitchChip(
                        label: 'reverse',
                        value: _reverse,
                        onChanged: (v) => setState(() => _reverse = v),
                      ),
                      DemoSwitchChip(
                        label: 'disableGesture',
                        value: _disableGesture,
                        onChanged: (v) => setState(() => _disableGesture = v),
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<CenterPageEnlargeStrategy>(
                    segments: const [
                      ButtonSegment(
                        value: CenterPageEnlargeStrategy.scale,
                        label: Text('scale'),
                      ),
                      ButtonSegment(
                        value: CenterPageEnlargeStrategy.height,
                        label: Text('height'),
                      ),
                      ButtonSegment(
                        value: CenterPageEnlargeStrategy.zoom,
                        label: Text('zoom'),
                      ),
                    ],
                    selected: {_enlargeStrategy},
                    onSelectionChanged: (selection) =>
                        setState(() => _enlargeStrategy = selection.first),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'viewportFraction: ${_viewportFraction.toStringAsFixed(2)}',
                      ),
                      Expanded(
                        child: Slider(
                          value: _viewportFraction,
                          min: 0.55,
                          max: 1.0,
                          divisions: 9,
                          onChanged: (v) =>
                              setState(() => _viewportFraction = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DemoSection(
              title: '按需构建模式 (CarouselSlider.builder)',
              subtitle: '提供 itemCount 与 (context, index, realIndex) 按需构建回调',
              child: CarouselSlider.builder(
                itemCount: 8,
                options: CarouselOptions(
                  height: 120,
                  viewportFraction: 0.7,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                ),
                itemBuilder: (context, index, realIndex) {
                  return _CarouselSlideCard(
                    title: 'Builder #$index',
                    subtitle: 'realIndex: $realIndex',
                    color: _slideColors[index % _slideColors.length],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarouselSlideCard extends StatelessWidget {
  const _CarouselSlideCard({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
