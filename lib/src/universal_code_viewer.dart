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
  late final List<String> _lines;
  late final UniversalSyntaxHighlighter _highlighter;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _lines = widget.code.split('\n');
    _highlighter = UniversalSyntaxHighlighter(widget.code);
  }

  @override
  void dispose() {
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
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _horizontalScrollController,
          child: SizedBox(
            width: _calculateContentWidth(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showLineNumbers) _buildLineNumbers(),
                Expanded(
                  child: _buildCodeLines(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateContentWidth() {
    // 计算最长行的宽度，这里使用一个估算值
    // 你可以根据实际情况调整计算方法
    final longestLine = _lines.reduce((a, b) => a.length > b.length ? a : b);
    return (longestLine.length * 10.0) + (widget.showLineNumbers ? 60.0 : 0.0);
  }

  Widget _buildLineNumbers() {
    return Container(
      width: 60,
      padding: const EdgeInsets.only(right: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _lines.length,
        itemBuilder: (context, index) => Container(
          height: 24,
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.centerRight,
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

  Widget _buildCodeLines() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: _lines.length,
      itemBuilder: (context, index) => _buildCodeLine(_lines[index], index),
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