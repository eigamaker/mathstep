import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/math_expression.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/history_item_card.dart';

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

  final List<MathExpression> _mockExpressions = [
    MathExpression(
      id: '1',
      calculatorSyntax: '(2x + 1) / (x - 3) = cbrt(x + 2)',
      latexExpression: r'\frac{2x+1}{x-3}=\sqrt[3]{x+2}',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      tag: 'Equation',
    ),
    MathExpression(
      id: '2',
      calculatorSyntax: 'sin(x) + cos(x) = 1',
      latexExpression: r'\sin(x) + \cos(x) = 1',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      tag: 'Trigonometry',
    ),
    MathExpression(
      id: '3',
      calculatorSyntax: 'x^2 + 2x + 1 = 0',
      latexExpression: r'x^2 + 2x + 1 = 0',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      tag: 'Quadratic',
    ),
  ];

  List<MathExpression> get _filteredExpressions {
    var filtered = _mockExpressions;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((expr) {
        return expr.calculatorSyntax.toLowerCase().contains(query) ||
            expr.latexExpression.toLowerCase().contains(query) ||
            (expr.tag?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_selectedTag != null) {
      filtered = filtered.where((expr) => expr.tag == _selectedTag).toList();
    }

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
        title: const Text('History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort history',
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
                      final expression = _filteredExpressions[index];
                      return HistoryItemCard(
                        expression: expression,
                        onTap: () => _viewExpression(expression),
                        onGenerateSimilar: () =>
                            _generateSimilarProblem(expression),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${expression.calculatorSyntax}')),
    );
  }

  void _generateSimilarProblem(MathExpression expression) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating a similar problem for ${expression.calculatorSyntax}',
        ),
      ),
    );
  }

  void _deleteExpression(MathExpression expression) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry'),
        content: Text('Remove ${expression.calculatorSyntax} from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _mockExpressions.removeWhere(
                  (expr) => expr.id == expression.id,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
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
            'No history yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
