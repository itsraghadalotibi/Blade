import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChipTag extends StatefulWidget {
  final List<String> initialTags;
  final List<String> options;
  final Function(String, bool) onTagSelected;

  const ChipTag({
    super.key,
    required this.initialTags,
    required this.options,
    required this.onTagSelected,
  });

  @override
  State<ChipTag> createState() => _ChipTagState();
}

class _ChipTagState extends State<ChipTag> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: widget.options.map((option) {
        return ChoiceChip(
          label: Text(option),
          selected: widget.initialTags.contains(option),
          onSelected: (selected) {
            widget.onTagSelected(option, selected); // Call the passed callback
          },
          selectedColor: const Color(0xFFFD5336),
          backgroundColor: Colors.grey[200],
        );
      }).toList(),
    );
  }
}
