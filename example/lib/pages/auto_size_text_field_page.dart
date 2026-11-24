import 'package:material_ui/material_ui.dart';
import 'package:xue_hua_universal_widgets/xue_hua_universal_widgets.dart';

import '../widgets/demo_section.dart';
import '../widgets/demo_switch_chip.dart';

class AutoSizeTextFieldPage extends StatefulWidget {
  const AutoSizeTextFieldPage({super.key});

  @override
  State<AutoSizeTextFieldPage> createState() => _AutoSizeTextFieldPageState();
}

class _AutoSizeTextFieldPageState extends State<AutoSizeTextFieldPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _basicController = TextEditingController(
    text: '输入更多内容观察字号自动缩小',
  );
  final TextEditingController _wrapWidthController = TextEditingController(
    text: '128.50',
  );
  final TextEditingController _presetController = TextEditingController(
    text: '预设字号梯度缩放',
  );
  final TextEditingController _overflowController = TextEditingController(
    text: '继续输入会触发溢出替换',
  );
  final TextEditingController _formController = TextEditingController(
    text: 'admin@example.com',
  );

  bool _multiline = false;
  bool _wrapWords = true;
  String? _savedFormValue;

  @override
  void dispose() {
    _basicController.dispose();
    _wrapWidthController.dispose();
    _presetController.dispose();
    _overflowController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('AutoSizeTextField & FormField')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            DemoSection(
              title: '基础全宽自适应输入框 (AutoSizeTextField)',
              subtitle: '支持单行 / 多行切换、minFontSize(10) ~ maxFontSize(28)、步进粒度',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      DemoSwitchChip(
                        label: '多行模式 (maxLines: null)',
                        value: _multiline,
                        onChanged: (v) => setState(() => _multiline = v),
                      ),
                      DemoSwitchChip(
                        label: 'wrapWords',
                        value: _wrapWords,
                        onChanged: (v) => setState(() => _wrapWords = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: _multiline ? 100 : 56,
                    child: AutoSizeTextField(
                      controller: _basicController,
                      fullwidth: true,
                      style: const TextStyle(fontSize: 28),
                      minFontSize: 10,
                      maxFontSize: 28,
                      stepGranularity: 1,
                      maxLines: _multiline ? null : 1,
                      wrapWords: _wrapWords,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '输入任意文本...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DemoSection(
              title: '自适应内容宽度 (fullwidth: false + minWidth + 前缀/后缀)',
              subtitle: '宽度随文本内容自动伸缩（适合金额、数量输入场景）',
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withAlpha(70),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AutoSizeTextField(
                    controller: _wrapWidthController,
                    fullwidth: false,
                    minWidth: 80,
                    minFontSize: 14,
                    maxFontSize: 32,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      prefixText: '¥ ',
                      suffixText: ' CNY',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ),
            DemoSection(
              title: '预设字号梯度 (presetFontSizes)',
              subtitle: '在 [28, 22, 16, 12] 档位中自动阶梯缩放',
              child: AutoSizeTextField(
                controller: _presetController,
                presetFontSizes: const [28, 22, 16, 12],
                style: const TextStyle(fontSize: 28),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'presetFontSizes: [28, 22, 16, 12]',
                ),
              ),
            ),
            DemoSection(
              title: '溢出替换 (overflowReplacement)',
              subtitle: '最小字号仍超出容器宽度时替换为自定义组件，支持一键恢复',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 220,
                    child: AutoSizeTextField(
                      controller: _overflowController,
                      minFontSize: 20,
                      maxFontSize: 24,
                      style: const TextStyle(fontSize: 24),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      overflowReplacement: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '文本超过最小字号限制，已展示 overflowReplacement 占位！',
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _overflowController.text =
                              '超长输入文本触发 overflowReplacement 显示效果演示字符串';
                        },
                        child: const Text('填充超长文本触发溢出'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          _overflowController.text = '短文本';
                        },
                        child: const Text('恢复短文本'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DemoSection(
              title: '表单集成与校验 (AutoSizeTextFormField)',
              subtitle: '支持 Form、validator、autovalidateMode、onSaved 与非全宽/全宽模式',
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AutoSizeTextFormField(
                      controller: _formController,
                      fullwidth: true,
                      minFontSize: 12,
                      maxFontSize: 24,
                      style: const TextStyle(fontSize: 24),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '邮箱地址 (含表单校验)',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入邮箱地址';
                        }
                        if (!value.contains('@')) {
                          return '邮箱格式不正确（需包含 @）';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() => _savedFormValue = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilledButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _formKey.currentState?.save();
                            }
                          },
                          child: const Text('校验并保存表单'),
                        ),
                        const SizedBox(width: 12),
                        if (_savedFormValue != null)
                          Expanded(
                            child: Text(
                              '已保存: $_savedFormValue',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
