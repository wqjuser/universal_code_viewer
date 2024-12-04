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

class UniversalCodeViewer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final highlighter = UniversalSyntaxHighlighter(code);
    final lines = code.split('\n');
    final effectivePadding = padding ?? const EdgeInsets.all(16);

    return Container(
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: style.baseStyle.color?.withOpacity(0.1) ?? Colors.grey,
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
                if (showLineNumbers) _buildLineNumbers(lines),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _buildCodeContent(highlighter, lines,context),
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
            color: style.baseStyle.color?.withOpacity(0.1) ?? Colors.grey,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: isCodeLanguageView
                ? Text(
              codeLanguage ?? highlighter.detectedLanguage.toUpperCase(),
              style: style.baseStyle.copyWith(
                color: style.baseStyle.color?.withOpacity(0.5),
                fontSize: 12,
              ),
            )
                : const SizedBox(),
          ),
          if (enableCopy) ...[
            copyWidget ??
                IconButton(
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: style.baseStyle.color?.withOpacity(0.5),
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
                style: style.baseStyle.copyWith(
                  color: style.baseStyle.color?.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeContent(UniversalSyntaxHighlighter highlighter, List<String> lines,BuildContext context) {
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

      // 添加换行符，除了最后一行
      if (i < lines.length - 1) {
        allCodeSpans.add(TextSpan(
          text: '\n',
          style: style.baseStyle,
        ));
      }

      currentPosition += line.length + (i < lines.length - 1 ? 1 : 0);
    }

    return ScrollConfiguration(
      // 禁用默认的滚动行为
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      child: SelectionArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // 确保内容至少和父容器一样宽
              minWidth: MediaQuery.of(context).size.width -
                  (showLineNumbers ? 60 : 32) - // 减去行号宽度和padding
                  (padding?.horizontal ?? 32),
            ),
            child: SelectableText.rich(
              TextSpan(children: allCodeSpans),
              style: style.baseStyle,
            ),
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

    // 获取与该行相交的spans
    final lineSpans = highlighter.spans
        .where((span) => span.start < lineEnd && span.end > lineStart);

    int currentPosition = 0;

    for (var span in lineSpans) {
      // 转换为行内位置
      final spanStartInLine = (span.start - lineStart).clamp(0, line.length);
      final spanEndInLine = (span.end - lineStart).clamp(0, line.length);

      // 添加未样式化的文本
      if (currentPosition < spanStartInLine) {
        spans.add(TextSpan(
          text: line.substring(currentPosition, spanStartInLine),
          style: style.baseStyle,
        ));
      }

      // 添加样式化的span
      if (spanStartInLine < spanEndInLine) {
        spans.add(TextSpan(
          text: line.substring(spanStartInLine, spanEndInLine),
          style: _getStyleForType(span.type),
        ));
      }

      currentPosition = spanEndInLine;
    }

    // 添加剩余的未样式化文本
    if (currentPosition < line.length) {
      spans.add(TextSpan(
        text: line.substring(currentPosition),
        style: style.baseStyle,
      ));
    }

    return spans;
  }

  TextStyle _getStyleForType(String type) {
    switch (type) {
      case 'keyword':
        return style.keywordStyle;
      case 'class':
        return style.classStyle;
      case 'method':
        return style.methodStyle;
      case 'variable':
        return style.variableStyle;
      case 'string':
        return style.stringStyle;
      case 'number':
        return style.numberStyle;
      case 'comment':
        return style.commentStyle;
      case 'tag':
        return style.tagStyle;
      case 'attribute':
        return style.attributeStyle;
      case 'operator':
        return style.operatorStyle;
      case 'punctuation':
        return style.punctuationStyle;
      default:
        return style.baseStyle;
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Code copied to clipboard'),
          backgroundColor: style.backgroundColor.computeLuminance() > 0.5
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