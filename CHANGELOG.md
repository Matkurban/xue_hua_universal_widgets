## 0.0.2

- **Dependencies**: Update `material_ui` to `^1.11.1` and `decimal` to `^3.2.7`.
- **Architecture & Code Quality**:
  - Refactored all 6 integrated widget modules (`read_more`, `auto_size_text`, `auto_size_text_field`, `card_swiper`, `carousel_slider`, `k_chart_plus`) to eliminate widget-returning helper methods, inline single-use widgets, encapsulate file-scoped repeated widgets into private widget classes, and organize shared widgets under dedicated `widgets/` directories.
  - Extracted shared font-size fitting engine (`AutoSizeTextFieldFitter`) for `AutoSizeTextField` and `AutoSizeTextFormField`.
- **Performance & Memory Optimizations**:
  - Properly disposed temporary `TextPainter` instances across `read_more`, `auto_size_text_field`, `k_chart_plus` renderers, indicators, and `DepthChart`.
  - Skipped redundant `TextPainter` measurements in `ReadMoreText` when using `TrimMode.length` and cached merged annotation `RegExp` patterns.
  - Fixed vertical grid line loop bounds (`columnSpace` -> `gridColumns`) in `MainRenderer`, `VolRenderer`, and `SecondaryRenderer` to eliminate hundreds of off-screen `drawLine` calls per frame.
  - Added `NumberFormat` instance caching in `NumberUtil` and reused `Paint`/`Path` instances across chart painting loops.
  - Replaced `MediaQuery.of(context)` with `MediaQuery.sizeOf(context)` / `MediaQuery.textScalerOf(context)` to minimize unnecessary rebuilds.
  - Simplified `DotSwiperPaginationBuilder` dot widget tree and implemented accurate `shouldRepaint` checks in `BaseChartPainter`, `ChartPainter`, `DepthChartPainter`, and `PageIndicator`.
- **Stability & Bug Fixes**:
  - Fixed `AutoSizeTextFormField` width over-scaling bug when `fullwidth: false`.
  - Fixed `CarouselSlider` unconditionally recreating/leaking `PageController` and resetting scroll position on parent rebuilds; added timer client guards and null-safe `remainder`.
  - Fixed `Swiper` controller update/disposal lifecycle leaks, loop precision layout handling, and `ScaleTransformBuilder` missing `alignment`.
  - Fixed `_RenderAutoSize.setupParentData` type check, `computeMinIntrinsicWidth` replacement measurement, `TextFitter` `==`/`hashCode` (`minLines` & `presetFontSizes` list equality), and `AutoSizeGroup` concurrent modification safety.
  - Fixed `KDJIndicator` null-dereference (`||` -> `&&`) and empty dataset crash, plus safe controller switching in `KChartWidget`.
- **Example & Tests**:
  - Expanded `example/` into a full showcase app with a dedicated interactive demo page for each of the 6 widget modules and shared `example/lib/widgets/`.
  - Added comprehensive unit and widget tests covering all 6 modules and example navigation.

## 0.0.1

* first commit
