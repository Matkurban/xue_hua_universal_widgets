import 'package:material_ui/material_ui.dart';

/// Shared compact toggle switch chip used in component control panels.
class DemoSwitchChip extends StatelessWidget {
  const DemoSwitchChip({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      visualDensity: VisualDensity.compact,
    );
  }
}
