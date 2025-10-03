import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

/// 数式のグラフを表示するウィジェット
class MathGraphDisplay extends StatefulWidget {
  final String asciiMathExpression;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final int pointCount;

  const MathGraphDisplay({
    super.key,
    required this.asciiMathExpression,
    this.minX = -10.0,
    this.maxX = 10.0,
    this.minY = -10.0,
    this.maxY = 10.0,
    this.pointCount = 100,
  });

  @override
  State<MathGraphDisplay> createState() => _MathGraphDisplayState();
}

class _MathGraphDisplayState extends State<MathGraphDisplay> {
  List<FlSpot>? _dataPoints;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateGraphData();
  }

  @override
  void didUpdateWidget(MathGraphDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asciiMathExpression != widget.asciiMathExpression ||
        oldWidget.minX != widget.minX ||
        oldWidget.maxX != widget.maxX ||
        oldWidget.minY != widget.minY ||
        oldWidget.maxY != widget.maxY ||
        oldWidget.pointCount != widget.pointCount) {
      _generateGraphData();
    }
  }

  void _generateGraphData() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dataPoints = <FlSpot>[];
      final step = (widget.maxX - widget.minX) / widget.pointCount;
      int validPoints = 0;

      for (int i = 0; i <= widget.pointCount; i++) {
        final x = widget.minX + i * step;
        final y = _evaluateExpression(widget.asciiMathExpression, x);
        
        if (y != null && y.isFinite && y >= widget.minY && y <= widget.maxY) {
          dataPoints.add(FlSpot(x, y));
          validPoints++;
        }
      }

      setState(() {
        _dataPoints = dataPoints;
        _isLoading = false;
        
        // 有効な点が少なすぎる場合はエラーメッセージを表示
        if (validPoints < 5) {
          _errorMessage = 'この数式はグラフ化できません。\n対応している関数: sin, cos, tan, sqrt, exp, ln, log, 累乗, 四則演算';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'グラフの生成中にエラーが発生しました: $e';
        _isLoading = false;
      });
    }
  }

  double? _evaluateExpression(String expression, double x) {
    try {
      // 基本的な数式の評価（簡易版）
      return _evaluateSimpleExpression(expression, x);
    } catch (e) {
      return null;
    }
  }

  double? _evaluateSimpleExpression(String expression, double x) {
    // 変数xを実際の値に置換
    String expr = expression.replaceAll('x', x.toString());
    
    // 基本的な数学関数の評価
    expr = _evaluateFunctions(expr);
    
    // 累乗の評価
    expr = _evaluatePowers(expr);
    
    // 基本的な四則演算の評価
    return _evaluateArithmetic(expr);
  }

  String _evaluateFunctions(String expr) {
    // sqrt(x) → sqrt(x)
    expr = expr.replaceAllMapped(
      RegExp(r'sqrt\(([^)]+)\)'),
      (match) {
        final inner = _evaluateArithmetic(match.group(1)!) ?? 0.0;
        return math.sqrt(inner).toString();
      },
    );

    // root(n, x) → x^(1/n)
    expr = expr.replaceAllMapped(
      RegExp(r'root\(([^,]+),\s*([^)]+)\)'),
      (match) {
        final n = double.tryParse(match.group(1)!) ?? 1.0;
        final inner = _evaluateArithmetic(match.group(2)!) ?? 0.0;
        return math.pow(inner, 1.0 / n).toString();
      },
    );

    // exp(x) → e^x
    expr = expr.replaceAllMapped(
      RegExp(r'exp\(([^)]+)\)'),
      (match) {
        final inner = _evaluateArithmetic(match.group(1)!) ?? 0.0;
        return math.exp(inner).toString();
      },
    );

    // ln(x) → log(x) (自然対数)
    expr = expr.replaceAllMapped(
      RegExp(r'ln\(([^)]+)\)'),
      (match) {
        final inner = _evaluateArithmetic(match.group(1)!) ?? 0.0;
        if (inner > 0) {
          return math.log(inner).toString();
        } else {
          return '0'; // 負の数や0の対数は0とする
        }
      },
    );

    // log(x) → log10(x) (常用対数)
    expr = expr.replaceAllMapped(
      RegExp(r'log\(([^)]+)\)'),
      (match) {
        final inner = _evaluateArithmetic(match.group(1)!) ?? 0.0;
        if (inner > 0) {
          return (math.log(inner) / math.ln10).toString();
        } else {
          return '0'; // 負の数や0の対数は0とする
        }
      },
    );

    // sin(x), cos(x), tan(x) の評価
    expr = expr.replaceAllMapped(
      RegExp(r'sin\(([^)]+)\)'),
      (match) {
        final inner = _evaluateArithmetic(match.group(1)!) ?? 0.0;
        return math.sin(inner).toString();
      },
    );

    expr = expr.replaceAllMapped(
      RegExp(r'cos\(([^)]+)\)'),
      (match) {
        final inner = _evaluateArithmetic(match.group(1)!) ?? 0.0;
        return math.cos(inner).toString();
      },
    );

    expr = expr.replaceAllMapped(
      RegExp(r'tan\(([^)]+)\)'),
      (match) {
        final inner = _evaluateArithmetic(match.group(1)!) ?? 0.0;
        return math.tan(inner).toString();
      },
    );

    return expr;
  }

  String _evaluatePowers(String expr) {
    // 数値^数値 の評価
    expr = expr.replaceAllMapped(
      RegExp(r'([0-9.]+)\^([0-9.]+)'),
      (match) {
        final base = double.tryParse(match.group(1)!) ?? 0.0;
        final exponent = double.tryParse(match.group(2)!) ?? 1.0;
        return math.pow(base, exponent).toString();
      },
    );

    // 変数^数値 の評価 (x^2, x^3 など)
    expr = expr.replaceAllMapped(
      RegExp(r'([a-zA-Z]+)\^([0-9.]+)'),
      (match) {
        final variable = match.group(1)!;
        
        // 変数がxの場合のみ処理（他の変数は未対応）
        if (variable == 'x') {
          // この時点ではxは既に数値に置換されているはず
          // もしxが残っている場合は、そのまま返す
          return match.group(0)!;
        }
        return match.group(0)!;
      },
    );

    // 括弧内の累乗の評価 ((x+1)^2 など)
    expr = expr.replaceAllMapped(
      RegExp(r'\(([^)]+)\)\^([0-9.]+)'),
      (match) {
        final inner = match.group(1)!;
        final exponent = double.tryParse(match.group(2)!) ?? 1.0;
        
        // 括弧内を先に評価
        final evaluatedInner = _evaluateArithmetic(inner);
        if (evaluatedInner != null) {
          return math.pow(evaluatedInner, exponent).toString();
        }
        return match.group(0)!;
      },
    );

    return expr;
  }

  double? _evaluateArithmetic(String expr) {
    try {
      // 基本的な四則演算の評価（簡易版）
      // 実際の実装では、より複雑な数式パーサーが必要
      expr = expr.replaceAll(' ', '');
      
      // 括弧の処理
      while (expr.contains('(')) {
        final start = expr.lastIndexOf('(');
        final end = expr.indexOf(')', start);
        if (end == -1) return null;
        
        final inner = expr.substring(start + 1, end);
        final result = _evaluateArithmetic(inner);
        if (result == null) return null;
        
        expr = expr.substring(0, start) + result.toString() + expr.substring(end + 1);
      }
      
      // 乗算と除算の処理
      expr = _evaluateMultiplicationDivision(expr);
      
      // 加算と減算の処理
      expr = _evaluateAdditionSubtraction(expr);
      
      return double.tryParse(expr);
    } catch (e) {
      return null;
    }
  }

  String _evaluateMultiplicationDivision(String expr) {
    // 乗算と除算の処理
    final regex = RegExp(r'([0-9.]+)\s*([*/])\s*([0-9.]+)');
    while (regex.hasMatch(expr)) {
      expr = expr.replaceFirstMapped(regex, (match) {
        final left = double.tryParse(match.group(1)!) ?? 0.0;
        final op = match.group(2)!;
        final right = double.tryParse(match.group(3)!) ?? 0.0;
        
        if (op == '*') {
          return (left * right).toString();
        } else if (op == '/' && right != 0) {
          return (left / right).toString();
        } else {
          return '0';
        }
      });
    }
    return expr;
  }

  String _evaluateAdditionSubtraction(String expr) {
    // 加算と減算の処理
    final regex = RegExp(r'([0-9.]+)\s*([+-])\s*([0-9.]+)');
    while (regex.hasMatch(expr)) {
      expr = expr.replaceFirstMapped(regex, (match) {
        final left = double.tryParse(match.group(1)!) ?? 0.0;
        final op = match.group(2)!;
        final right = double.tryParse(match.group(3)!) ?? 0.0;
        
        if (op == '+') {
          return (left + right).toString();
        } else {
          return (left - right).toString();
        }
      });
    }
    return expr;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, color: Colors.orange.shade400, size: 32),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_dataPoints == null || _dataPoints!.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text('グラフデータがありません'),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: true,
              horizontalInterval: (widget.maxY - widget.minY) / 10,
              verticalInterval: (widget.maxX - widget.minX) / 10,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.shade300,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.shade300,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: (widget.maxX - widget.minX) / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: (widget.maxY - widget.minY) / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade400),
            ),
            minX: widget.minX,
            maxX: widget.maxX,
            minY: widget.minY,
            maxY: widget.maxY,
            lineBarsData: [
              LineChartBarData(
                spots: _dataPoints!,
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
