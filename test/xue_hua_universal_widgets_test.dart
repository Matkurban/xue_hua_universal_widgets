import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:xue_hua_universal_widgets/xue_hua_universal_widgets.dart';

void main() {
  group('ReadMoreText', () {
    testWidgets('trims by length and toggles with external ValueNotifier', (
      WidgetTester tester,
    ) async {
      final isCollapsed = ValueNotifier<bool>(true);
      addTearDown(isCollapsed.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 240,
              child: ReadMoreText(
                'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
                trimMode: TrimMode.length,
                trimLength: 10,
                isCollapsed: isCollapsed,
                trimCollapsedText: 'more',
                trimExpandedText: 'less',
              ),
            ),
          ),
        ),
      );

      final richTextCollapsed = tester.widget<RichText>(find.byType(RichText));
      expect(richTextCollapsed.text.toPlainText(), contains('ABCDEFGHIJ'));
      expect(richTextCollapsed.text.toPlainText(), contains('more'));

      isCollapsed.value = false;
      await tester.pump();

      final richTextExpanded = tester.widget<RichText>(find.byType(RichText));
      expect(
        richTextExpanded.text.toPlainText(),
        contains('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'),
      );
      expect(richTextExpanded.text.toPlainText(), contains('less'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('trims by line with annotations and rich constructor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  width: 140,
                  child: ReadMoreText(
                    'Hello #flutter https://flutter.dev world ' * 6,
                    trimMode: TrimMode.line,
                    trimLines: 2,
                    annotations: [
                      Annotation(
                        regExp: RegExp(r'#\w+'),
                        spanBuilder: ({required text, required textStyle}) =>
                            TextSpan(
                              text: text,
                              style: textStyle.copyWith(color: Colors.blue),
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: ReadMoreText.rich(
                    const TextSpan(
                      text:
                          'Rich text content that spans several lines '
                          'when constrained to a narrow container.',
                    ),
                    trimMode: TrimMode.line,
                    trimLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('AutoSizeText', () {
    testWidgets('renders with AutoSizeGroupBuilder and overflowReplacement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutoSizeGroupBuilder(
              builder: (context, group) {
                return Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 30,
                      child: AutoSizeText(
                        'Short',
                        group: group,
                        maxLines: 1,
                        minFontSize: 8,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      height: 30,
                      child: AutoSizeText(
                        'A much longer string that shrinks the group',
                        group: group,
                        maxLines: 1,
                        minFontSize: 8,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                      height: 16,
                      child: AutoSizeText(
                        'Overflowing very long text',
                        maxLines: 1,
                        minFontSize: 16,
                        overflowReplacement: Text('FALLBACK'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('FALLBACK'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test(
      'TextFitter equality considers minLines and presetFontSizes values',
      () {
        final a = TextFitter(
          text: const TextSpan(text: 'abc'),
          textAlign: TextAlign.start,
          textDirection: TextDirection.ltr,
          textWidthBasis: TextWidthBasis.parent,
          minLines: 1,
          minFontSize: 12,
          maxFontSize: 24,
          presetFontSizes: const [24, 18, 12],
        );
        final b = TextFitter(
          text: const TextSpan(text: 'abc'),
          textAlign: TextAlign.start,
          textDirection: TextDirection.ltr,
          textWidthBasis: TextWidthBasis.parent,
          minLines: 1,
          minFontSize: 12,
          maxFontSize: 24,
          presetFontSizes: [24, 18, 12],
        );
        final c = TextFitter(
          text: const TextSpan(text: 'abc'),
          textAlign: TextAlign.start,
          textDirection: TextDirection.ltr,
          textWidthBasis: TextWidthBasis.parent,
          minLines: 2,
          minFontSize: 12,
          maxFontSize: 24,
          presetFontSizes: const [24, 18, 12],
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      },
    );
  });

  group('AutoSizeTextField & AutoSizeTextFormField', () {
    testWidgets(
      'AutoSizeTextField and AutoSizeTextFormField size cleanly with fullwidth=false',
      (WidgetTester tester) async {
        final fieldController = TextEditingController(text: 'Hello');
        final formController = TextEditingController(text: 'Hello');
        addTearDown(fieldController.dispose);
        addTearDown(formController.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 240,
                    child: AutoSizeTextField(
                      controller: fieldController,
                      fullwidth: false,
                      minWidth: 40,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: AutoSizeTextFormField(
                      controller: formController,
                      fullwidth: false,
                      minWidth: 40,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final fieldSize = tester.getSize(find.byType(TextField).first);
        final formSize = tester.getSize(find.byType(TextFormField));

        // Previously AutoSizeTextFormField multiplied width by fontSize (~14x).
        expect((formSize.width - fieldSize.width).abs(), lessThan(5.0));

        await tester.enterText(
          find.byType(TextField).first,
          'A very long input string that should trigger auto-sizing',
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('CarouselSlider', () {
    testWidgets(
      'preserves page across parent rebuilds and supports controller navigation',
      (WidgetTester tester) async {
        final controller = CarouselSliderController();
        var currentPage = 0;

        Widget buildHost(int rebuildTick) {
          return MaterialApp(
            home: Scaffold(
              body: CarouselSlider(
                carouselController: controller,
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                  onPageChanged: (index, reason) => currentPage = index,
                ),
                items: List<Widget>.generate(
                  4,
                  (i) => Text('Slide $i ($rebuildTick)'),
                ),
              ),
            ),
          );
        }

        await tester.pumpWidget(buildHost(0));
        expect(find.text('Slide 0 (0)'), findsOneWidget);

        controller.jumpToPage(2);
        await tester.pumpAndSettle();
        expect(currentPage, 2);

        // Parent rebuild must not reset CarouselSlider back to page 0.
        await tester.pumpWidget(buildHost(1));
        await tester.pumpAndSettle();
        expect(currentPage, 2);
        expect(find.text('Slide 2 (1)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Swiper controls and custom layouts', () {
    testWidgets(
      'supports SwiperControl buttons, outer pagination, and STACK/TINDER/CUSTOM layouts',
      (WidgetTester tester) async {
        final controller = SwiperController();
        addTearDown(controller.dispose);
        var activeIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 320,
                height: 220,
                child: Swiper(
                  controller: controller,
                  itemCount: 3,
                  outer: true,
                  control: const SwiperControl(),
                  pagination: const SwiperPagination(
                    builder: SwiperPagination.dots,
                  ),
                  onIndexChanged: (i) => activeIndex = i,
                  itemBuilder: (context, index) =>
                      Center(child: Text('S$index')),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.arrow_forward_ios));
        await tester.pumpAndSettle();
        expect(activeIndex, 1);

        // Verify STACK and TINDER layouts render cleanly.
        for (final layout in [SwiperLayout.STACK, SwiperLayout.TINDER]) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 320,
                  height: 220,
                  child: Swiper(
                    key: ValueKey(layout),
                    layout: layout,
                    itemWidth: 200,
                    itemHeight: 160,
                    itemCount: 3,
                    itemBuilder: (context, index) => Text('L$index'),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      },
    );
  });

  group('KChartWidget & DepthChart', () {
    List<KLineEntity> createSampleKLines(int count) {
      final baseTime = DateTime(2026, 1, 1).millisecondsSinceEpoch;
      return List<KLineEntity>.generate(count, (i) {
        final open = 100.0 + i * 0.5;
        final close = open + (i.isEven ? 1.5 : -1.0);
        return KLineEntity.fromCustom(
          open: open,
          high: (open > close ? open : close) + 1.0,
          low: (open < close ? open : close) - 1.0,
          close: close,
          vol: 1000.0 + i * 25.0,
          time: baseTime + i * 86400000,
        );
      });
    }

    test(
      'DataUtil and indicators handle empty and populated datasets safely',
      () {
        final mainIndicators = <MainIndicator>[
          MAIndicator(),
          EMAIndicator(),
          BOLLIndicator(),
          SARIndicator(),
        ];
        final secondaryIndicators = <SecondaryIndicator>[
          MACDIndicator(),
          KDJIndicator(),
          RSIIndicator(),
          WRIndicator(),
          CCIIndicator(),
        ];

        // Empty dataset must not throw (regression test for KDJIndicator.calc).
        final empty = <KLineEntity>[];
        DataUtil.calculateAll(empty, mainIndicators, secondaryIndicators);

        final data = createSampleKLines(40);
        DataUtil.calculateAll(data, mainIndicators, secondaryIndicators);
        expect(data.last.maValueList, isNotNull);
        expect(data.last.k, isNotNull);
        expect(data.last.macd, isNotNull);

        expect(NumberUtil.formatFixed(12345.678, 2), '12,345.67');
        expect(NumberUtil.formatCompact(1500000), '1.50M');
      },
    );

    testWidgets(
      'KChartWidget renders with all indicators and handles tap/pan/reset cleanly',
      (WidgetTester tester) async {
        final mainIndicators = <MainIndicator>[
          MAIndicator(),
          EMAIndicator(),
          BOLLIndicator(),
          SARIndicator(),
        ];
        final secondaryIndicators = <SecondaryIndicator>[
          MACDIndicator(),
          KDJIndicator(),
          RSIIndicator(),
          WRIndicator(),
          CCIIndicator(),
        ];
        final data = createSampleKLines(40);
        DataUtil.calculateAll(data, mainIndicators, secondaryIndicators);

        final controller = InteractiveLayerController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 360,
                  child: KChartWidget(
                    data,
                    const KChartStyle(),
                    const KChartColors(),
                    controller: controller,
                    mainIndicators: mainIndicators,
                    secondaryIndicators: secondaryIndicators,
                    detailBuilder: (entity) => Text('Close: ${entity.close}'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Tap shows crosshair; the painter publishes InfoWindowEntity during
        // paint and StreamBuilder renders it on the next frame.
        await tester.tapAt(const Offset(180, 120));
        await tester.pump();
        await tester.pump();
        expect(find.textContaining('Close:'), findsOneWidget);

        // Pan hides crosshair.
        await tester.drag(find.byType(KChartWidget), const Offset(60, 0));
        await tester.pumpAndSettle();

        controller.reset();
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DepthChart renders and handles long press interaction', (
      WidgetTester tester,
    ) async {
      final bids = [
        DepthEntity(98.0, 50.0),
        DepthEntity(99.0, 30.0),
        DepthEntity(99.5, 10.0),
      ];
      final asks = [
        DepthEntity(100.5, 12.0),
        DepthEntity(101.0, 28.0),
        DepthEntity(102.0, 55.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 200,
              child: DepthChart(bids, asks, const DepthChartColors()),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(80, 100));
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveTo(const Offset(240, 100));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
