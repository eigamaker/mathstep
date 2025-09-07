import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Returns the full recognized text as a single string.
  Future<String> extractTextFromImageFilePath(String path) async {
    final inputImage = InputImage.fromFile(File(path));
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Returns a list of candidate text lines detected in the image, in reading order.
  /// Empty and whitespace-only lines are filtered out.
  Future<List<String>> extractLineCandidates(String path) async {
    final inputImage = InputImage.fromFile(File(path));
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    final List<String> lines = [];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final t = line.text.trim();
        if (t.isNotEmpty) {
          lines.add(t);
        }
      }
    }
    return lines;
  }

  /// Extract text from raw PNG/JPEG bytes by writing to a temp file first.
  Future<String> extractTextFromImageBytes(Uint8List bytes, {String extension = 'png'}) async {
    final dir = Directory.systemTemp.createTempSync('mathstep_ocr_');
    final file = File('${dir.path}/region.$extension');
    await file.writeAsBytes(bytes);
    try {
      final inputImage = InputImage.fromFile(file);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } finally {
      // best-effort cleanup
      try { await file.delete(); } catch (_) {}
      try { await dir.delete(recursive: true); } catch (_) {}
    }
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
