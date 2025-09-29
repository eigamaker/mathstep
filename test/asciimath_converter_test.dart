import 'package:flutter_test/flutter_test.dart';
import 'package:mathstep/utils/asciimath_converter.dart';

void main() {
  group('AsciiMathConverter', () {
    group('calculatorToAsciiMath', () {
      test('基本的な数式の変換', () {
        expect(
          AsciiMathConverter.calculatorToAsciiMath('x^2 + 3*x + 2'),
          equals('x^2 + 3x + 2'),
        );
      });

      test('分数の変換', () {
        expect(
          AsciiMathConverter.calculatorToAsciiMath('frac(1,2)'),
          equals('(1)/(2)'),
        );
        
        expect(
          AsciiMathConverter.calculatorToAsciiMath('a/b'),
          equals('(a)/(b)'),
        );
      });

      test('関数の変換', () {
        expect(
          AsciiMathConverter.calculatorToAsciiMath('sin(x)'),
          equals('sin(x)'),
        );
        
        expect(
          AsciiMathConverter.calculatorToAsciiMath('sqrt(x)'),
          equals('sqrt(x)'),
        );
      });

      test('累乗の変換', () {
        expect(
          AsciiMathConverter.calculatorToAsciiMath('pow(x,2)'),
          equals('x^2'),
        );
        
        expect(
          AsciiMathConverter.calculatorToAsciiMath('x^(n+1)'),
          equals('x^(n+1)'),
        );
      });

      test('積分の変換', () {
        expect(
          AsciiMathConverter.calculatorToAsciiMath('integral(0,1,x^2,x)'),
          equals('int(x^2,  x) from 0 to 1'),
        );
        
        expect(
          AsciiMathConverter.calculatorToAsciiMath('int(x^2,x)'),
          equals('int(x^2, x)'),
        );
      });

      test('総和の変換', () {
        expect(
          AsciiMathConverter.calculatorToAsciiMath('sum(i=1,10,i^2)'),
          equals('sum(i=1, 10, i^2)'),
        );
      });

      test('複雑な数式の変換', () {
        expect(
          AsciiMathConverter.calculatorToAsciiMath('frac(x^2 + 1, sqrt(x))'),
          equals('(x^2 + (1))/(() sqrt(x))'),
        );
      });
    });

    group('asciiMathToLatex', () {
      test('基本的な数式の変換', () {
        expect(
          AsciiMathConverter.asciiMathToLatex('x^2 + 3x + 2'),
          equals('x^{2} + 3x + 2'),
        );
      });

      test('分数の変換', () {
        expect(
          AsciiMathConverter.asciiMathToLatex('(a)/(b)'),
          equals('\\frac{a}{b}'),
        );
        
        expect(
          AsciiMathConverter.asciiMathToLatex('a/b'),
          equals('\\frac{a}{b}'),
        );
      });

      test('平方根の変換', () {
        expect(
          AsciiMathConverter.asciiMathToLatex('sqrt(x)'),
          equals('\\sqrt{x}'),
        );
      });

      test('関数の変換', () {
        expect(
          AsciiMathConverter.asciiMathToLatex('sin(x)'),
          equals('\\sin(x)'),
        );
        
        expect(
          AsciiMathConverter.asciiMathToLatex('log(x)'),
          equals('\\log(x)'),
        );
      });

      test('積分の変換', () {
        expect(
          AsciiMathConverter.asciiMathToLatex('int(x^2, x)'),
          equals('\\int x^{2} dx'),
        );
      });

      test('総和の変換', () {
        expect(
          AsciiMathConverter.asciiMathToLatex('sum(i=1, n, i^2)'),
          equals('\\sum_{i=1}^{n} i^{2}'),
        );
      });

      test('数学記号の変換', () {
        expect(
          AsciiMathConverter.asciiMathToLatex('pi'),
          equals('\\pi'),
        );
        
        expect(
          AsciiMathConverter.asciiMathToLatex('inf'),
          equals('\\infty'),
        );
      });
    });

    group('normalizeChatGptResponse', () {
      test('LaTeX形式の正規化', () {
        expect(
          AsciiMathConverter.normalizeChatGptResponse('\\frac{a}{b}'),
          equals('(a)/(b)'),
        );
        
        expect(
          AsciiMathConverter.normalizeChatGptResponse('\\sqrt{x}'),
          equals('sqrt(x)'),
        );
        
        expect(
          AsciiMathConverter.normalizeChatGptResponse('x^{2}'),
          equals('x^2'),
        );
      });

      test('関数の正規化', () {
        expect(
          AsciiMathConverter.normalizeChatGptResponse('\\sin(x)'),
          equals('sin(x)'),
        );
        
        expect(
          AsciiMathConverter.normalizeChatGptResponse('\\log(x)'),
          equals('log(x)'),
        );
      });

      test('数学記号の正規化', () {
        expect(
          AsciiMathConverter.normalizeChatGptResponse('\\pi'),
          equals('pi'),
        );
        
        expect(
          AsciiMathConverter.normalizeChatGptResponse('\\infty'),
          equals('inf'),
        );
      });

      test('複雑な数式の正規化', () {
        expect(
          AsciiMathConverter.normalizeChatGptResponse('\\frac{\\sqrt{x^{2} + 1}}{\\sin(x)}'),
          equals('\\frac{sqrt(x^2) + 1}{sin(x)}'),
        );
      });

      test('不正な文字の除去', () {
        expect(
          AsciiMathConverter.normalizeChatGptResponse('x² + 3x + 2'),
          equals('x + 3x + 2'),
        );
      });
    });

    group('asciiMathToMathML', () {
      test('基本的な数式の変換', () {
        final result = AsciiMathConverter.asciiMathToMathML('(a)/(b)');
        expect(result, contains('<mfrac>'));
        expect(result, contains('<mrow>a</mrow>'));
        expect(result, contains('<mrow>b</mrow>'));
      });

      test('累乗の変換', () {
        final result = AsciiMathConverter.asciiMathToMathML('x^2');
        expect(result, contains('<msup>'));
        expect(result, contains('<mi>x</mi>'));
        expect(result, contains('<mi>2</mi>'));
      });
    });

    group('エッジケース', () {
      test('空文字列の処理', () {
        expect(AsciiMathConverter.calculatorToAsciiMath(''), equals(''));
        expect(AsciiMathConverter.asciiMathToLatex(''), equals(''));
        expect(AsciiMathConverter.normalizeChatGptResponse(''), equals(''));
      });

      test('null文字列の処理', () {
        expect(AsciiMathConverter.calculatorToAsciiMath('null'), equals('null'));
        expect(AsciiMathConverter.asciiMathToLatex('null'), equals('null'));
        expect(AsciiMathConverter.normalizeChatGptResponse('null'), equals('null'));
      });

      test('特殊文字の処理', () {
        expect(
          AsciiMathConverter.calculatorToAsciiMath('x^2 + 3*x + 2 = 0'),
          equals('x^2 + 3x + 2 = 0'),
        );
      });
    });
  });
}
