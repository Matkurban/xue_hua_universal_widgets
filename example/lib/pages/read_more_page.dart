import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:xue_hua_universal_widgets/xue_hua_universal_widgets.dart';

import '../widgets/demo_section.dart';
import '../widgets/draggable_divider.dart';

class ReadMorePage extends StatefulWidget {
  const ReadMorePage({super.key});

  @override
  State<ReadMorePage> createState() => _ReadMorePageState();
}

class _ReadMorePageState extends State<ReadMorePage> {
  static const _userMap = {123: 'Android', 456: 'iOS'};

  final ValueNotifier<bool> _isCollapsed = ValueNotifier<bool>(true);
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  late final TapGestureRecognizer _widgetsSpanRecognizer;

  TrimMode _trimMode = TrimMode.line;
  int _trimLines = 2;
  int _trimLength = 90;

  @override
  void initState() {
    super.initState();
    _widgetsSpanRecognizer = TapGestureRecognizer()
      ..onTap = () => _showMessage('Rich span "widgets" tapped!');
  }

  TapGestureRecognizer _createRecognizer(VoidCallback onTap) {
    final recognizer = TapGestureRecognizer()..onTap = onTap;
    _recognizers.add(recognizer);
    return recognizer;
  }

  void _disposeDynamicRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _disposeDynamicRecognizers();
    _widgetsSpanRecognizer.dispose();
    _isCollapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeDynamicRecognizers();

    return Scaffold(
      appBar: AppBar(title: const Text('ReadMoreText')),
      body: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14),
        child: DraggableDivider(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                DemoSection(
                  title: '折叠模式与阈值配置',
                  subtitle: '拖动右侧灰色分割线可实时改变容器宽度以观察换行折叠',
                  child: Column(
                    children: [
                      SegmentedButton<TrimMode>(
                        segments: const [
                          ButtonSegment<TrimMode>(
                            value: TrimMode.length,
                            label: Text('TrimMode.length'),
                          ),
                          ButtonSegment<TrimMode>(
                            value: TrimMode.line,
                            label: Text('TrimMode.line'),
                          ),
                        ],
                        selected: <TrimMode>{_trimMode},
                        onSelectionChanged: (Set<TrimMode> newSelection) {
                          setState(() => _trimMode = newSelection.first);
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_trimMode == TrimMode.length)
                        _TrimValueStepper(
                          label: 'trimLength',
                          value: _trimLength,
                          onDecrement: () => setState(
                            () => _trimLength = _trimLength > 10
                                ? _trimLength - 10
                                : 10,
                          ),
                          onIncrement: () => setState(() => _trimLength += 10),
                        ),
                      if (_trimMode == TrimMode.line)
                        _TrimValueStepper(
                          label: 'trimLines',
                          value: _trimLines,
                          onDecrement: () => setState(
                            () => _trimLines = _trimLines > 1
                                ? _trimLines - 1
                                : 1,
                          ),
                          onIncrement: () => setState(() => _trimLines++),
                        ),
                    ],
                  ),
                ),
                DemoSection(
                  title: '基础用法 + 前后缀 + 自定义样式与分隔符',
                  subtitle: 'preDataText / postDataText / moreStyle / lessStyle / delimiter',
                  child: ReadMoreText(
                    'Flutter is Google’s mobile UI open source framework to build high-quality native (super fast) interfaces for iOS and Android apps with the unified codebase. 😊😊😊',
                    trimMode: _trimMode,
                    trimLines: _trimLines,
                    trimLength: _trimLength,
                    preDataText: 'AMANDA',
                    preDataTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    postDataText: '[END]',
                    postDataTextStyle: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                    delimiter: ' ··· ',
                    delimiterStyle: const TextStyle(color: Colors.orange),
                    moreStyle: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.w600,
                    ),
                    lessStyle: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
                    trimCollapsedText: '展开更多',
                    trimExpandedText: ' 收起',
                  ),
                ),
                DemoSection(
                  title: '正则注解 (Annotations: URL / @提及 / #话题)',
                  subtitle: '点击高亮链接、@用户 或 #话题 触发交互回调',
                  child: ReadMoreText(
                    'Flutter(https://flutter.dev/) has its own UI components, along with an engine to render them on both the <@123> and <@456> platforms <@999> http://google.com #read_more. Most of those UI components conform to #Material Design. 😊😊😊',
                    trimMode: _trimMode,
                    trimLines: _trimLines,
                    trimLength: _trimLength,
                    colorClickableText: Colors.pink,
                    trimCollapsedText: '...Expand',
                    trimExpandedText: ' Collapse',
                    annotations: [
                      Annotation(
                        regExp: RegExp(
                          r'(?:(?:https?|ftp)://)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
                        ),
                        spanBuilder:
                            ({
                              required String text,
                              required TextStyle textStyle,
                            }) => TextSpan(
                              text: text,
                              style: textStyle.copyWith(
                                decoration: TextDecoration.underline,
                                color: Colors.green,
                              ),
                              recognizer: _createRecognizer(
                                () => _showMessage('URL: $text'),
                              ),
                            ),
                      ),
                      Annotation(
                        regExp: RegExp(r'<@(\d+)>'),
                        spanBuilder:
                            ({
                              required String text,
                              required TextStyle textStyle,
                            }) {
                              final user =
                                  _userMap[int.tryParse(
                                    text.substring(2, text.length - 1),
                                  )];
                              if (user == null) {
                                return TextSpan(
                                  text: '@unknown',
                                  style: textStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: _createRecognizer(
                                    () => _showMessage('User not found'),
                                  ),
                                );
                              }
                              return TextSpan(
                                text: '@$user',
                                style: textStyle.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: Colors.redAccent,
                                ),
                                recognizer: _createRecognizer(
                                  () => _showMessage('Mention: @$user'),
                                ),
                                children: [
                                  if (user == 'iOS')
                                    const TextSpan(text: ' Extra'),
                                ],
                              );
                            },
                      ),
                      Annotation(
                        regExp: RegExp('#(?:[a-zA-Z0-9_]+)'),
                        spanBuilder:
                            ({
                              required String text,
                              required TextStyle textStyle,
                            }) => TextSpan(
                              text: text,
                              style: textStyle.copyWith(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: _createRecognizer(
                                () => _showMessage('Hashtag: $text'),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
                DemoSection(
                  title: '外部 ValueNotifier 控制 & 禁止展开 (isExpandable: false)',
                  subtitle: '通过按钮同步外部 isCollapsed 状态，并对比不可点击展开模式',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReadMoreText(
                        'The Flutter framework builds its layout via the composition of widgets, everything that you construct programmatically is a widget and these are compiled together to create the user interface. 😊😊😊',
                        trimMode: _trimMode,
                        trimLines: _trimLines,
                        trimLength: _trimLength,
                        isCollapsed: _isCollapsed,
                        colorClickableText: Colors.pink,
                        trimCollapsedText: '...Read more',
                        trimExpandedText: ' Less',
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<bool>(
                        valueListenable: _isCollapsed,
                        builder: (context, collapsed, _) {
                          return FilledButton.tonal(
                            onPressed: () => _isCollapsed.value = !collapsed,
                            child: Text(collapsed ? '外部控制：展开文本' : '外部控制：收起文本'),
                          );
                        },
                      ),
                      const Divider(height: 20),
                      ReadMoreText(
                        'Non-expandable preview mode: tapping the suffix will not toggle expansion because isExpandable is set to false. Useful for summary cards.',
                        trimMode: _trimMode,
                        trimLines: _trimLines,
                        trimLength: _trimLength,
                        isExpandable: false,
                        colorClickableText: Colors.grey,
                        trimCollapsedText: ' (不可展开)',
                      ),
                    ],
                  ),
                ),
                DemoSection(
                  title:
                      '富文本构造 (ReadMoreText.rich) + richPreData / richPostData',
                  subtitle: '支持多样式 TextSpan 与局部手势点击',
                  child: ReadMoreText.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'The '),
                        const TextSpan(
                          text: 'Flutter framework ',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            letterSpacing: 2,
                          ),
                        ),
                        const TextSpan(
                          text: 'builds its layout via the composition of ',
                        ),
                        TextSpan(
                          text: 'widgets, ',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: _widgetsSpanRecognizer,
                        ),
                        const TextSpan(
                          text: 'everything that you construct programmatically is a widget and these are compiled together to create the user interface. 😊😊😊',
                        ),
                      ],
                    ),
                    richPreData: const TextSpan(
                      text: '[RICH] ',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    richPostData: const TextSpan(
                      text: ' ✓',
                      style: TextStyle(color: Colors.teal),
                    ),
                    trimMode: _trimMode,
                    trimLines: _trimLines,
                    trimLength: _trimLength,
                    colorClickableText: Colors.blueAccent,
                    trimCollapsedText: '...Read more',
                    trimExpandedText: ' Less',
                  ),
                ),
                DemoSection(
                  title: 'Unicode / Emoji 安全截断',
                  subtitle: '按 Runes 截断避免 Emoji 代理对被拆分乱码',
                  child: ReadMoreText(
                    '😊' * 120,
                    trimMode: _trimMode,
                    trimLines: _trimLines,
                    trimLength: _trimLength,
                    colorClickableText: Colors.blueAccent,
                    trimCollapsedText: '...More',
                    trimExpandedText: ' Less',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrimValueStepper extends StatelessWidget {
  const _TrimValueStepper({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: '),
        IconButton(icon: const Icon(Icons.remove), onPressed: onDecrement),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w600)),
        IconButton(icon: const Icon(Icons.add), onPressed: onIncrement),
      ],
    );
  }
}
