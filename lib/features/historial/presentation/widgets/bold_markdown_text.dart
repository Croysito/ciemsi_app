import 'package:flutter/material.dart';

class BoldMarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  const BoldMarkdownText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final baseStyle = defaultStyle.merge(style);

    return RichText(
      text: TextSpan(style: baseStyle, children: _buildSpans(baseStyle)),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }

  List<TextSpan> _buildSpans(TextStyle baseStyle) {
    final spans = <TextSpan>[];
    var index = 0;
    var bold = false;

    while (index < text.length) {
      final marker = text.indexOf('**', index);
      if (marker == -1) {
        spans.add(_span(text.substring(index), bold, baseStyle));
        break;
      }

      if (marker > index) {
        spans.add(_span(text.substring(index, marker), bold, baseStyle));
      }

      bold = !bold;
      index = marker + 2;
    }

    return spans;
  }

  TextSpan _span(String value, bool bold, TextStyle baseStyle) {
    return TextSpan(
      text: value,
      style: bold ? baseStyle.copyWith(fontWeight: FontWeight.bold) : baseStyle,
    );
  }
}
