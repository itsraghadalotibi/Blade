import 'package:flutter/material.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;

  const ExpandableTextWidget({
    Key? key,
    required this.text,
    this.style,
    this.maxLines = 4,
  }) : super(key: key);

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool isExpanded = false;
  bool exceedsMaxLines = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  void _checkTextOverflow() {
    final textStyle = widget.style ?? DefaultTextStyle.of(context).style;

    final span = TextSpan(
      text: widget.text,
      style: textStyle,
    );

    final tp = TextPainter(
      text: span,
      maxLines: widget.maxLines,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    tp.layout(maxWidth: MediaQuery.of(context).size.width);

    setState(() {
      exceedsMaxLines = tp.didExceedMaxLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.style ?? DefaultTextStyle.of(context).style;



    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: textStyle,
          maxLines: isExpanded ? null : widget.maxLines,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (exceedsMaxLines)
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                isExpanded ? 'Show less' : 'Show more',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: textStyle.fontSize,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
