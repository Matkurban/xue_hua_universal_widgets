import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('ShowcaseHomePage lists and opens all 6 component demo pages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final entries = <String>[
      'ReadMoreText',
      'AutoSizeText',
      'AutoSizeTextField & FormField',
      'CarouselSlider',
      'CardSwiper',
      'KChartPlus & DepthChart',
    ];

    for (final title in entries) {
      expect(find.text(title), findsOneWidget);
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();

      // Page opens with matching AppBar title and zero exceptions.
      expect(find.text(title), findsWidgets);
      expect(tester.takeException(), isNull);

      // Navigate back to ShowcaseHomePage.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
