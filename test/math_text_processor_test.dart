import 'package:flutter_test/flutter_test.dart';

import 'package:mathstep/utils/math_text_processor.dart';

void main() {
  group('MathTextProcessor', () {
    test('detects the presence of LaTeX markers', () {
      expect(MathTextProcessor.containsMath('plain text'), isFalse);
      expect(MathTextProcessor.containsMath(r'Try \sqrt{2} today'), isTrue);
    });

    test('splits prose and math segments without dropping spaces', () {
      const source = r'Area is given by $A = \pi r^2$ units.';
      final segments = MathTextProcessor.parseTextWithMath(source);

      expect(segments.length, 3);
      expect(segments[0].type, MathTextType.text);
      expect(segments[0].content, 'Area is given by ');
      expect(segments[1].type, MathTextType.math);
      expect(segments[1].content, r'A = \pi r^2');
      expect(segments[2].content, ' units.');
    });

    test('converts LaTeX snippets into plain text', () {
      final readable = MathTextProcessor.mathToReadableText(r'\frac{a}{b} + \sqrt{c}');
      expect(readable, '(a)/(b) + sqrt(c)');
    });
  });
}
