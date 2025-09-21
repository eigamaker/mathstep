import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/math_expression.dart';
import '../models/solution.dart';

class SolutionStorageNotifier extends StateNotifier<List<Solution>> {
  SolutionStorageNotifier() : super([]) {
    _loadSolutions();
  }

  static const _solutionsKey = AppConstants.solutionsKey;
  static const _expressionsKey = AppConstants.expressionsKey;

  Future<void> _loadSolutions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final solutionsJson = prefs.getStringList(_solutionsKey);
      if (solutionsJson != null) {
        state = solutionsJson.map((jsonString) {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          return Solution.fromJson(jsonMap);
        }).toList();
      }
    } catch (e) {
      // エラーが発生した場合は空のリストで初期化
      state = [];
    }
  }

  Future<void> _saveSolutions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final solutionsJson = state.map((solution) => jsonEncode(solution.toJson())).toList();
      await prefs.setStringList(_solutionsKey, solutionsJson);
    } catch (e) {
      // 保存エラーは無視（データの整合性を保つため）
    }
  }

  void addSolution(MathExpression expression, Solution solution) {
    // 数式の情報も一緒に保存
    _saveExpression(expression);
    
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
    _saveSolutions();
  }

  Future<void> _saveExpression(MathExpression expression) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expressionsJson = prefs.getStringList(_expressionsKey) ?? [];
      
      // 既存の数式を更新または追加
      final expressionJson = jsonEncode(expression.toJson());
      final existingIndex = expressionsJson.indexWhere((json) {
        try {
          final Map<String, dynamic> data = jsonDecode(json);
          return data['id'] == expression.id;
        } catch (e) {
          return false;
        }
      });
      
      if (existingIndex >= 0) {
        expressionsJson[existingIndex] = expressionJson;
      } else {
        expressionsJson.add(expressionJson);
      }
      
      await prefs.setStringList(_expressionsKey, expressionsJson);
    } catch (e) {
      // 保存エラーは無視（データの整合性を保つため）
    }
  }

  Future<MathExpression?> getExpression(String expressionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expressionsJson = prefs.getStringList(_expressionsKey) ?? [];
      
      for (final json in expressionsJson) {
        try {
          final Map<String, dynamic> data = jsonDecode(json);
          if (data['id'] == expressionId) {
            return MathExpression.fromJson(data);
          }
        } catch (e) {
          // 無効なJSONはスキップ
          continue;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void removeSolution(String solutionId) {
    state = state.where((s) => s.id != solutionId).toList();
    _saveSolutions();
  }

  void clearAll() {
    state = [];
    _saveSolutions();
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
final historyItemsProvider = FutureProvider<List<MathExpressionWithSolution>>((ref) async {
  final solutions = ref.watch(solutionStorageProvider);
  final notifier = ref.read(solutionStorageProvider.notifier);
  
  final List<MathExpressionWithSolution> items = [];
  
  for (final solution in solutions) {
    final expression = await notifier.getExpression(solution.mathExpressionId);
    if (expression != null) {
      items.add(MathExpressionWithSolution(
        expression: expression,
        solution: solution,
      ));
    }
  }
  
  return items;
});

class MathExpressionWithSolution {
  final MathExpression expression;
  final Solution solution;

  const MathExpressionWithSolution({
    required this.expression,
    required this.solution,
  });
}
