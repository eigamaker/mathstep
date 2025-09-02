import 'package:flutter/material.dart';

class CalculatorKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;

  const CalculatorKeypad({
    super.key,
    required this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          // 第1行: 括弧、変数、区切り文字
          _buildKeyRow([
            _buildKey('(', '('),
            _buildKey(')', ')'),
            _buildKey('x', 'x'),
            _buildKey('y', 'y'),
            _buildKey('z', 'z'),
            _buildKey(',', ','),
          ]),
          
          // 第2行: 移動、削除
          _buildKeyRow([
            _buildKey('←', '←'),
            _buildKey('→', '→'),
            _buildKey('DEL', 'DEL'),
            _buildKey('^', '^'),
            _buildKey('sqrt(', '√'),
            _buildKey('cbrt(', '∛'),
          ]),
          
          // 第3行: 根号、分数
          _buildKeyRow([
            _buildKey('root(', 'n√'),
            _buildKey('frac(', 'a/b'),
            _buildKey('abs(', '|x|'),
            _buildKey('pi', 'π'),
            _buildKey('e', 'e'),
            _buildKey('i', 'i'),
          ]),
          
          // 第4行: 関数
          _buildKeyRow([
            _buildKey('sin(', 'sin'),
            _buildKey('cos(', 'cos'),
            _buildKey('tan(', 'tan'),
            _buildKey('ln(', 'ln'),
            _buildKey('log(', 'log'),
            _buildKey('n!', 'n!'),
          ]),
          
          // 第5行: 順列・組み合わせ
          _buildKeyRow([
            _buildKey('nPr(', 'P'),
            _buildKey('nCr(', 'C'),
            _buildKey('sum(', 'Σ'),
            _buildKey('prod(', 'Π'),
            _buildKey('Re(', 'Re'),
            _buildKey('Im(', 'Im'),
          ]),
          
          // 第6行: 複素数、演算子
          _buildKeyRow([
            _buildKey('conj(', 'z*'),
            _buildKey('|', '|'),
            _buildKey('/', '÷'),
            _buildKey('*', '×'),
            _buildKey('-', '-'),
            _buildKey('+', '+'),
          ]),
          
          // 第7行: 等号
          _buildKeyRow([
            _buildKey('=', '=', isWide: true, isPrimary: true),
          ]),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<Widget> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) => Expanded(child: key)).toList(),
      ),
    );
  }

  Widget _buildKey(String value, String display, {bool isWide = false, bool isPrimary = false}) {
    return Container(
      margin: const EdgeInsets.all(1.5),
              child: Material(
          color: _getKeyColor(value),
          borderRadius: BorderRadius.circular(6),
          elevation: isPrimary ? 2 : 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => onKeyPressed(value),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isPrimary ? Colors.green.shade400 : Colors.grey.shade300, 
                  width: isPrimary ? 1.5 : 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  display,
                  style: TextStyle(
                    fontSize: isWide ? 18 : 12,
                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                    color: _getTextColor(value),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
    );
  }

  Color _getKeyColor(String value) {
    switch (value) {
      case 'DEL':
        return Colors.red.shade100;
      case '←':
      case '→':
        return Colors.blue.shade100;
      case '=':
        return Colors.green.shade100;
      case '+':
      case '-':
      case '*':
      case '/':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getTextColor(String value) {
    switch (value) {
      case 'DEL':
        return Colors.red.shade800;
      case '←':
      case '→':
        return Colors.blue.shade800;
      case '=':
        return Colors.green.shade800;
      case '+':
      case '-':
      case '*':
      case '/':
        return Colors.orange.shade800;
      default:
        return Colors.black87;
    }
  }
}
