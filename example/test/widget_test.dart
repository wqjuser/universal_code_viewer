// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

/*
 *
 * Copyright (c) 2024 CodeFusionBit. All rights reserved.
 * Author: Hitesh Sapra
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_code_viewer/universal_code_viewer.dart';

void main() {
  const sampleDartCode = '''
void main() {
  print("Hello, World!");
}
''';

  group('UniversalCodeViewer Widget Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Using the new method for mock handlers
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            return true;
          }
          if (methodCall.method == 'Clipboard.getData') {
            return {'text': sampleDartCode};
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('renders code content correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: Scaffold(
              body: Center(
                child: UniversalCodeViewer(
                  code: sampleDartCode,
                  style: SyntaxHighlighterStyles.vscodeDark,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('void main() {'), findsOneWidget);
      expect(find.text('  print("Hello, World!");'), findsOneWidget);
      expect(find.text('}'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

      final container = find.byType(Container).first;
      final decoration =
          tester.widget<Container>(container).decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF1E1E1E)));
    });

    testWidgets('copies code to clipboard when copy button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: Scaffold(
              body: Center(
                child: UniversalCodeViewer(
                  code: sampleDartCode,
                  style: SyntaxHighlighterStyles.vscodeDark,
                  enableCopy: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final copyButton = find.byIcon(Icons.copy_rounded);
      expect(copyButton, findsOneWidget);
      await tester.tap(copyButton);
      await tester.pumpAndSettle();

      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      expect(clipboardData?.text, equals(sampleDartCode));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('Code copied to clipboard'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('applies custom padding correctly',
        (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(24.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: Scaffold(
              body: Center(
                child: UniversalCodeViewer(
                  code: sampleDartCode,
                  style: SyntaxHighlighterStyles.vscodeDark,
                  padding: customPadding,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('handles empty code gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: Scaffold(
              body: Center(
                child: UniversalCodeViewer(
                  code: '',
                  style: SyntaxHighlighterStyles.vscodeDark,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(UniversalCodeViewer), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('supports theme changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: Scaffold(
              body: Center(
                child: UniversalCodeViewer(
                  code: sampleDartCode,
                  style: SyntaxHighlighterStyles.vscodeDark,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      Container darkContainer =
          tester.widget<Container>(find.byType(Container).first);
      BoxDecoration darkDecoration = darkContainer.decoration as BoxDecoration;
      expect(darkDecoration.color, equals(const Color(0xFF1E1E1E)));

      await tester.pumpWidget(
        const MaterialApp(
          home: Material(
            child: Scaffold(
              body: Center(
                child: UniversalCodeViewer(
                  code: sampleDartCode,
                  style: SyntaxHighlighterStyles.githubLight,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      Container lightContainer =
          tester.widget<Container>(find.byType(Container).first);
      BoxDecoration lightDecoration =
          lightContainer.decoration as BoxDecoration;
      expect(lightDecoration.color, equals(Colors.white));
    });
  });
}
