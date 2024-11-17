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

import 'package:flutter/material.dart';
import 'package:universal_code_viewer/universal_code_viewer.dart';

void main() {
  runApp(const SyntaxHighlighterDemo());
}

class SyntaxHighlighterDemo extends StatelessWidget {
  const SyntaxHighlighterDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Universal Code Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final Map<String, String> codeExamples = {
    'Dart': '''
void main() {
  // Example of a Dart class
  final calculator = Calculator();
  print(calculator.add(5).multiply(2).result);  // Outputs: 10
}

class Calculator {
  double result = 0;
  
  Calculator add(double value) {
    result += value;
    return this;
  }
  
  Calculator multiply(double value) {
    result *= value;
    return this;
  }
}
''',
    'Python': '''
def fibonacci(n: int) -> list[int]:
    """Generate Fibonacci sequence up to n"""
    sequence = [0, 1]
    while sequence[-1] <= n:
        sequence.append(sequence[-1] + sequence[-2])
    return sequence[:-1]

# Example usage with type hints
def calculate_stats(numbers: list[int]) -> dict[str, float]:
    """Calculate basic statistics for a list of numbers"""
    return {
        "mean": sum(numbers) / len(numbers),
        "min": min(numbers),
        "max": max(numbers)
    }

# Test the functions
if __name__ == "__main__":
    fib_sequence = fibonacci(100)
    stats = calculate_stats(fib_sequence)
    print(f"Statistics: {stats}")
''',
    'JavaScript': '''
// Modern JavaScript example with ES6+ features
class DataProcessor {
  constructor(data) {
    this.data = data;
  }

  async processData() {
    try {
      // Using modern JS features
      const results = await Promise.all(
        this.data.map(async (item) => {
          const processed = await this.transform(item);
          return {
            ...processed,
            timestamp: new Date().toISOString()
          };
        })
      );

      return results.filter(item => item.value > 0)
                   .sort((a, b) => b.value - a.value);
    } catch (error) {
      console.error(`Processing failed: error`);
      throw error;
    }
  }

  async transform(item) {
    // Simulate async processing
    return new Promise(resolve => {
      setTimeout(() => {
        resolve({
          id: item.id,
          value: item.data * 2
        });
      }, 100);
    });
  }
}
''',
    'HTML': '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modern HTML Example</title>
    <style>
        .container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            padding: 20px;
        }
        .card {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <article class="card">
            <header>
                <h2>Modern HTML Features</h2>
            </header>
            <main>
                <p>Examples of modern HTML5 elements and attributes:</p>
                <details>
                    <summary>Click to expand</summary>
                    <ul>
                        <li>Semantic HTML5 elements</li>
                        <li>Modern attributes</li>
                        <li>Grid layout</li>
                    </ul>
                </details>
            </main>
            <footer>
                <small>Last updated: 2024</small>
            </footer>
        </article>
    </div>
</body>
</html>
''',
  };

  String currentLanguage = 'Dart';
  SyntaxStyle currentTheme = SyntaxHighlighterStyles.vscodeDark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universal Code Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showThemeSelector,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLanguageSelector(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: UniversalCodeViewer(
                  code: codeExamples[currentLanguage]!,
                  style: currentTheme,
                  codeLanguage: currentLanguage.toUpperCase(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: codeExamples.keys.map((language) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(language),
              selected: currentLanguage == language,
              onSelected: (selected) {
                if (selected) {
                  setState(() => currentLanguage = language);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('VSCode Dark'),
                onTap: () => _updateTheme(SyntaxHighlighterStyles.vscodeDark),
              ),
              ListTile(
                title: const Text('VSCode Light'),
                onTap: () => _updateTheme(SyntaxHighlighterStyles.vscodeLight),
              ),
              ListTile(
                title: const Text('GitHub Dark'),
                onTap: () => _updateTheme(SyntaxHighlighterStyles.githubDark),
              ),
              ListTile(
                title: const Text('GitHub Light'),
                onTap: () => _updateTheme(SyntaxHighlighterStyles.githubLight),
              ),
              ListTile(
                title: const Text('Monokai Pro'),
                onTap: () => _updateTheme(SyntaxHighlighterStyles.monokaiPro),
              ),
              ListTile(
                title: const Text('Dracula'),
                onTap: () => _updateTheme(SyntaxHighlighterStyles.draculaTheme),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateTheme(SyntaxStyle newTheme) {
    setState(() => currentTheme = newTheme);
    Navigator.pop(context);
  }
}

// Example page showing multiple highlighters
class MultipleHighlightersExample extends StatelessWidget {
  const MultipleHighlightersExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Highlighters')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Python with VSCode Dark:'),
            UniversalCodeViewer(
              code: '''
              def greet(name: str) -> str:
                  return f"Hello, {name}!"
              ''',
              style: SyntaxHighlighterStyles.vscodeDark,
            ),
            SizedBox(height: 20),
            Text('JavaScript with GitHub Light:'),
            UniversalCodeViewer(
              code: '''
              function calculateTotal(items) {
                return items
                  .filter(item => item.inStock)
                  .reduce((sum, item) => sum + item.price, 0);
              }
              ''',
              style: SyntaxHighlighterStyles.githubLight,
            ),
            SizedBox(height: 20),
            Text('HTML with Monokai Pro:'),
            UniversalCodeViewer(
              code: '''
              <div class="card">
                <h2>Hello World</h2>
                <p>This is a sample card.</p>
              </div>
              ''',
              style: SyntaxHighlighterStyles.monokaiPro,
            ),
          ],
        ),
      ),
    );
  }
}
