import 'dart:math' as math;

/// 数式表現の共通ユーティリティ
class MathExpressionUtils {
  MathExpressionUtils._();

  /// 説明文から数式表現を除去してプレーンなテキストにする
  static String cleanDescription(String description) {
    var cleaned = description;
    
    // 数式パターンを除去
    cleaned = cleaned.replaceAll(RegExp(r'sqrt\([^)]+\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b(abs|sin|cos|tan|log|ln|sqrt|integral|sum|prod|limit|d/dx)\s*\([^)]+\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b\w+\^\w+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b\w+/\w+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'integral[^a-zA-Z]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'limit[^a-zA-Z]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'd/dx[^a-zA-Z]*'), '');
    
    // 余分な空白を整理
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // 数学的な表現をより親しみやすく
    cleaned = cleaned.replaceAll('である', 'です');
    cleaned = cleaned.replaceAll('である。', 'です。');
    
    // ステップバイステップの説明を強調
    if (cleaned.contains('まず') || cleaned.contains('次に')) {
      cleaned = '📝 $cleaned';
    }
    
    // 重要なポイントを強調
    if (cleaned.contains('重要') || cleaned.contains('注意')) {
      cleaned = '⚠️ $cleaned';
    }
    
    // 結果を強調
    if (cleaned.contains('結果') || cleaned.contains('答え')) {
      cleaned = '✅ $cleaned';
    }
    
    return cleaned;
  }

  /// 数式表現が有効かどうかをチェックする
  static bool isValidMathExpression(String expression) {
    if (expression.trim().isEmpty) return false;
    
    // 基本的な数式パターンをチェック
    final mathPattern = RegExp(r'^[0-9+\-*/().^x\s]+$|sqrt\([^)]+\)|sin\([^)]+\)|cos\([^)]+\)|tan\([^)]+\)|log\([^)]+\)|ln\([^)]+\)|exp\([^)]+\)');
    return mathPattern.hasMatch(expression);
  }

  /// 数式表現を正規化する
  static String normalizeExpression(String expression) {
    // 余分な空白を除去
    var normalized = expression.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // 括弧の前後に適切な空白を追加
    normalized = normalized.replaceAll(RegExp(r'(\w)\('), r'$1 (');
    normalized = normalized.replaceAll(RegExp(r'\)(\w)'), r') $1');
    
    return normalized;
  }

  /// 数式の複雑さを評価する（1-5のスケール）
  static int getExpressionComplexity(String expression) {
    int complexity = 1;
    
    // 基本的な演算子
    if (expression.contains('+') || expression.contains('-')) complexity++;
    if (expression.contains('*') || expression.contains('/')) complexity++;
    if (expression.contains('^')) complexity++;
    
    // 関数
    if (expression.contains('sqrt') || expression.contains('sin') || 
        expression.contains('cos') || expression.contains('tan')) {
      complexity++;
    }
    if (expression.contains('log') || expression.contains('ln') || 
        expression.contains('exp')) {
      complexity++;
    }
    
    // 括弧の深さ
    int maxDepth = 0;
    int currentDepth = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') {
        currentDepth++;
        maxDepth = math.max(maxDepth, currentDepth);
      } else if (expression[i] == ')') {
        currentDepth--;
      }
    }
    complexity += maxDepth;
    
    return math.min(complexity, 5);
  }
}

