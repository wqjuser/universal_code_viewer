import 'package:flutter/services.dart';
import 'package:universal_code_viewer/universal_code_viewer.dart';
import 'package:flutter/material.dart';

class UniversalCodeViewer extends StatefulWidget {
  final String code;
  final SyntaxStyle style;
  final bool showLineNumbers;
  final bool enableCopy;
  final bool isCodeLanguageView;
  final String? codeLanguage;
  final EdgeInsetsGeometry? padding;
  final Widget? copyWidget;

  const UniversalCodeViewer({
    super.key,
    required this.code,
    required this.style,
    this.showLineNumbers = true,
    this.enableCopy = true,
    this.isCodeLanguageView = true,
    this.codeLanguage,
    this.padding,
    this.copyWidget,
  });

  @override
  State<UniversalCodeViewer> createState() => _UniversalCodeViewerState();
}

class _UniversalCodeViewerState extends State<UniversalCodeViewer> {
  late final ScrollController _verticalScrollController;
  late final ScrollController _horizontalScrollController;
  late final List<String> _lines;
  late final UniversalSyntaxHighlighter _highlighter;

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _horizontalScrollController = ScrollController();
    _lines = widget.code.split('\n');
    _highlighter = UniversalSyntaxHighlighter(widget.code);
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding = widget.padding ?? const EdgeInsets.all(16);

    return Container(
      decoration: BoxDecoration(
        color: widget.style.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.style.baseStyle.color?.withOpacity(0.1) ?? Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: effectivePadding,
              child: _buildCodeContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.style.baseStyle.color?.withOpacity(0.1) ?? Colors.grey,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: widget.isCodeLanguageView
                ? Text(
                    widget.codeLanguage ?? _highlighter.detectedLanguage.toUpperCase(),
                    style: widget.style.baseStyle.copyWith(
                      color: widget.style.baseStyle.color?.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  )
                : const SizedBox(),
          ),
          if (widget.enableCopy) ...[
            widget.copyWidget ??
                IconButton(
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: widget.style.baseStyle.color?.withOpacity(0.5),
                  ),
                  tooltip: 'Copy to clipboard',
                  onPressed: () => _copyToClipboard(context),
                ),
          ]
        ],
      ),
    );
  }

  Widget _buildCodeContent() {
    return SelectionArea(
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showLineNumbers) _buildLineNumbers(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      _lines.length,
                      (index) => _buildCodeLine(_lines[index], index),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineNumbers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        _lines.length,
        (index) => Container(
          height: 24,
          padding: const EdgeInsets.only(right: 16, vertical: 4),
          child: Text(
            '${index + 1}',
            style: widget.style.baseStyle.copyWith(
              color: widget.style.baseStyle.color?.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeLine(String line, int lineIndex) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text.rich(
        TextSpan(
          children: _getLineSpans(line, lineIndex),
        ),
        style: widget.style.baseStyle,
      ),
    );
  }

  List<TextSpan> _getLineSpans(String line, int lineIndex) {
    final List<TextSpan> spans = [];
    final int lineStart = _lines.take(lineIndex).join('\n').length +
        (lineIndex > 0 ? 1 : 0);
    final int lineEnd = lineStart + line.length;

    final lineSpans = _highlighter.spans
        .where((span) => span.start < lineEnd && span.end > lineStart);

    int currentPosition = 0;

    for (var span in lineSpans) {
      final spanStartInLine = (span.start - lineStart).clamp(0, line.length);
      final spanEndInLine = (span.end - lineStart).clamp(0, line.length);

      if (currentPosition < spanStartInLine) {
        spans.add(TextSpan(
          text: line.substring(currentPosition, spanStartInLine),
        ));
      }

      if (spanStartInLine < spanEndInLine) {
        spans.add(TextSpan(
          text: line.substring(spanStartInLine, spanEndInLine),
          style: _getStyleForType(span.type),
        ));
      }

      currentPosition = spanEndInLine;
    }

    if (currentPosition < line.length) {
      spans.add(TextSpan(
        text: line.substring(currentPosition),
      ));
    }

    return spans;
  }

  TextStyle _getStyleForType(String type) {
    switch (type) {
      case 'keyword':
        return widget.style.keywordStyle;
      case 'class':
        return widget.style.classStyle;
      case 'method':
        return widget.style.methodStyle;
      case 'variable':
        return widget.style.variableStyle;
      case 'string':
        return widget.style.stringStyle;
      case 'number':
        return widget.style.numberStyle;
      case 'comment':
        return widget.style.commentStyle;
      case 'tag':
        return widget.style.tagStyle;
      case 'attribute':
        return widget.style.attributeStyle;
      case 'operator':
        return widget.style.operatorStyle;
      case 'punctuation':
        return widget.style.punctuationStyle;
      default:
        return widget.style.baseStyle;
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Code copied to clipboard'),
          backgroundColor: widget.style.backgroundColor.computeLuminance() > 0.5
              ? Colors.black87
              : Colors.white70,
          behavior: SnackBarBehavior.floating,
          width: 200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}