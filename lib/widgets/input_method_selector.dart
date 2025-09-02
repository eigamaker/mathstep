import 'package:flutter/material.dart';

enum InputMethod {
  calculator,
  voice,
  ocr,
}

class InputMethodSelector extends StatefulWidget {
  const InputMethodSelector({super.key});

  @override
  State<InputMethodSelector> createState() => _InputMethodSelectorState();
}

class _InputMethodSelectorState extends State<InputMethodSelector> {
  InputMethod _selectedMethod = InputMethod.calculator;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildMethodButton(
              InputMethod.calculator,
              Icons.calculate,
              '電卓',
              'キーパッドで入力',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMethodButton(
              InputMethod.voice,
              Icons.mic,
              '音声',
              '音声で入力',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMethodButton(
              InputMethod.ocr,
              Icons.camera_alt,
              'OCR',
              '画像から認識',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton(
    InputMethod method,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Colors.white
                  : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Colors.white
                    : Colors.grey.shade800,
                fontSize: 12,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white70
                    : Colors.grey.shade600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
