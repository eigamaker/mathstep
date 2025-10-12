import 'lib/utils/syntax_converter.dart';

void main() {
  print('=== Function Input Test ===\n');
  
  final testCases = [
    'f(x)=sin(x',
    'f(x)=sin(x)',
    'f(x)=sin(x) + cos(x)',
    'log(100',
    'log(100)',
    'log(100) + log(1000)',
    'ln(x',
    'ln(x)',
    'ln(x) + ln(y)',
  ];
  
  for (final input in testCases) {
    final converted = SyntaxConverter.calculatorToLatex(input);
    print('Input:  "$input"');
    print('Output: "$converted"');
    print('');
  }
}

