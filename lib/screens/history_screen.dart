import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/math_expression.dart';
import '../providers/solution_storage_provider.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/history_item_card.dart';
import 'solution_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  String? _selectedTag;
  String _sortBy = 'timestamp';
  bool _sortAscending = false;

  List<MathExpressionWithSolution> get _filteredExpressions {
    final solutions = ref.watch(solutionStorageProvider);
    var filtered = solutions.map((solution) {
      // 解法から数式を再構築（実際の実装では別途管理する必要があります）
      return MathExpressionWithSolution(
        expression: MathExpression(
          id: solution.mathExpressionId,
          calculatorSyntax: solution.problemStatement ?? '数式',
          latexExpression: '', // 実際の実装では適切に設定
          timestamp: solution.timestamp,
        ),
        solution: solution,
      );
    }).toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.expression.calculatorSyntax.toLowerCase().contains(query) ||
            item.expression.latexExpression.toLowerCase().contains(query) ||
            (item.solution.problemStatement?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_selectedTag != null) {
      filtered = filtered.where((item) => 
        item.solution.problemStatement?.contains(_selectedTag!) ?? false
      ).toList();
    }

    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'tag':
          comparison = (a.solution.problemStatement ?? '').compareTo(b.solution.problemStatement ?? '');
          break;
        case 'expression':
          comparison = a.expression.calculatorSyntax.compareTo(b.expression.calculatorSyntax);
          break;
        case 'timestamp':
        default:
          comparison = a.expression.timestamp.compareTo(b.expression.timestamp);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  List<String> get _availableTags {
    final solutions = ref.watch(solutionStorageProvider);
    return solutions
        .map((s) => s.problemStatement)
        .where((tag) => tag != null)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('履歴'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: '履歴を並び替え',
          ),
        ],
      ),
      body: Column(
        children: [
          HistoryFilterBar(
            searchQuery: _searchQuery,
            selectedTag: _selectedTag,
            availableTags: _availableTags,
            onSearchChanged: (query) => setState(() => _searchQuery = query),
            onTagChanged: (tag) => setState(() => _selectedTag = tag),
          ),
          Expanded(
            child: _filteredExpressions.isEmpty
                ? const _EmptyHistoryPlaceholder()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExpressions.length,
                    itemBuilder: (context, index) {
                      final item = _filteredExpressions[index];
                      return HistoryItemCard(
                        expression: item.expression,
                        onTap: () => _viewExpression(item),
                        onGenerateSimilar: () =>
                            _generateSimilarProblem(item),
                        onDelete: () => _deleteExpression(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _viewExpression(MathExpressionWithSolution item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolutionScreen(
          mathExpression: item.expression,
          solution: item.solution,
        ),
      ),
    );
  }

  void _generateSimilarProblem(MathExpressionWithSolution item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating a similar problem for ${item.expression.calculatorSyntax}',
        ),
      ),
    );
  }

  void _deleteExpression(MathExpressionWithSolution item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('履歴から削除'),
        content: Text('${item.expression.calculatorSyntax} を履歴から削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(solutionStorageProvider.notifier).removeSolution(item.solution.id);
              Navigator.pop(context);
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) {
          void updateSort(String value) {
            setState(() => _sortBy = value);
            setLocalState(() {});
          }

          return AlertDialog(
            title: const Text('Sort options'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Newest first'),
                  value: 'timestamp',
                  groupValue: _sortBy,
                  onChanged: (value) => updateSort(value!),
                ),
                RadioListTile<String>(
                  title: const Text('By tag'),
                  value: 'tag',
                  groupValue: _sortBy,
                  onChanged: (value) => updateSort(value!),
                ),
                RadioListTile<String>(
                  title: const Text('By expression'),
                  value: 'expression',
                  groupValue: _sortBy,
                  onChanged: (value) => updateSort(value!),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Ascending order'),
                  value: _sortAscending,
                  onChanged: (value) {
                    setState(() => _sortAscending = value);
                    setLocalState(() {});
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyHistoryPlaceholder extends StatelessWidget {
  const _EmptyHistoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '履歴がありません',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            '数式を入力して解法を生成すると、\nここに履歴が表示されます',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
