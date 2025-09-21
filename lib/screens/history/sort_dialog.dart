import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'history_state.dart';

/// 履歴のソート設定ダイアログ
class SortDialog extends StatefulWidget {
  const SortDialog({
    super.key,
    required this.currentState,
    required this.onStateChanged,
  });

  final HistoryState currentState;
  final ValueChanged<HistoryState> onStateChanged;

  @override
  State<SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  late String _sortBy;
  late bool _sortAscending;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.currentState.sortBy;
    _sortAscending = widget.currentState.sortAscending;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppConstants.sortDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: const Text('新しい順'),
            value: AppConstants.sortByTimestamp,
            groupValue: _sortBy,
            onChanged: (value) => _updateSortBy(value!),
          ),
          RadioListTile<String>(
            title: const Text('数式順'),
            value: AppConstants.sortByExpression,
            groupValue: _sortBy,
            onChanged: (value) => _updateSortBy(value!),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('昇順'),
            value: _sortAscending,
            onChanged: (value) => _updateSortAscending(value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  void _updateSortBy(String value) {
    setState(() => _sortBy = value);
    widget.onStateChanged(
      widget.currentState.copyWith(sortBy: value),
    );
  }

  void _updateSortAscending(bool value) {
    setState(() => _sortAscending = value);
    widget.onStateChanged(
      widget.currentState.copyWith(sortAscending: value),
    );
  }
}
