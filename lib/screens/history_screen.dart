import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../providers/solution_storage_provider.dart';
import 'history/empty_history_placeholder.dart';
import 'history/history_item_widget.dart';
import 'history/history_state.dart';
import 'history/sort_dialog.dart';
import 'solution_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryState _state = const HistoryState();

  @override
  Widget build(BuildContext context) {
    final historyItemsAsync = ref.watch(historyItemsProvider);
    
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
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '数式を検索...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _state = _state.copyWith(searchQuery: '')),
                      )
                    : null,
              ),
              onChanged: (query) => setState(() => _state = _state.copyWith(searchQuery: query)),
            ),
          ),
          Expanded(
            child: historyItemsAsync.when(
              data: (items) {
                final filteredItems = HistoryFilter.filterAndSort(items, _state);
                return filteredItems.isEmpty
                    ? const EmptyHistoryPlaceholder()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return HistoryItemWidget(
                            item: item,
                            onView: () => _viewExpression(item),
                            onDelete: () => _deleteExpression(item),
                          );
                        },
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('エラー: $error'),
              ),
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


  void _deleteExpression(MathExpressionWithSolution item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.deleteConfirmTitle),
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
      builder: (context) => SortDialog(
        currentState: _state,
        onStateChanged: (newState) {
          setState(() => _state = newState);
        },
      ),
    );
  }
}

