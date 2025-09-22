import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../localization/localization_extensions.dart';
import '../providers/solution_storage_provider.dart';
import '../providers/expression_provider.dart';
import '../providers/navigation_provider.dart';
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
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: context.l10n.historySearchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(
                          () => _state = _state.copyWith(searchQuery: ''),
                        ),
                      )
                    : null,
              ),
              onChanged: (query) =>
                  setState(() => _state = _state.copyWith(searchQuery: query)),
            ),
          ),
          Expanded(
            child: historyItemsAsync.when(
              data: (items) {
                final filteredItems = HistoryFilter.filterAndSort(
                  items,
                  _state,
                );
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
                            onCopyAndPaste: () => _copyAndPasteExpression(item),
                          );
                        },
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(context.l10n.historyErrorMessage('$error')),
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
        title: Text(context.l10n.historyDeleteDialogTitle),
        content: Text(
          context.l10n.historyDeleteConfirmation(
            item.expression.calculatorSyntax,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.commonCancelButton),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(solutionStorageProvider.notifier)
                  .removeSolution(item.solution.id);
              Navigator.pop(context);
            },
            child: Text(context.l10n.commonDeleteButton),
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.history, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              context.l10n.historyTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200, width: 1),
          ),
          child: IconButton(
            icon: Icon(Icons.sort, color: Colors.green.shade700),
            onPressed: _showSortDialog,
            tooltip: context.l10n.historySortTooltip,
          ),
        ),
      ],
    );
  }

  void _copyAndPasteExpression(MathExpressionWithSolution item) {
    // クリップボードにコピー
    Clipboard.setData(ClipboardData(text: item.expression.calculatorSyntax));

    // プロバイダーに数式を設定
    ref
        .read(expressionProvider.notifier)
        .updateInput(item.expression.calculatorSyntax);

    // ホーム画面に切り替え
    ref.read(navigationProvider.notifier).goToHome();

    // 成功メッセージを表示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.historyCopyAndPasteMessage),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
