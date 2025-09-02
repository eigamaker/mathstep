import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class OcrInputWidget extends StatefulWidget {
  final Function(String) onTextRecognized;

  const OcrInputWidget({
    super.key,
    required this.onTextRecognized,
  });

  @override
  State<OcrInputWidget> createState() => _OcrInputWidgetState();
}

class _OcrInputWidgetState extends State<OcrInputWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessing = false;
  String _recognizedText = '';
  File? _selectedImage;

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isProcessing = true;
        });

        await _processImage(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像の選択に失敗しました: $e')),
      );
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      setState(() {
        _recognizedText = recognizedText.text;
        _isProcessing = false;
      });

      // 数式を抽出して電卓シンタックスに変換
      final mathExpression = _extractMathExpression(_recognizedText);
      if (mathExpression.isNotEmpty) {
        widget.onTextRecognized(mathExpression);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR処理に失敗しました: $e')),
      );
    }
  }

  String _extractMathExpression(String text) {
    // 基本的な数式パターンを抽出
    final lines = text.split('\n');
    String mathExpression = '';
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (_isMathExpression(trimmedLine)) {
        mathExpression = _normalizeMathExpression(trimmedLine);
        break;
      }
    }
    
    return mathExpression;
  }

  bool _isMathExpression(String text) {
    // 数式らしき文字列かどうかを判定
    final mathPatterns = [
      RegExp(r'[+\-*/=]'),  // 演算子
      RegExp(r'[()]'),      // 括弧
      RegExp(r'[xyz]'),     // 変数
      RegExp(r'\d'),        // 数字
      RegExp(r'[√π]'),      // 数学記号
    ];
    
    return mathPatterns.any((pattern) => pattern.hasMatch(text));
  }

  String _normalizeMathExpression(String text) {
    String normalized = text;
    
    // よくあるOCR誤認識を修正
    normalized = normalized.replaceAll('l', '1');  // l → 1
    normalized = normalized.replaceAll('O', '0');  // O → 0
    normalized = normalized.replaceAll('o', '0');  // o → 0
    normalized = normalized.replaceAll('I', '1');  // I → 1
    
    // 数学記号の変換
    normalized = normalized.replaceAll('√', 'sqrt(');
    normalized = normalized.replaceAll('π', 'pi');
    normalized = normalized.replaceAll('×', '*');
    normalized = normalized.replaceAll('÷', '/');
    normalized = normalized.replaceAll('＝', '=');
    
    // 括弧の正規化
    normalized = normalized.replaceAll('（', '(');
    normalized = normalized.replaceAll('）', ')');
    
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 画像選択ボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('カメラで撮影'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('ギャラリーから選択'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 処理中表示
          if (_isProcessing)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('画像を処理中...'),
                ],
              ),
            ),
          
          // 選択された画像
          if (_selectedImage != null && !_isProcessing)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Image.file(
                _selectedImage!,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          
          // 認識結果
          if (_recognizedText.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '認識結果:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _recognizedText,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // OCR入力のヒント
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OCR入力のヒント:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• 印刷された数式を撮影してください\n'
                  '• 手書きよりも印刷体の方が認識精度が高いです\n'
                  '• 数式がはっきり見えるように撮影してください',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
