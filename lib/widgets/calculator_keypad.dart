import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum CalculatorKeyType { input, delete, moveLeft, moveRight }

class CalculatorKeyEvent {
  const CalculatorKeyEvent(this.type, [this.value = '']);

  final CalculatorKeyType type;
  final String value;
}

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({super.key, required this.onKeyPressed});

  final void Function(CalculatorKeyEvent event) onKeyPressed;

  static const List<List<_KeySpec>> _layout = [
    // 数字と基本演算
    [
      _KeySpec.input('7'),
      _KeySpec.input('8'),
      _KeySpec.input('9'),
      _KeySpec.input('('),
      _KeySpec.input(')'),
      _KeySpec.delete(),
    ],
    [
      _KeySpec.input('4'),
      _KeySpec.input('5'),
      _KeySpec.input('6'),
      _KeySpec.input('+'),
      _KeySpec.input('-'),
      _KeySpec.input('*', label: '\u00D7'),
    ],
    [
      _KeySpec.input('1'),
      _KeySpec.input('2'),
      _KeySpec.input('3'),
      _KeySpec.input('/', label: '\u00F7'),
      _KeySpec.input('^', label: 'x^y'),
      _KeySpec.input('pow(', label: 'x^()'),
    ],
    [
      _KeySpec.input('0'),
      _KeySpec.input('.'),
      _KeySpec.input('sqrt(', label: '\u221A'),
      _KeySpec.input('cbrt(', label: '\u221B'),
      _KeySpec.input('root(', label: '\u207F\u221A'),
      _KeySpec.input('frac(', label: 'a/b'),
    ],
    // 変数と定数
    [
      _KeySpec.input('x'),
      _KeySpec.input('y'),
      _KeySpec.input('z'),
      _KeySpec.input('n'),
      _KeySpec.input('pi', label: '\u03C0'),
      _KeySpec.input('e'),
    ],
    [
      _KeySpec.input('i'),
      _KeySpec.input('abs(', label: '|x|'),
      _KeySpec.input('f(', label: 'f(x)'),
      _KeySpec.moveLeft(),
      _KeySpec.moveRight(),
      _KeySpec.input(',', label: ','),
    ],
    // 三角・対数関数
    [
      _KeySpec.input('sin('),
      _KeySpec.input('cos('),
      _KeySpec.input('tan('),
      _KeySpec.input('ln('),
      _KeySpec.input('log('),
      _KeySpec.input('n!', label: 'n!'),
    ],
    // 高度な数学関数
    [
      _KeySpec.input('sum(', label: '\u03A3'),
      _KeySpec.input('prod(', label: '\u03A0'),
      _KeySpec.input('integral(', label: '\u222B'),
      _KeySpec.input('nPr(', label: 'P'),
      _KeySpec.input('nCr(', label: 'C'),
      _KeySpec.input('Re(', label: 'Re'),
    ],
    [
      _KeySpec.input('conj(', label: 'z*'),
      _KeySpec.input('Im(', label: 'Im'),
      _KeySpec.input('|', label: '|'),
      _KeySpec.moveLeft(),
      _KeySpec.moveRight(),
      _KeySpec.input('='),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          for (final row in _layout) _buildKeyRow(context, row),
        ],
      ),
    );
  }

  Widget _buildKeyRow(BuildContext context, List<_KeySpec> keys) {
    return Expanded(
      child: Row(
        children: keys
            .map((key) => Expanded(child: _buildKey(context, key)))
            .toList(),
      ),
    );
  }

  Widget _buildKey(BuildContext context, _KeySpec spec) {
    final background = _backgroundColorFor(spec.type, spec.value);
    final textColor = _textColorFor(spec.type, spec.value);

    return Container(
      margin: const EdgeInsets.all(1.5),
      height: 48, // キーボタンの高さを適切に調整
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(8),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onKeyPressed(CalculatorKeyEvent(spec.type, spec.value)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: background.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(
                spec.displayLabel,
                style: TextStyle(
                  fontSize: spec.fontSize ?? 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }


  Color _backgroundColorFor(CalculatorKeyType type, String value) {
    switch (type) {
      case CalculatorKeyType.delete:
        return AppColors.errorContainer;
      case CalculatorKeyType.moveLeft:
      case CalculatorKeyType.moveRight:
        return AppColors.primaryContainer;
      case CalculatorKeyType.input:
        switch (value) {
          case '+':
          case '-':
          case '*':
          case '/':
            return AppColors.warningContainer;
          case '0':
          case '1':
          case '2':
          case '3':
          case '4':
          case '5':
          case '6':
          case '7':
          case '8':
          case '9':
          case '.':
            return AppColors.primaryContainer;
          case 'sin(':
          case 'cos(':
          case 'tan(':
          case 'ln(':
          case 'log(':
          case 'pow(':
            return AppColors.infoContainer;
          case 'sqrt(':
          case 'cbrt(':
          case 'root(':
            return AppColors.infoContainer;
          case 'n!':
            return AppColors.warningContainer;
          case 'int(':
          case 'sum(':
          case 'prod(':
          case 'f(':
            return AppColors.secondaryContainer;
          case 'n':
            return AppColors.primaryContainer;
          case '=':
            return AppColors.successContainer;
          default:
            return AppColors.neutralContainer;
        }
    }
  }

  Color _textColorFor(CalculatorKeyType type, String value) {
    switch (type) {
      case CalculatorKeyType.delete:
        return AppColors.error;
      case CalculatorKeyType.moveLeft:
      case CalculatorKeyType.moveRight:
        return AppColors.primary;
      case CalculatorKeyType.input:
        switch (value) {
          case '+':
          case '-':
          case '*':
          case '/':
            return AppColors.warning;
          case '0':
          case '1':
          case '2':
          case '3':
          case '4':
          case '5':
          case '6':
          case '7':
          case '8':
          case '9':
          case '.':
            return AppColors.primary;
          case 'sin(':
          case 'cos(':
          case 'tan(':
          case 'ln(':
          case 'log(':
          case 'pow(':
            return AppColors.info;
          case 'sqrt(':
          case 'cbrt(':
          case 'root(':
            return AppColors.info;
          case 'n!':
            return AppColors.warning;
          case 'int(':
          case 'sum(':
          case 'prod(':
          case 'f(':
            return AppColors.secondary;
          case 'n':
            return AppColors.primary;
          case '=':
            return AppColors.success;
          default:
            return AppColors.neutral;
        }
    }
  }
}

class _KeySpec {
  const _KeySpec(this.type, this.value, {this.label, this.fontSize});

  const _KeySpec.input(String value, {String? label, double? fontSize})
    : this(CalculatorKeyType.input, value, label: label, fontSize: fontSize);

  const _KeySpec.delete() : this(CalculatorKeyType.delete, 'DEL');

  const _KeySpec.moveLeft() : this(CalculatorKeyType.moveLeft, '\u2190');

  const _KeySpec.moveRight() : this(CalculatorKeyType.moveRight, '\u2192');

  final CalculatorKeyType type;
  final String value;
  final String? label;
  final double? fontSize;

  String get displayLabel => label ?? value;
}
