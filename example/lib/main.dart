import 'package:material_ui/material_ui.dart';

import 'pages/auto_size_text_field_page.dart';
import 'pages/auto_size_text_page.dart';
import 'pages/card_swiper_page.dart';
import 'pages/carousel_slider_page.dart';
import 'pages/k_chart_plus_page.dart';
import 'pages/read_more_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF02BB9F)),
        useMaterial3: true,
      ),
      title: 'XueHua Universal Widgets',
      home: const ShowcaseHomePage(),
    );
  }
}

class ShowcaseHomePage extends StatelessWidget {
  const ShowcaseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('XueHua Universal Widgets')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _ComponentNavCard(
            icon: Icons.short_text,
            title: 'ReadMoreText',
            subtitle: '长度/行数折叠、正则注解(URL/@/#)、富文本、外部状态同步、可拖拽宽度测试',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ReadMorePage()),
            ),
          ),
          _ComponentNavCard(
            icon: Icons.format_size,
            title: 'AutoSizeText',
            subtitle: '自动缩放、预设字号、步进粒度、单词折行、溢出替换与回调、分组字号同步',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AutoSizeTextPage()),
            ),
          ),
          _ComponentNavCard(
            icon: Icons.text_fields,
            title: 'AutoSizeTextField & FormField',
            subtitle: '自适应字号输入框、自适应宽度、前缀后缀、预设字号、溢出替换与表单校验',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AutoSizeTextFieldPage(),
              ),
            ),
          ),
          _ComponentNavCard(
            icon: Icons.view_carousel,
            title: 'CarouselSlider',
            subtitle: '无限轮播、居中放大(scale/height/zoom)、自动播放、横竖方向、控制器跳转与 Builder',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CarouselSliderPage(),
              ),
            ),
          ),
          _ComponentNavCard(
            icon: Icons.style,
            title: 'CardSwiper',
            subtitle: 'DEFAULT/STACK/TINDER/CUSTOM 布局、分页器与动效指示器、控制按钮、缩放淡入',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CardSwiperPage()),
            ),
          ),
          _ComponentNavCard(
            icon: Icons.candlestick_chart,
            title: 'KChartPlus & DepthChart',
            subtitle: '蜡烛图/分时线、主图(MA/EMA/BOLL/SAR)与副图(MACD/KDJ/RSI/WR/CCI)、深度图',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const KChartPlusPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentNavCard extends StatelessWidget {
  const _ComponentNavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
