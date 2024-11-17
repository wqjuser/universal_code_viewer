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

import 'package:flutter/services.dart';
import 'package:universal_code_viewer/universal_code_viewer.dart';
import 'package:flutter/material.dart';

/// A customizable code viewer widget that supports syntax highlighting for multiple programming languages.
///
/// The [UniversalCodeViewer] widget provides a rich code viewing experience with features like
/// syntax highlighting, line numbers, copy functionality, and customizable themes.
///
/// Example usage:
/// ```dart
/// UniversalCodeViewer(
///   code: '''
///   void main() {
///     print("Hello, World!");
///   }
///   ''',
///   style: SyntaxHighlighterStyles.vscodeDark,
///   showLineNumbers: true,
///   enableCopy: true,
/// )
/// ```
class UniversalCodeViewer extends StatelessWidget {
  /// The source code to be displayed and highlighted.
  ///
  /// This parameter accepts any string containing valid source code. The widget will
  /// automatically detect the programming language and apply appropriate syntax highlighting.
  ///
  /// Example:
  /// ```dart
  /// final code = '''
  /// function greet(name) {
  ///   console.log(`Hello, ${name}!`);
  /// }
  /// ''';
  /// ```
  final String code;

  /// The syntax highlighting style to be applied to the code.
  ///
  /// This defines the color scheme and text styles for different code elements
  /// like keywords, strings, comments, etc. You can use predefined styles from
  /// [SyntaxHighlighterStyles] or create custom ones.
  ///
  /// Built-in styles include:
  /// - [SyntaxHighlighterStyles.vscodeDark]
  /// - [SyntaxHighlighterStyles.vscodeLight]
  /// - [SyntaxHighlighterStyles.githubDark]
  /// - [SyntaxHighlighterStyles.githubLight]
  /// - And more...
  ///
  /// Example:
  /// ```dart
  /// style: SyntaxHighlighterStyles.vscodeDark
  /// ```
  final SyntaxStyle style;

  /// Whether to show line numbers on the left side of the code.
  ///
  /// When true, displays line numbers starting from 1 for each line of code.
  /// Line numbers are styled with a slightly transparent color based on the theme.
  ///
  /// Defaults to `true`.
  ///
  /// Example:
  /// ```dart
  /// showLineNumbers: true  // Shows: 1, 2, 3, ...
  /// ```
  final bool showLineNumbers;

  /// Whether to show a copy button that allows users to copy the code to clipboard.
  ///
  /// When true, displays a copy icon button in the header that, when pressed,
  /// copies the entire code to the system clipboard and shows a confirmation snackbar.
  ///
  /// Defaults to `true`.
  ///
  /// Example:
  /// ```dart
  /// enableCopy: true  // Shows copy button
  /// ```
  final bool enableCopy;

  /// Whether to show the detected programming language label in the header.
  ///
  /// When true, displays the automatically detected language (or provided custom language)
  /// in the header section of the widget.
  ///
  /// Defaults to `true`.
  ///
  /// Example:
  /// ```dart
  /// isCodeLanguageView: true  // Shows "JAVASCRIPT", "PYTHON", etc.
  /// ```
  final bool isCodeLanguageView;

  /// Optional custom language label to display instead of the auto-detected one.
  ///
  /// When provided, this string will be displayed in the header instead of
  /// the automatically detected programming language.
  ///
  /// Example:
  /// ```dart
  /// codeLanguage: "TypeScript"  // Forces "TYPESCRIPT" label
  /// ```
  final String? codeLanguage;

  /// Custom padding for the code content area.
  ///
  /// Allows customizing the padding around the code content. If not provided,
  /// defaults to `EdgeInsets.all(16)`.
  ///
  /// Example:
  /// ```dart
  /// padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16)
  /// ```
  final EdgeInsetsGeometry? padding;

  /// Custom widget to replace the default copy button.
  ///
  /// When provided, this widget will be used instead of the default copy icon button.
  /// The custom widget should handle the copy functionality internally.
  ///
  /// Example:
  /// ```dart
  /// copyWidget: TextButton(
  ///   onPressed: () => Clipboard.setData(ClipboardData(text: code)),
  ///   child: Text('Copy Code'),
  /// )
  /// ```
  final Widget? copyWidget;

  /// Creates a UniversalCodeViewer widget.
  ///
  /// The [code] and [style] parameters are required. All other parameters are optional
  /// and have sensible defaults.
  ///
  /// Example:
  /// ```dart
  /// UniversalCodeViewer(
  ///   code: 'print("Hello, World!")',
  ///   style: SyntaxHighlighterStyles.vscodeDark,
  ///   showLineNumbers: true,
  ///   enableCopy: true,
  ///   isCodeLanguageView: true,
  ///   padding: EdgeInsets.all(16),
  /// )
  /// ```

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
          Container(
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
                          codeLanguage ??
                              highlighter.detectedLanguage.toUpperCase(),
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
          ),
          Padding(
            padding: effectivePadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showLineNumbers)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        lines.length,
                        (index) => Container(
                          height: 24,
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
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        lines.length,
                        (index) => Container(
                          height: 24,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildHighlightedLine(
                            lines[index],
                            highlighter,
                            index,
                            lines,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedLine(
    String line,
    UniversalSyntaxHighlighter highlighter,
    int lineIndex,
    List<String> allLines,
  ) {
    final List<TextSpan> spans = [];
    final int lineStart = allLines.take(lineIndex).join('\n').length +
        (lineIndex > 0 ? 1 : 0); // Account for newline characters
    final int lineEnd = lineStart + line.length;

    // Get spans that intersect with this line
    final lineSpans = highlighter.spans
        .where((span) => span.start < lineEnd && span.end > lineStart);

    int currentPosition = 0;

    for (var span in lineSpans) {
      // Convert global positions to line positions
      final spanStartInLine = (span.start - lineStart).clamp(0, line.length);
      final spanEndInLine = (span.end - lineStart).clamp(0, line.length);

      // Add unstyled text before the span
      if (currentPosition < spanStartInLine) {
        spans.add(TextSpan(
          text: line.substring(currentPosition, spanStartInLine),
          style: style.baseStyle,
        ));
      }

      // Add the styled span
      if (spanStartInLine < spanEndInLine) {
        spans.add(TextSpan(
          text: line.substring(spanStartInLine, spanEndInLine),
          style: _getStyleForType(span.type),
        ));
      }

      currentPosition = spanEndInLine;
    }

    // Add any remaining unstyled text
    if (currentPosition < line.length) {
      spans.add(TextSpan(
        text: line.substring(currentPosition),
        style: style.baseStyle,
      ));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      key: ValueKey('line-$lineIndex'), // Add key for better performance
    );
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
