/*
 * Copyright (c) 2024 CodeFusionBit. All rights reserved.
 * Author: Hitesh Sapra
 *
 * This software is the confidential and proprietary information of CodeFusionBit.
 * You shall not disclose such confidential information and shall use it only in
 * accordance with the terms of the license agreement you entered into with
 * CodeFusionBit.
 *
 * Website: https://codefusionbit.com
 * Contact: info@codefusionbit.com
 */

import 'dart:ui';
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
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.code;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlighter = UniversalSyntaxHighlighter(widget.code);
    final lines = widget.code.split('\n');
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
          _buildHeader(context, highlighter),
          Padding(
            padding: effectivePadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showLineNumbers) _buildLineNumbers(lines),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _buildCodeContent(highlighter, lines, context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UniversalSyntaxHighlighter highlighter) {
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
                    widget.codeLanguage ?? highlighter.detectedLanguage.toUpperCase(),
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

  Widget _buildLineNumbers(List<String> lines) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          lines.length,
          (index) => SizedBox(
            height: 24,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${index + 1}',
                style: widget.style.baseStyle.copyWith(
                  color: widget.style.baseStyle.color?.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeContent(UniversalSyntaxHighlighter highlighter, List<String> lines, BuildContext context) {
    final List<TextSpan> allCodeSpans = [];
    int currentPosition = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineSpans = _getLineSpans(
        line,
        highlighter,
        currentPosition,
        lines,
        i,
      );

      allCodeSpans.addAll(lineSpans);

      if (i < lines.length - 1) {
        allCodeSpans.add(TextSpan(
          text: '\n',
          style: widget.style.baseStyle,
        ));
      }

      currentPosition += line.length + (i < lines.length - 1 ? 1 : 0);
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width -
                (widget.showLineNumbers ? 60 : 32) -
                (widget.padding?.horizontal ?? 32),
          ),
          child: SelectableText.rich(
            TextSpan(children: allCodeSpans),
            style: widget.style.baseStyle,
            contextMenuBuilder: (context, editableTextState) {
              return AdaptiveTextSelectionToolbar.editableText(
                editableTextState: editableTextState,
              );
            },
            onSelectionChanged: (selection, cause) {
              // 可以在这里处理选择变化事件，如果需要的话
            },
            // 保留跳转的双击手势
            enableInteractiveSelection: true,
            // 使得文本可以被选择和复制
            showCursor: false,
            // 不显示光标，因为这是只读的代码视图
            minLines: 1,
            maxLines: null,
          ),
        ),
      ),
    );
  }

  List<TextSpan> _getLineSpans(
    String line,
    UniversalSyntaxHighlighter highlighter,
    int lineStart,
    List<String> allLines,
    int lineIndex,
  ) {
    final List<TextSpan> spans = [];
    final int lineEnd = lineStart + line.length;

    final lineSpans = highlighter.spans.where((span) => span.start < lineEnd && span.end > lineStart);

    int currentPosition = 0;

    for (var span in lineSpans) {
      final spanStartInLine = (span.start - lineStart).clamp(0, line.length);
      final spanEndInLine = (span.end - lineStart).clamp(0, line.length);

      if (currentPosition < spanStartInLine) {
        spans.add(TextSpan(
          text: line.substring(currentPosition, spanStartInLine),
          style: widget.style.baseStyle,
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
        style: widget.style.baseStyle,
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
          backgroundColor: widget.style.backgroundColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white70,
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
