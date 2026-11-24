import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:xue_hua_universal_widgets/xue_hua_universal_widgets.dart';

import '../widgets/demo_section.dart';
import '../widgets/demo_switch_chip.dart';

class KChartPlusPage extends StatefulWidget {
  const KChartPlusPage({super.key});

  @override
  State<KChartPlusPage> createState() => _KChartPlusPageState();
}

class _KChartPlusPageState extends State<KChartPlusPage> {
  final InteractiveLayerController _controller = InteractiveLayerController();

  final MAIndicator _ma = MAIndicator();
  final EMAIndicator _ema = EMAIndicator();
  final BOLLIndicator _boll = BOLLIndicator();
  final SARIndicator _sar = SARIndicator();

  final MACDIndicator _macd = MACDIndicator();
  final KDJIndicator _kdj = KDJIndicator();
  final RSIIndicator _rsi = RSIIndicator();
  final WRIndicator _wr = WRIndicator();
  final CCIIndicator _cci = CCIIndicator();

  late final List<KLineEntity> _datas;
  late final List<DepthEntity> _bids;
  late final List<DepthEntity> _asks;

  final Set<String> _activeMainKeys = {'MA'};
  final Set<String> _activeSecondaryKeys = {'MACD'};

  bool _isLine = false;
  bool _volHidden = false;
  bool _hideGrid = false;
  bool _showNowPrice = true;
  bool _darkTheme = false;
  String _loadMoreStatus = '拖动到边缘会触发 onLoadMore 回调';

  @override
  void initState() {
    super.initState();
    _datas = _generateSampleKLines(120);
    DataUtil.calculateAll(
      _datas,
      [_ma, _ema, _boll, _sar],
      [_macd, _kdj, _rsi, _wr, _cci],
    );
    _bids = _generateBids();
    _asks = _generateAsks();

    _controller.onLoadMore = (isRightEdge) {
      if (!mounted) return;
      setState(() {
        _loadMoreStatus = isRightEdge ? '已到达最新数据右边缘' : '已到达历史数据左边缘（可加载更多）';
      });
    };
  }

  List<KLineEntity> _generateSampleKLines(int count) {
    final baseTime = DateTime(2026, 6, 1).millisecondsSinceEpoch;
    var price = 42000.0;
    return List<KLineEntity>.generate(count, (i) {
      final wave = math.sin(i * 0.23) * 420 + math.cos(i * 0.11) * 260;
      final open = price;
      final close = (open + wave * 0.35 + (i.isEven ? 95 : -80)).clamp(
        36000.0,
        52000.0,
      );
      final high = math.max(open, close) + 120 + (i % 5) * 45;
      final low = math.min(open, close) - 110 - (i % 4) * 40;
      final vol = 800.0 + (i % 13) * 190 + (wave.abs() * 1.4);
      price = close;
      return KLineEntity.fromCustom(
        open: open,
        high: high,
        low: low,
        close: close,
        vol: vol,
        time: baseTime + i * 86400000,
      );
    });
  }

  List<DepthEntity> _generateBids() {
    var cumVol = 180.0;
    return List<DepthEntity>.generate(15, (i) {
      final price = 41850.0 + i * 10.0;
      cumVol = (cumVol - (10.0 + (i % 3) * 3.0)).clamp(5.0, 200.0);
      return DepthEntity(price, cumVol);
    });
  }

  List<DepthEntity> _generateAsks() {
    var cumVol = 8.0;
    return List<DepthEntity>.generate(15, (i) {
      final price = 42010.0 + i * 10.0;
      cumVol += 10.0 + (i % 4) * 3.5;
      return DepthEntity(price, cumVol);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainIndicators = <MainIndicator>[
      if (_activeMainKeys.contains('MA')) _ma,
      if (_activeMainKeys.contains('EMA')) _ema,
      if (_activeMainKeys.contains('BOLL')) _boll,
      if (_activeMainKeys.contains('SAR')) _sar,
    ];
    final secondaryIndicators = <SecondaryIndicator>[
      if (_activeSecondaryKeys.contains('MACD')) _macd,
      if (_activeSecondaryKeys.contains('KDJ')) _kdj,
      if (_activeSecondaryKeys.contains('RSI')) _rsi,
      if (_activeSecondaryKeys.contains('WR')) _wr,
      if (_activeSecondaryKeys.contains('CCI')) _cci,
    ];

    final KChartColors chartColors = _darkTheme
        ? const KChartColors(
            bgColor: Color(0xFF131722),
            defaultTextColor: Color(0xFF9598A1),
            gridColor: Color(0xFF2A2E39),
            crossColor: Color(0xFFE0E3EB),
            crossTextColor: Color(0xFF131722),
            crossBgColor: Color(0xFFE0E3EB),
            crossBorderColor: Color(0xFFE0E3EB),
            nowPriceUpColor: Color(0xFF14AD8F),
            nowPriceDnColor: Color(0xFFD5405D),
            maxColor: Color(0xFFE0E3EB),
            minColor: Color(0xFFE0E3EB),
          )
        : const KChartColors();

    final DepthChartColors depthColors = _darkTheme
        ? const DepthChartColors(
            defaultTextColor: Color(0xFF9598A1),
            selectFillColor: Color(0xFF1E222D),
            selectBorderColor: Color(0xFF434651),
            annotationColor: Color(0xFFE0E3EB),
            crossColor: Color(0xFFE0E3EB),
          )
        : const DepthChartColors();

    return Scaffold(
      appBar: AppBar(title: const Text('KChartPlus & DepthChart')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            DemoSection(
              title: 'K 线图控制面板',
              subtitle: '支持单指拖动、双指缩放、点击/长按十字光标，$_loadMoreStatus',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      DemoSwitchChip(
                        label: _isLine ? '分时折线 (isLine)' : '蜡烛图',
                        value: _isLine,
                        onChanged: (v) => setState(() => _isLine = v),
                      ),
                      DemoSwitchChip(
                        label: '显示成交量',
                        value: !_volHidden,
                        onChanged: (v) => setState(() => _volHidden = !v),
                      ),
                      DemoSwitchChip(
                        label: '显示网格',
                        value: !_hideGrid,
                        onChanged: (v) => setState(() => _hideGrid = !v),
                      ),
                      DemoSwitchChip(
                        label: '当前价标线',
                        value: _showNowPrice,
                        onChanged: (v) => setState(() => _showNowPrice = v),
                      ),
                      DemoSwitchChip(
                        label: '暗色主题',
                        value: _darkTheme,
                        onChanged: (v) => setState(() => _darkTheme = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '主图指标 (可多选叠加)：',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final key in ['MA', 'EMA', 'BOLL', 'SAR'])
                        DemoSwitchChip(
                          label: key,
                          value: _activeMainKeys.contains(key),
                          onChanged: (selected) {
                            setState(() {
                              if (selected) {
                                _activeMainKeys.add(key);
                              } else {
                                _activeMainKeys.remove(key);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '副图指标 (可多选叠加)：',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final key in ['MACD', 'KDJ', 'RSI', 'WR', 'CCI'])
                        DemoSwitchChip(
                          label: key,
                          value: _activeSecondaryKeys.contains(key),
                          onChanged: (selected) {
                            setState(() {
                              if (selected) {
                                _activeSecondaryKeys.add(key);
                              } else {
                                _activeSecondaryKeys.remove(key);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _controller.zoomTo(
                          _controller.pointViewPort.scaleX * 1.25,
                        ),
                        icon: const Icon(Icons.zoom_in, size: 18),
                        label: const Text('放大'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _controller.zoomTo(
                          _controller.pointViewPort.scaleX * 0.8,
                        ),
                        icon: const Icon(Icons.zoom_out, size: 18),
                        label: const Text('缩小'),
                      ),
                      OutlinedButton(
                        onPressed: () => _controller.scrollTo(0),
                        child: const Text('跳到最新'),
                      ),
                      OutlinedButton(
                        onPressed: _controller.reset,
                        child: const Text('Reset 视图'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DemoSection(
              title: 'KChartWidget 实盘图表预览',
              subtitle: '点击或长按图表展示自定义 detailBuilder 浮窗详情',
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: KChartWidget(
                  _datas,
                  const KChartStyle(),
                  chartColors,
                  controller: _controller,
                  mainIndicators: mainIndicators,
                  secondaryIndicators: secondaryIndicators,
                  volHidden: _volHidden,
                  isLine: _isLine,
                  hideGrid: _hideGrid,
                  showNowPrice: _showNowPrice,
                  mBaseHeight: 280,
                  mSecondaryHeight: 68,
                  fixedLength: 2,
                  detailBuilder: (entity) =>
                      _KLineDetailCard(entity: entity, darkTheme: _darkTheme),
                ),
              ),
            ),
            DemoSection(
              title: '市场深度图 (DepthChart)',
              subtitle: '长按深度图左右滑动查看买盘 / 卖盘委托价量十字浮窗',
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _darkTheme ? const Color(0xFF131722) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DepthChart(
                  _bids,
                  _asks,
                  depthColors,
                  baseUnit: 2,
                  quoteUnit: 2,
                  chartTranslations: const DepthChartTranslations(
                    price: '价格',
                    amount: '累计量',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KLineDetailCard extends StatelessWidget {
  const _KLineDetailCard({required this.entity, required this.darkTheme});

  final KLineEntity entity;
  final bool darkTheme;

  @override
  Widget build(BuildContext context) {
    final bgColor = darkTheme
        ? const Color(0xE61E222D)
        : const Color(0xE6FFFFFF);
    final textColor = darkTheme ? Colors.white : Colors.black87;
    final dateText = dateFormat(
      DateTime.fromMillisecondsSinceEpoch(entity.time ?? 0),
      TimeFormat.yearMonthDay,
    );

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(8),
      width: 138,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withAlpha(110)),
      ),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 10, color: textColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _KLineDetailRow(label: '日期', value: dateText),
            _KLineDetailRow(
              label: '开盘',
              value: NumberUtil.formatFixed(entity.open, 2) ?? '--',
            ),
            _KLineDetailRow(
              label: '最高',
              value: NumberUtil.formatFixed(entity.high, 2) ?? '--',
            ),
            _KLineDetailRow(
              label: '最低',
              value: NumberUtil.formatFixed(entity.low, 2) ?? '--',
            ),
            _KLineDetailRow(
              label: '收盘',
              value: NumberUtil.formatFixed(entity.close, 2) ?? '--',
            ),
            _KLineDetailRow(
              label: '成交量',
              value: NumberUtil.formatCompact(entity.vol),
            ),
          ],
        ),
      ),
    );
  }
}

class _KLineDetailRow extends StatelessWidget {
  const _KLineDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
