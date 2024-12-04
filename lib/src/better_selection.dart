import 'package:flutter/material.dart';

class BetterSelectionWidget extends StatefulWidget {
  final Widget child;
  final Color? selectionColor;
  final bool enableDoubleTapSelection;
  final VoidCallback? onSelectionChanged;

  const BetterSelectionWidget({
    super.key,
    required this.child,
    this.selectionColor = const Color(0xFF2196F3),
    this.enableDoubleTapSelection = true,
    this.onSelectionChanged,
  });

  @override
  State<BetterSelectionWidget> createState() => _BetterSelectionWidgetState();
}

class _BetterSelectionWidgetState extends State<BetterSelectionWidget> {
  String? _selectedText;

  void _handleSelectionChanged(String? text) {
    setState(() {
      _selectedText = text;
    });
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
        onDoubleTap: widget.enableDoubleTapSelection ? _handleDoubleTap : null,
        child: SelectionArea(
          child: widget.child,
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    // 这里实现双击选中单词的逻辑
    final text = _getTextFromContext();
    if (text != null) {
      final selection = _findWordBoundary(text);
      if (selection != null) {
        _updateSelection(selection);
      }
    }
  }

  String? _getTextFromContext() {
    // 从上下文中获取文本内容
    final element = context.findRenderObject() as RenderBox?;
    if (element == null) return null;

    // 尝试获取文本内容
    final textContent = widget.child.toString();
    return textContent;
  }

  TextSelection? _findWordBoundary(String text) {
    // 实现单词边界查找逻辑
    final pattern = RegExp(r'\b\w+\b');
    final matches = pattern.allMatches(text);

    // 简单实现：返回第一个匹配的单词
    if (matches.isNotEmpty) {
      final match = matches.first;
      return TextSelection(
        baseOffset: match.start,
        extentOffset: match.end,
      );
    }
    return null;
  }

  void _updateSelection(TextSelection selection) {
    // 更新选择
    final text = _getTextFromContext();
    if (text != null) {
      final selectedText = text.substring(
        selection.baseOffset,
        selection.extentOffset,
      );
      _handleSelectionChanged(selectedText);
    }
  }
}