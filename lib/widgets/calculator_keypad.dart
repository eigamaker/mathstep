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
          // 第1行: 数字キー
          _buildKeyRow([
            _buildKey('7', '7'),
            _buildKey('8', '8'),
            _buildKey('9', '9'),
            _buildKey('(', '('),
            _buildKey(')', ')'),
            _buildKey('DEL', 'DEL'),
          ]),
          
          // 第2行: 数字キー
          _buildKeyRow([
            _buildKey('4', '4'),
            _buildKey('5', '5'),
            _buildKey('6', '6'),
            _buildKey('+', '+'),
            _buildKey('-', '-'),
            _buildKey('*', '×'),
          ]),
          
          // 第3行: 数字キー
          _buildKeyRow([
            _buildKey('1', '1'),
            _buildKey('2', '2'),
            _buildKey('3', '3'),
            _buildKey('/', '÷'),
            _buildKey('^', 'x^y'),
            _buildKey('sqrt(', '√'),
          ]),
          
          // 第4行: 数字キーと小数点
          _buildKeyRow([
            _buildKey('0', '0'),
            _buildKey('.', '.'),
            _buildKey('x', 'x'),
            _buildKey('y', 'y'),
            _buildKey('z', 'z'),
            _buildKey('cbrt(', '∛'),
          ]),
          
          // 第5行: 移動、削除
          _buildKeyRow([
            _buildKey('←', '◀'),
            _buildKey('→', '▶'),
            _buildKey('root(', 'ⁿ√'),
            _buildKey('frac(', 'a/b'),
            _buildKey('abs(', '|x|'),
            _buildKey('pi', 'π'),
          ]),
          
          // 第6行: 関数
          _buildKeyRow([
            _buildKey('sin(', 'sin'),
            _buildKey('cos(', 'cos'),
            _buildKey('tan(', 'tan'),
            _buildKey('ln(', 'ln'),
            _buildKey('log(', 'log'),
            _buildKey('n!', 'n!'),
          ]),
          
          // 第7行: 順列・組み合わせ
          _buildKeyRow([
            _buildKey('nPr(', 'P'),
            _buildKey('nCr(', 'C'),
            _buildKey('sum(', 'Σ'),
            _buildKey('prod(', 'Π'),
            _buildKey('Re(', 'Re'),
            _buildKey('Im(', 'Im'),
          ]),
          
          // 第8行: 複素数、演算子
          _buildKeyRow([
            _buildKey('conj(', 'z*'),
            _buildKey('|', '|'),
            _buildKey('e', 'e'),
            _buildKey('i', 'i'),
            _buildKey(',', ','),
            _buildKey('=', '=', isPrimary: true),
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
      height: 50,
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
                    fontSize: isWide ? 20 : 16,
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
        return Colors.blue.shade50;
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
        return Colors.blue.shade800;
      default:
        return Colors.black87;
    }
  }
}
