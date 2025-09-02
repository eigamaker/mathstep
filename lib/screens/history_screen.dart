import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/math_expression.dart';
import '../models/solution.dart';
import '../widgets/history_item_card.dart';
import '../widgets/history_filter_bar.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  String? _selectedTag;
  String _sortBy = 'timestamp'; // timestamp, tag, expression
  bool _sortAscending = false;

  // モックデータ（実際の実装ではデータベースから取得）
  final List<MathExpression> _mockExpressions = [
    MathExpression(
      id: '1',
      calculatorSyntax: '(2x+1)/(x-3) = cbrt(x+2)',
      latexExpression: r'\frac{2x+1}{x-3}=\sqrt[3]{x+2}',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      tag: '方程式',
    ),
    MathExpression(
      id: '2',
      calculatorSyntax: 'sin(x) + cos(x) = 1',
      latexExpression: r'\sin(x) + \cos(x) = 1',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      tag: '三角関数',
    ),
    MathExpression(
      id: '3',
      calculatorSyntax: 'x^2 + 2x + 1 = 0',
      latexExpression: r'x^2 + 2x + 1 = 0',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      tag: '二次方程式',
    ),
  ];

  List<MathExpression> get _filteredExpressions {
    List<MathExpression> filtered = _mockExpressions;

    // 検索クエリでフィルタ
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((expr) =>
          expr.calculatorSyntax.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          expr.latexExpression.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (expr.tag?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    // タグでフィルタ
    if (_selectedTag != null) {
      filtered = filtered.where((expr) => expr.tag == _selectedTag).toList();
    }

    // ソート
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'tag':
          comparison = (a.tag ?? '').compareTo(b.tag ?? '');
          break;
        case 'expression':
          comparison = a.calculatorSyntax.compareTo(b.calculatorSyntax);
          break;
        case 'timestamp':
        default:
          comparison = a.timestamp.compareTo(b.timestamp);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  List<String> get _availableTags {
    return _mockExpressions
        .map((expr) => expr.tag)
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
          ),
        ],
      ),
      body: Column(
        children: [
          // フィルタバー
          HistoryFilterBar(
            searchQuery: _searchQuery,
            selectedTag: _selectedTag,
            availableTags: _availableTags,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onTagChanged: (tag) {
              setState(() {
                _selectedTag = tag;
              });
            },
          ),
          
          // 履歴リスト
          Expanded(
            child: _filteredExpressions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '履歴がありません',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExpressions.length,
                    itemBuilder: (context, index) {
                      final expression = _filteredExpressions[index];
                      return HistoryItemCard(
                        expression: expression,
                        onTap: () => _viewExpression(expression),
                        onGenerateSimilar: () => _generateSimilarProblem(expression),
                        onDelete: () => _deleteExpression(expression),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _viewExpression(MathExpression expression) {
    // 履歴項目を表示（実際の実装ではSolutionScreenに遷移）
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${expression.calculatorSyntax} を表示')),
    );
  }

  void _generateSimilarProblem(MathExpression expression) {
    // 類題生成（実際の実装ではChatGPT APIを使用）
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${expression.calculatorSyntax} の類題を生成')),
    );
  }

  void _deleteExpression(MathExpression expression) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('${expression.calculatorSyntax} を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _mockExpressions.removeWhere((expr) => expr.id == expression.id);
              });
              Navigator.pop(context);
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('並び順'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('日時'),
              value: 'timestamp',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('タグ'),
              value: 'tag',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('数式'),
              value: 'expression',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('昇順'),
              value: _sortAscending,
              onChanged: (value) {
                setState(() {
                  _sortAscending = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
