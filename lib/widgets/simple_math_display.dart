import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class SimpleMathDisplay extends StatelessWidget {
  final String expression;

  const SimpleMathDisplay({
    super.key,
    required this.expression,
  });

  @override
  Widget build(BuildContext context) {
    if (expression.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          '数式を入力してください',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // 積分の特別な表示
    if (expression.contains(r'\int')) {
      return _buildIntegralDisplay();
    }

    // Σ記号の特別な表示
    if (expression.contains(r'\sum')) {
      return _buildSummationDisplay();
    }

    // 分数の特別な表示
    if (expression.contains(r'\frac') || expression.contains('/')) {
      return _buildFractionDisplay();
    }

    // ルートの特別な表示
    if (expression.contains(r'\sqrt')) {
      return _buildRootDisplay();
    }

    // 通常の数式表示
    return _buildNormalExpression();
  }

  Widget _buildIntegralDisplay() {
    // より柔軟な積分パターンマッチング
    final integralPatterns = [
      // \int_{a}^{b} f(x) dx
      RegExp(r'\\int\s*_\{([^}]+)\}\^\{([^}]+)\}\s*([^d]+?)\s*d([a-zA-Z]+)'),
      // \int_a^b f(x) dx
      RegExp(r'\\int\s*_([a-zA-Z0-9+\-*/^()]+)\^([a-zA-Z0-9+\-*/^()]+)\s*([^d]+?)\s*d([a-zA-Z]+)'),
      // \int^{b} f(x) dx
      RegExp(r'\\int\s*\^\{([^}]+)\}\s*([^d]+?)\s*d([a-zA-Z]+)'),
      // \int_{a} f(x) dx
      RegExp(r'\\int\s*_\{([^}]+)\}\s*([^d]+?)\s*d([a-zA-Z]+)'),
      // \int f(x) dx
      RegExp(r'\\int\s*([^d]+?)\s*d([a-zA-Z]+)'),
    ];
    
    RegExpMatch? match;
    int patternIndex = -1;
    for (int i = 0; i < integralPatterns.length; i++) {
      match = integralPatterns[i].firstMatch(expression);
      if (match != null) {
        patternIndex = i;
        break;
      }
    }
    
    // デバッグ用ログ
    print('積分式: $expression');
    print('マッチしたパターン: ${patternIndex >= 0 ? patternIndex : "なし"}');
    if (match != null) {
      print('グループ数: ${match.groupCount}');
      for (int i = 0; i <= match.groupCount; i++) {
        print('グループ$i: ${match.group(i)}');
      }
    }

    if (match != null) {
      String? lowerLimit;
      String? upperLimit;
      String? integrand;
      String? variable;
      
      // パターンに応じて上限・下限・被積分関数・変数を抽出
      if (match.groupCount >= 4) {
        // \int_{a}^{b} f(x) dx または \int_a^b f(x) dx
        lowerLimit = match.group(1);
        upperLimit = match.group(2);
        integrand = match.group(3)?.trim();
        variable = match.group(4);
      } else if (match.groupCount >= 3) {
        // \int^{b} f(x) dx または \int_{a} f(x) dx
        if (expression.contains('^{')) {
          // 上限のみ
          upperLimit = match.group(1);
          integrand = match.group(2)?.trim();
          variable = match.group(3);
        } else {
          // 下限のみ
          lowerLimit = match.group(1);
          integrand = match.group(2)?.trim();
          variable = match.group(3);
        }
      } else if (match.groupCount >= 2) {
        // \int f(x) dx
        integrand = match.group(1)?.trim();
        variable = match.group(2);
      }

      return SizedBox(
        height: 100, // 固定高さを設定
        child: Stack(
          children: [
            // 中央の積分記号と被積分関数
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 積分記号
                  Container(
                    width: 30,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        '∫',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // 被積分関数
                  if (integrand != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildMathText(integrand),
                    ),
                  
                  // 変数
                  if (variable != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        'd$variable',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // 上限（積分記号の右上に配置）
            if (upperLimit != null)
              Positioned(
                top: 5,
                left: 15, // 積分記号の右側に配置
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    upperLimit,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            
            // 下限（積分記号の右下に配置）
            if (lowerLimit != null)
              Positioned(
                bottom: 5,
                left: 15, // 積分記号の右側に配置
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    lowerLimit,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return _buildNormalExpression();
  }

  Widget _buildSummationDisplay() {
    final sigmaPattern = RegExp(r'\\sum(?:_\{([^}]+)\})?(?:\^\{([^}]+)\})?\s*([^\\]*)');
    final match = sigmaPattern.firstMatch(expression);

    if (match != null) {
      final lowerLimit = match.group(1);
      final upperLimit = match.group(2);
      final summand = match.group(3)?.trim();

      return SizedBox(
        height: 100, // 固定高さを設定
        child: Stack(
          children: [
            // 中央のΣ記号と被和関数
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Σ記号
                  Container(
                    width: 40,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        'Σ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // 被和関数
                  if (summand != null && summand.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _buildMathText(summand),
                    ),
                ],
              ),
            ),
            
            // 上限（Σ記号の右上に配置）
            if (upperLimit != null)
              Positioned(
                top: 8,
                left: 20, // Σ記号の右側に配置
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    upperLimit,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            
            // 下限（Σ記号の右下に配置）
            if (lowerLimit != null)
              Positioned(
                bottom: 8,
                left: 20, // Σ記号の右側に配置
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    lowerLimit,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return _buildNormalExpression();
  }

  Widget _buildFractionDisplay() {
    // \frac パターンの処理
    final fracPattern = RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}');
    final match = fracPattern.firstMatch(expression);

    if (match != null) {
      final numerator = match.group(1)?.trim() ?? '';
      final denominator = match.group(2)?.trim() ?? '';

      return SizedBox(
        height: 100, // 固定高さを設定
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 分子
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMathText(numerator),
            ),

            // 分数線
            Container(
              width: 80,
              height: 3,
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 分母
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMathText(denominator),
            ),
          ],
        ),
      );
    }

    return _buildNormalExpression();
  }

  Widget _buildRootDisplay() {
    final rootPattern = RegExp(r'\\sqrt\{([^}]+)\}');
    final match = rootPattern.firstMatch(expression);

    if (match != null) {
      final radicand = match.group(1)?.trim() ?? '';

      return SizedBox(
        height: 80, // 固定高さを設定
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ルート記号
            Container(
              width: 30,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  '√',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // 被開方数
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildMathText(radicand),
            ),
          ],
        ),
      );
    }

    return _buildNormalExpression();
  }

  Widget _buildMathText(String text) {
    // 分数の場合は特別処理
    if (text.contains('/') && !text.contains('\\frac')) {
      return _buildSimpleFraction(text);
    }

    try {
      return Math.tex(
        text,
        textStyle: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
        ),
      );
    } catch (e) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontFamily: 'monospace',
        ),
      );
    }
  }

  Widget _buildSimpleFraction(String text) {
    // 2/3 のような分数を3行レイアウトで表示
    final parts = text.split('/');
    if (parts.length == 2) {
      final numerator = parts[0].trim();
      final denominator = parts[1].trim();

      return SizedBox(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 分子
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Text(
                numerator,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // 分数線
            Container(
              width: 60,
              height: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            // 分母
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.shade200, width: 1),
              ),
              child: Text(
                denominator,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildNormalExpression() {
    // 通常の数式でも分数を検出して3行レイアウトに変換
    if (expression.contains('/') && !expression.contains('\\frac')) {
      return _buildSimpleFraction(expression);
    }

    try {
      return Math.tex(
        expression,
        textStyle: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
        ),
      );
    } catch (e) {
      return Text(
        expression,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontFamily: 'monospace',
        ),
      );
    }
  }
}