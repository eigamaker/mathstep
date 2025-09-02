import 'package:flutter/material.dart';

class HistoryFilterBar extends StatelessWidget {
  final String searchQuery;
  final String? selectedTag;
  final List<String> availableTags;
  final Function(String) onSearchChanged;
  final Function(String?) onTagChanged;

  const HistoryFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedTag,
    required this.availableTags,
    required this.onSearchChanged,
    required this.onTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          // 検索バー
          TextField(
            decoration: InputDecoration(
              hintText: '数式、タグで検索...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => onSearchChanged(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: onSearchChanged,
          ),
          
          const SizedBox(height: 12),
          
          // タグフィルタ
          if (availableTags.isNotEmpty) ...[
            Row(
              children: [
                const Text(
                  'タグ: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 全タグ表示ボタン
                        _buildTagChip(
                          label: 'すべて',
                          isSelected: selectedTag == null,
                          onTap: () => onTagChanged(null),
                        ),
                        const SizedBox(width: 8),
                        // 各タグのボタン
                        ...availableTags.map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildTagChip(
                            label: tag,
                            isSelected: selectedTag == tag,
                            onTap: () => onTagChanged(tag),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.blue 
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Colors.blue 
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected 
                ? Colors.white 
                : Colors.grey.shade700,
            fontWeight: isSelected 
                ? FontWeight.bold 
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
