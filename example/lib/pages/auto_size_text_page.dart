import 'package:material_ui/material_ui.dart';
import 'package:xue_hua_universal_widgets/xue_hua_universal_widgets.dart';

import '../widgets/demo_section.dart';
import '../widgets/demo_switch_chip.dart';

class AutoSizeTextPage extends StatefulWidget {
  const AutoSizeTextPage({super.key});

  @override
  State<AutoSizeTextPage> createState() => _AutoSizeTextPageState();
}

class _AutoSizeTextPageState extends State<AutoSizeTextPage> {
  final TextEditingController _inputController = TextEditingController(
    text: 'AutoSizeText 会根据容器宽高与最大行数自动计算最合适的字号大小。',
  );
  final AutoSizeGroup _sharedGroup = AutoSizeGroup();

  double _boxWidth = 260;
  int _maxLines = 2;
  double _stepGranularity = 1.0;
  bool _wrapWords = true;
  bool _isOverflowing = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sampleText = _inputController.text;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('AutoSizeText')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            DemoSection(
              title: '交互参数控制',
              subtitle: '动态调整容器宽度、最大行数、步进粒度与示例文本',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      labelText: '测试文本',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('容器宽度: ${_boxWidth.round()}px'),
                      Expanded(
                        child: Slider(
                          value: _boxWidth,
                          min: 80,
                          max: 340,
                          onChanged: (v) => setState(() => _boxWidth = v),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('maxLines:'),
                      for (final lines in [1, 2, 3])
                        ChoiceChip(
                          label: Text('$lines'),
                          selected: _maxLines == lines,
                          onSelected: (_) => setState(() => _maxLines = lines),
                        ),
                      const Text('step:'),
                      for (final step in [1.0, 2.0, 4.0])
                        ChoiceChip(
                          label: Text('$step'),
                          selected: _stepGranularity == step,
                          onSelected: (_) =>
                              setState(() => _stepGranularity = step),
                        ),
                      DemoSwitchChip(
                        label: 'wrapWords',
                        value: _wrapWords,
                        onChanged: (v) => setState(() => _wrapWords = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DemoSection(
              title: '基础自动缩放 (minFontSize / maxFontSize / stepGranularity)',
              subtitle: 'style: 30px, minFontSize: 10, maxFontSize: 30',
              child: Center(
                child: Container(
                  width: _boxWidth,
                  height: 76,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AutoSizeText(
                    sampleText,
                    style: const TextStyle(fontSize: 30),
                    minFontSize: 10,
                    maxFontSize: 30,
                    maxLines: _maxLines,
                    stepGranularity: _stepGranularity,
                    wrapWords: _wrapWords,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            DemoSection(
              title: '预设字号列表 (presetFontSizes)',
              subtitle: '仅在降序预设列表 [32, 24, 18, 14, 10] 中选择最大可容纳字号',
              child: Center(
                child: Container(
                  width: _boxWidth,
                  height: 64,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withAlpha(80),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AutoSizeText(
                    sampleText,
                    presetFontSizes: const [32, 24, 18, 14, 10],
                    maxLines: _maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            DemoSection(
              title: '溢出替换 (overflowReplacement) & 溢出回调 (overflowCallback)',
              subtitle: '拖动上方宽度滑块至较窄值触发溢出替换',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前溢出状态: ${_isOverflowing ? "已溢出 (显示替代组件)" : "正常容纳"}',
                    style: TextStyle(
                      color: _isOverflowing ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: _boxWidth,
                      height: 36,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AutoSizeText(
                        sampleText,
                        maxLines: 1,
                        minFontSize: 16,
                        style: const TextStyle(fontSize: 22),
                        overflowCallback: (overflow) {
                          if (overflow != _isOverflowing) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() => _isOverflowing = overflow);
                              }
                            });
                          }
                        },
                        overflowReplacement: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber,
                              size: 18,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '文本溢出替代提示',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DemoSection(
              title: '单词折行对比 (wrapWords: true vs false)',
              subtitle: '包含超长英文单词时 wrapWords=false 会整体缩小以保证单词不断行',
              child: Row(
                children: [
                  Expanded(
                    child: _WrapComparisonBox(
                      label: 'wrapWords: true',
                      wrapWords: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _WrapComparisonBox(
                      label: 'wrapWords: false',
                      wrapWords: false,
                    ),
                  ),
                ],
              ),
            ),
            DemoSection(
              title: '富文本自动缩放 (AutoSizeText.rich)',
              subtitle: '保持不同局部样式并整体等比缩放',
              child: Center(
                child: Container(
                  width: _boxWidth,
                  height: 60,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withAlpha(80),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AutoSizeText.rich(
                    TextSpan(
                      text: '价格 ',
                      style: TextStyle(fontSize: 26),
                      children: [
                        TextSpan(
                          text: '¥9,999.00 ',
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '限时优惠活动进行中',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    minFontSize: 10,
                  ),
                ),
              ),
            ),
            DemoSection(
              title: '分组字号同步 (AutoSizeGroup & AutoSizeGroupBuilder)',
              subtitle: '同组内所有 AutoSizeText 自动对齐至最小可容纳字号',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '1) 显式 AutoSizeGroup 实例同步：',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _SyncedGroupCard(
                          text: '短标题',
                          group: _sharedGroup,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SyncedGroupCard(
                          text: '这是一段明显更长用于拉齐整组字号的标题文本',
                          group: _sharedGroup,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '2) AutoSizeGroupBuilder 自动管理组生命周期：',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  AutoSizeGroupBuilder(
                    builder: (context, group) {
                      return Row(
                        children: [
                          Expanded(
                            child: _SyncedGroupCard(text: 'A 项', group: group),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SyncedGroupCard(
                              text: '中等长度标题',
                              group: group,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SyncedGroupCard(
                              text: '很长的同步测试标签文案',
                              group: group,
                            ),
                          ),
                        ],
                      );
                    },
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

class _WrapComparisonBox extends StatelessWidget {
  const _WrapComparisonBox({required this.label, required this.wrapWords});

  final String label;
  final bool wrapWords;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 82,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: AutoSizeText(
              'Supercalifragilisticexpialidocious word',
              style: const TextStyle(fontSize: 22),
              minFontSize: 8,
              maxLines: 2,
              wrapWords: wrapWords,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncedGroupCard extends StatelessWidget {
  const _SyncedGroupCard({required this.text, required this.group});

  final String text;
  final AutoSizeGroup group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 46,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AutoSizeText(
        text,
        group: group,
        maxLines: 1,
        minFontSize: 8,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }
}
