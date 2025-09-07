import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/latex_preview_scroll.dart';
import '../services/chatgpt_service.dart';
import '../models/math_expression.dart';
import 'solution_screen.dart';
import 'guide_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../services/ocr_service.dart';
import '../services/vision_formula_service.dart';
import '../utils/syntax_converter.dart';
import '../utils/ocr_postprocessor.dart';
import 'image_region_picker_screen.dart';
import 'formula_editor_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  String _currentExpression = '';
  String _latexExpression = '';
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? _lastOcrImagePath;
  Uint8List? _lastCroppedBytes;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    // アプリ起動時にテキストフィールドにフォーカスを当てる
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFieldFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _currentExpression = _textController.text;
      _latexExpression = SyntaxConverter.calculatorToLatex(_currentExpression);
    });
  }

  Future<void> _refineWithVision() async {
    try {
      if (_lastCroppedBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('まず画像から範囲を選択してください')),
        );
        return;
      }
      final service = VisionFormulaService();
      final expr = await service.extractCalculatorSyntax(_lastCroppedBytes!, mimeType: 'image/png');
      if (!mounted) return;
      final normalized = OcrPostprocessor.toCalculatorSyntax(expr);
      _textController.text = normalized;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI抽出に失敗しました: $e')),
      );
    }
  }

  Future<void> _openFormulaEditor() async {
    final edited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormulaEditorScreen(initialCalculatorSyntax: _textController.text),
      ),
    );
    if (edited is String) {
      _textController.text = edited;
    }
  }

  Future<void> _pickFromCameraAndRecognizeWithRegion() async {
    try {
      final XFile? shot = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (shot == null) return;
      _lastOcrImagePath = shot.path;
      if (!mounted) return;
      final Uint8List? cropped = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ImageRegionPickerScreen(imagePath: shot.path)),
      );
      if (cropped == null) return;
      _lastCroppedBytes = cropped;
      _lastCroppedBytes = cropped;
      final ocr = OcrService();
      final raw = await ocr.extractTextFromImageBytes(cropped);
      if (!mounted) return;
      if (raw.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('選択範囲からテキストを検出できませんでした')),
        );
        return;
      }
      final normalized = OcrPostprocessor.toCalculatorSyntax(raw);
      _textController.text = normalized;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR中にエラーが発生しました: $e')),
      );
    }
  }

  Future<void> _pickFromGalleryAndRecognize() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      _lastOcrImagePath = picked.path;
      if (!mounted) return;
      final Uint8List? cropped = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ImageRegionPickerScreen(imagePath: picked.path)),
      );
      if (cropped == null) return;
      final ocr = OcrService();
      final raw = await ocr.extractTextFromImageBytes(cropped);
      if (!mounted) return;
      if (raw.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('選択範囲からテキストを検出できませんでした')),
        );
        return;
      }
      final normalized = OcrPostprocessor.toCalculatorSyntax(raw);
      _textController.text = normalized;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR中にエラーが発生しました: $e')),
      );
    }
  }

  // 改良版: OCR結果を電卓記法に寄せる軽量正規化
  String _normalizeOcrToCalculatorV2(String raw) {
    String s = raw;
    s = s.replaceAll('\r', ' ').replaceAll('\n', ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    s = s
        .replaceAll('×', '*')
        .replaceAll('·', '*')
        .replaceAll('⋅', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('—', '-')
        .replaceAll('π', 'pi')
        .replaceAll('Π', 'pi');
    s = s.replaceAllMapped(RegExp(r'√\s*\(([^\)]+)\)'), (m) => 'sqrt(${m.group(1)})');
    s = s.replaceAllMapped(RegExp(r'√\s*([A-Za-z0-9]+)'), (m) => 'sqrt(${m.group(1)})');
    s = s.replaceAllMapped(RegExp(r'\|\s*([^|]+?)\s*\|'), (m) => 'abs(${m.group(1)})');
    s = s.replaceAll(RegExp(r'\s*\(\s*'), '(');
    s = s.replaceAll(RegExp(r'\s*\)\s*'), ')');
    return s;
  }

  // OCR結果を電卓記法に寄せる軽量正規化
  String _normalizeOcrToCalculator(String raw) {
    String s = raw;
    // unify whitespace
    s = s.replaceAll('\r', ' ').replaceAll('\n', ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    // common math symbols
    s = s
        .replaceAll('×', '*')
        .replaceAll('·', '*')
        .replaceAll('⋅', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('—', '-')
        .replaceAll('π', 'pi')
        .replaceAll('Π', 'pi');
    // sqrt forms
    s = s.replaceAllMapped(RegExp(r'√\s*\(([^\)]+)\)'), (m) => 'sqrt(${m.group(1)})');
    s = s.replaceAllMapped(RegExp(r'√\s*([A-Za-z0-9]+)'), (m) => 'sqrt(${m.group(1)})');
    // absolute value |expr|
    s = s.replaceAllMapped(RegExp(r'\|\s*([^|]+?)\s*\|'), (m) => 'abs(${m.group(1)})');
    // cleanup spaces around parens
    s = s.replaceAll(RegExp(r'\s*\(\s*'), '(');
    s = s.replaceAll(RegExp(r'\s*\)\s*'), ')');
    return s;
  }

  Future<void> _pickFromCameraAndRecognize() async {
    try {
      final XFile? shot = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (shot == null) return;

      _lastOcrImagePath = shot.path;
      final ocr = OcrService();
      final candidates = await ocr.extractLineCandidates(shot.path);
      if (!mounted) return;

      if (candidates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('画像からテキストを検出できませんでした')),
        );
        return;
      }

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          final allJoined = candidates.join(' ');
          final list = <String>['(すべて結合)', ...candidates];
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text('画像から数式を選択', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final t = i == 0 ? allJoined : list[i];
                        final label = i == 0 ? list[i] : t;
                        return ListTile(
                          title: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            Navigator.pop(context, t);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).then((selected) {
        if (selected is String && selected.trim().isNotEmpty) {
          final normalized = _normalizeOcrToCalculator(selected);
          // テキストフィールドに反映（UI表示＋プロンプトの一部として利用）
          _textController.text = normalized;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR中にエラーが発生しました: $e')),
      );
    }
  }

  String _convertToLatex(String calculatorSyntax) {
    // 基本的な変換（詳細は後で実装）
    String latex = calculatorSyntax;
    latex = latex.replaceAll('frac(', r'\frac{');
    latex = latex.replaceAll('sqrt(', r'\sqrt{');
    latex = latex.replaceAll('cbrt(', r'\sqrt[3]{');
    latex = latex.replaceAll('sin(', r'\sin(');
    latex = latex.replaceAll('cos(', r'\cos(');
    latex = latex.replaceAll('tan(', r'\tan(');
    latex = latex.replaceAll('ln(', r'\ln(');
    latex = latex.replaceAll('log(', r'\log(');
    latex = latex.replaceAll('pi', r'\pi');
    latex = latex.replaceAll('e', 'e');
    latex = latex.replaceAll('i', 'i');
    return latex;
  }

  void _insertText(String text) {
    // テキストフィールドにフォーカスを当てる
    _textFieldFocus.requestFocus();
    
    final cursorPosition = _textController.selection.baseOffset;
    final textBefore = _textController.text.substring(0, cursorPosition);
    final textAfter = _textController.text.substring(cursorPosition);
    
    _textController.text = textBefore + text + textAfter;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: cursorPosition + text.length),
    );
  }

  void _deleteText() {
    // テキストフィールドにフォーカスを当てる
    _textFieldFocus.requestFocus();
    
    final cursorPosition = _textController.selection.baseOffset;
    if (cursorPosition > 0) {
      final textBefore = _textController.text.substring(0, cursorPosition - 1);
      final textAfter = _textController.text.substring(cursorPosition);
      
      _textController.text = textBefore + textAfter;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition - 1),
      );
    }
  }

  void _moveCursor(int direction) {
    // テキストフィールドにフォーカスを当てる
    _textFieldFocus.requestFocus();
    
    final cursorPosition = _textController.selection.baseOffset;
    final newPosition = (cursorPosition + direction).clamp(0, _textController.text.length);
    
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: newPosition),
    );
  }

  Future<void> _generateSolution() async {
    if (_currentExpression.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数式を入力してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final chatGptService = ChatGptService();
      final solution = await chatGptService.generateSolution(_latexExpression);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SolutionScreen(
              mathExpression: MathExpression(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                calculatorSyntax: _currentExpression,
                latexExpression: _latexExpression,
                timestamp: DateTime.now(),
              ),
              solution: solution,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MathStep'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _openFormulaEditor,
            tooltip: '式エディタを開く',
          ),
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _refineWithVision,
            tooltip: 'AIで数式抽出 (Vision)',
          ),
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: _pickFromGalleryAndRecognize,
            tooltip: 'ギャラリーから範囲指定',
          ),
          IconButton(
            icon: const Icon(Icons.photo_camera_outlined),
            onPressed: _pickFromCameraAndRecognizeWithRegion,
            tooltip: 'カメラで範囲指定',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GuideScreen(),
                ),
              );
            },
            tooltip: '使い方ガイド',
          ),
        ],
      ),
      body: Column(
        children: [
          // LaTeXプレビュー
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _latexExpression.isNotEmpty
                  ? LatexPreviewScrollable(expression: _latexExpression)
                  : const Center(
                      child: Text(
                        '数式を入力してください',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ),
          
          // テキスト入力フィールド
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _textController,
              focusNode: _textFieldFocus,
              decoration: const InputDecoration(
                labelText: '数式を入力',
                border: OutlineInputBorder(),
                hintText: '例: (2x+1)/(x-3) = cbrt(x+2)',
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 解説生成ボタン
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _generateSolution,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      '解説を表示',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 電卓キーパッド
          Expanded(
            flex: 3,
            child: CalculatorKeypad(
              onKeyPressed: (key) {
                switch (key) {
                  case 'DEL':
                    _deleteText();
                    break;
                  case '←':
                    _moveCursor(-1);
                    break;
                  case '→':
                    _moveCursor(1);
                    break;
                  default:
                    _insertText(key);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
