import 'package:flutter/material.dart';

class BetterSelectionWidget extends StatefulWidget {
  final Widget child;
  final Color? selectionColor;
  final bool enableDoubleTapSelection;
  final VoidCallback? onSelectionChanged;

  const BetterSelectionWidget({
    super.key,
    required this.child,
    this.selectionColor,
    this.enableDoubleTapSelection = true,
    this.onSelectionChanged,
  });

  @override
  State<BetterSelectionWidget> createState() => _BetterSelectionWidgetState();
}

class _BetterSelectionWidgetState extends State<BetterSelectionWidget> {
  final FocusNode _focusNode = FocusNode();
  final SelectionOverlay? _selectionOverlay = null;
  Offset? _lastTapDownPosition;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _lastTapDownPosition = details.globalPosition;
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    if (!widget.enableDoubleTapSelection) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final TextSpan? textSpan = _findTextSpanAtPosition(details.localPosition);
    if (textSpan == null) return;

    final String text = textSpan.toPlainText();
    final int offset = _getOffsetForPosition(details.localPosition, text);
    if (offset < 0) return;

    _selectWordAt(text, offset);
  }

  TextSpan? _findTextSpanAtPosition(Offset position) {
    if (widget.child is Text) {
      final Text textWidget = widget.child as Text;
      if (textWidget.textSpan != null) {
        return textWidget.textSpan as TextSpan;
      }
    } else if (widget.child is RichText) {
      final RichText richText = widget.child as RichText;
      return richText.text as TextSpan;
    }
    return null;
  }

  int _getOffsetForPosition(Offset position, String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.getPositionForOffset(position).offset;
  }

  void _selectWordAt(String text, int offset) {
    final RegExp wordBoundary = RegExp(r'\b\w+\b');
    final matches = wordBoundary.allMatches(text);

    for (final match in matches) {
      if (offset >= match.start && offset <= match.end) {
        _updateSelection(match.start, match.end);
        return;
      }
    }
  }

  void _updateSelection(int start, int end) {
    // 使用 flutter/services.dart 中的剪贴板服务
    final TextSelection selection = TextSelection(
      baseOffset: start,
      extentOffset: end,
    );

    // 通知选择变化
    widget.onSelectionChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: widget.selectionColor?.withOpacity(0.3) ??
              Theme.of(context).textSelectionTheme.selectionColor,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _handleTapDown,
        onDoubleTapDown: _handleDoubleTapDown,
        child: SelectionArea(
          focusNode: _focusNode,
          child: widget.child,
        ),
      ),
    );
  }
}