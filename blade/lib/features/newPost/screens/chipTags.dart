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
    // Calculate the ideal chip width based on content with a maximum width
    List<Widget> chips = widget.options.map((option) {
      double screenWidth = MediaQuery.of(context).size.width;
      double chipWidth = screenWidth / 3 - 12;  // Assuming 3 chips per row minus spacing

      return Container(
        width: (option.length * 8 > chipWidth) ? chipWidth : null,  // Allow chips to grow but limit maximum width
        child: ChoiceChip(
          label: Text(
            option,
            overflow: TextOverflow.ellipsis,  // Use ellipsis for longer names
            style: TextStyle(color: (widget.initialTags.contains(option) ? Colors.white : Colors.black)),
          ),
          selected: widget.initialTags.contains(option),
          onSelected: (selected) {
            widget.onTagSelected(option, selected); // Call the passed callback
            setState(() {
              if (selected) {
                widget.initialTags.add(option);
              } else {
                widget.initialTags.remove(option);
              }
            });
          },
          selectedColor: const Color(0xFFFD5336),
          backgroundColor: Colors.grey[200],
        ),
      );
    }).toList();

    return Wrap(
      spacing: 8.0,  // Horizontal space between chips
      runSpacing: 8.0,  // Vertical space between chip rows
      alignment: WrapAlignment.start,  // Align chips to the start of the row
      children: chips,
    );
  }
}
