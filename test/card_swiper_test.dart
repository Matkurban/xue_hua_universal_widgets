import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:xue_hua_universal_widgets/xue_hua_universal_widgets.dart';

void main() {
  group('Swiper loop mode layout and precision', () {
    testWidgets(
      'lays out at fractional width (560.4 x 315.2) without RenderSliverFixedExtentBoxAdaptor assertion',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: 560.4,
                height: 315.2,
                child: Swiper(
                  itemCount: 4,
                  loop: true,
                  itemBuilder: (context, index) => Text('Item $index'),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Item 0'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'lays out across various fractional widths and viewportFractions',
      (WidgetTester tester) async {
        for (final width in [320.7, 393.3333333333333, 412.7, 560.4]) {
          for (final fraction in [0.8, 1.0, 1.2]) {
            await tester.pumpWidget(
              Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: SizedBox(
                    width: width,
                    height: 315.2,
                    child: Swiper(
                      key: ValueKey('$width-$fraction'),
                      itemCount: 5,
                      loop: true,
                      viewportFraction: fraction,
                      itemBuilder: (context, index) => Text('Slide $index'),
                    ),
                  ),
                ),
              ),
            );
            expect(tester.takeException(), isNull);
          }
        }
      },
    );

    testWidgets('loops forward and backward seamlessly via controller', (
      WidgetTester tester,
    ) async {
      final controller = SwiperController();
      addTearDown(controller.dispose);
      final visited = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 560.4,
              height: 315.2,
              child: Swiper(
                controller: controller,
                itemCount: 3,
                loop: true,
                onIndexChanged: visited.add,
                itemBuilder: (context, index) => Text('Page $index'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Page 0'), findsOneWidget);

      // Backward from 0 wraps to 2.
      final prevFuture = controller.previous(animation: false);
      await tester.pumpAndSettle();
      await prevFuture;
      expect(find.text('Page 2'), findsOneWidget);

      // Forward from 2 wraps back to 0.
      final nextFuture = controller.next(animation: false);
      await tester.pumpAndSettle();
      await nextFuture;
      expect(find.text('Page 0'), findsOneWidget);

      // Move directly to index 1.
      final moveFuture = controller.move(1, animation: false);
      await tester.pumpAndSettle();
      await moveFuture;
      expect(find.text('Page 1'), findsOneWidget);

      expect(visited, [2, 0, 1]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports drag looping forward and backward', (
      WidgetTester tester,
    ) async {
      var currentIndex = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 560.4,
              height: 315.2,
              child: Swiper(
                itemCount: 3,
                loop: true,
                onIndexChanged: (i) => currentIndex = i,
                itemBuilder: (context, index) => Center(child: Text('P$index')),
              ),
            ),
          ),
        ),
      );

      // Drag right to go backward from 0 -> 2.
      await tester.drag(find.byType(Swiper), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(currentIndex, 2);
      expect(find.text('P2'), findsOneWidget);

      // Drag left to go forward from 2 -> 0.
      await tester.drag(find.byType(Swiper), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(currentIndex, 0);
      expect(find.text('P0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('works with pagination indicators and scale/fade transformer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 560.4,
                height: 315.2,
                child: Swiper(
                  itemCount: 4,
                  loop: true,
                  viewportFraction: 0.8,
                  scale: 0.9,
                  fade: 0.5,
                  indicatorLayout: PageIndicatorLayout.scale,
                  pagination: const SwiperPagination(),
                  itemBuilder: (context, index) => Text('Card $index'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Card 0'), findsOneWidget);
      expect(find.byType(PageIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('preserves finite bounds when loop is false', (
      WidgetTester tester,
    ) async {
      final controller = SwiperController();
      addTearDown(controller.dispose);
      var currentIndex = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 560.4,
              height: 315.2,
              child: Swiper(
                controller: controller,
                itemCount: 2,
                loop: false,
                onIndexChanged: (i) => currentIndex = i,
                itemBuilder: (context, index) => Text('Finite $index'),
              ),
            ),
          ),
        ),
      );

      final prevFuture = controller.previous(animation: false);
      await tester.pumpAndSettle();
      await prevFuture;
      expect(currentIndex, 0);

      final next1 = controller.next(animation: false);
      await tester.pumpAndSettle();
      await next1;
      expect(currentIndex, 1);

      final next2 = controller.next(animation: false);
      await tester.pumpAndSettle();
      await next2;
      expect(currentIndex, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles empty itemCount and vertical loop cleanly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 560.4,
              height: 315.2,
              child: Swiper(
                itemCount: 0,
                loop: true,
                itemBuilder: (context, index) => Text('Empty $index'),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 315.2,
              height: 560.4,
              child: Swiper(
                itemCount: 4,
                loop: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) => Text('Vertical $index'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Vertical 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
