import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/math_expression.dart';
import '../models/solution.dart';

class SolutionStorageNotifier extends StateNotifier<List<Solution>> {
  SolutionStorageNotifier() : super([]);

  void addSolution(MathExpression expression, Solution solution) {
    // 同じ数式の既存の解法がある場合は更新、なければ追加
    final existingIndex = state.indexWhere(
      (s) => s.mathExpressionId == expression.id,
    );
    
    final updatedSolution = solution.copyWith(
      mathExpressionId: expression.id,
    );

    if (existingIndex >= 0) {
      final newState = List<Solution>.from(state);
      newState[existingIndex] = updatedSolution;
      state = newState;
    } else {
      state = [...state, updatedSolution];
    }
  }

  void removeSolution(String solutionId) {
    state = state.where((s) => s.id != solutionId).toList();
  }

  void clearAll() {
    state = [];
  }

  Solution? getSolutionByExpressionId(String expressionId) {
    try {
      return state.firstWhere((s) => s.mathExpressionId == expressionId);
    } catch (e) {
      return null;
    }
  }

  List<Solution> getSolutionsByTag(String tag) {
    return state.where((s) => s.problemStatement?.contains(tag) ?? false).toList();
  }
}

final solutionStorageProvider = StateNotifierProvider<SolutionStorageNotifier, List<Solution>>(
  (ref) => SolutionStorageNotifier(),
);

// 特定の数式IDに対応する解法を取得するプロバイダー
final solutionByExpressionIdProvider = Provider.family<Solution?, String>((ref, expressionId) {
  final solutions = ref.watch(solutionStorageProvider);
  return solutions.where((s) => s.mathExpressionId == expressionId).firstOrNull;
});

// 履歴用の数式と解法のペアを取得するプロバイダー
final historyItemsProvider = Provider<List<MathExpressionWithSolution>>((ref) {
  final solutions = ref.watch(solutionStorageProvider);
  // 実際の実装では、MathExpressionも別途管理する必要があります
  // ここでは簡略化のため、solutionsから直接作成します
  return solutions.map((solution) {
    return MathExpressionWithSolution(
      expression: MathExpression(
        id: solution.mathExpressionId,
        calculatorSyntax: '', // 実際の実装では適切に設定
        latexExpression: '', // 実際の実装では適切に設定
        timestamp: solution.timestamp,
      ),
      solution: solution,
    );
  }).toList();
});

class MathExpressionWithSolution {
  final MathExpression expression;
  final Solution solution;

  const MathExpressionWithSolution({
    required this.expression,
    required this.solution,
  });
}
