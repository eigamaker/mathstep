import 'dart:math' as math;

/// 数式の評価を行うユーティリティクラス
class ExpressionEvaluator {
  ExpressionEvaluator._();

  /// 数式を評価して結果を返す
  static double? evaluateExpression(String expression, double x) {
    try {
      return _evaluateSimpleExpression(expression, x);
    } catch (e) {
      return null;
    }
  }

  /// 基本的な数式の評価
  static double? _evaluateSimpleExpression(String expression, double x) {
    // 変数xを実際の値に置換
    String expr = expression.replaceAll('x', x.toString());
    
    // 基本的な数学関数の評価
    expr = _evaluateFunctions(expr);
    
    // 累乗の評価
    expr = _evaluatePowers(expr);
    
    // 基本的な四則演算の評価
    return _evaluateArithmetic(expr);
  }

  /// 数学関数の評価
  static String _evaluateFunctions(String expr) {
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

    // 三角関数の評価
    expr = _evaluateTrigonometricFunctions(expr);

    return expr;
  }

  /// 三角関数の評価
  static String _evaluateTrigonometricFunctions(String expr) {
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

  /// 累乗の評価
  static String _evaluatePowers(String expr) {
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

  /// 四則演算の評価
  static double? _evaluateArithmetic(String expr) {
    try {
      // 基本的な四則演算の評価（簡易版）
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

  /// 乗算と除算の処理
  static String _evaluateMultiplicationDivision(String expr) {
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

  /// 加算と減算の処理
  static String _evaluateAdditionSubtraction(String expr) {
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
}
