import "dart:convert";

import "package:flutter_test/flutter_test.dart";

import "package:mathstep/services/json_parser.dart";

void main() {
  group('JsonParser', () {
    test('parses valid JSON payload with escaped latex', () {
      final rawResponse = jsonEncode({
        'problemStatement': 'f(x) = x^2 e^{-x}, x \\ge 0',
        'steps': [
          {
            'id': 'step1',
            'title': 'title',
            'description': 'desc',
            'latexExpression': 'f_{\\max} = f(2) = 4 e^{-2}',
          },
        ],
        'alternativeSolutions': <Map<String, dynamic>>[],
        'verification': {
          'domainCheck': 'x \\ge 0',
        },
      });

      final solution = JsonParser.parseSolutionResponse(rawResponse);

      expect(solution, isNotNull);
      expect(solution!.steps, isNotEmpty);

      final expression = solution.steps.first.latexExpression;
      expect(expression, isNotNull);
      expect(expression, contains('\\'));
      expect(expression, isNot(contains('__BACKSLASH__')));
    });

    test('parses JSON contained within surrounding text', () {
      final jsonContent = jsonEncode({
        'problemStatement': 'x^2 + 3x + 2 = 0',
        'steps': <Map<String, dynamic>>[],
      });

      final rawResponse = '''
The solution is provided below:

```json
$jsonContent
```

Let me know if you need anything else.
''';

      final solution = JsonParser.parseSolutionResponse(rawResponse);

      expect(solution, isNotNull);
      expect(solution!.problemStatement, 'x^2 + 3x + 2 = 0');
    });
  });
}
