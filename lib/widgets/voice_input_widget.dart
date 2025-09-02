import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/voice_dictation.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onTextRecognized;

  const VoiceInputWidget({
    super.key,
    required this.onTextRecognized,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    // マイクの権限を確認
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('マイクの権限が必要です')),
      );
      return;
    }

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
        });
      },
      localeId: 'ja_JP',
    );
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });

    if (_lastWords.isNotEmpty) {
      // 音声認識結果を電卓シンタックスに変換
      final calculatorSyntax = VoiceDictation.convertDictationToCalculatorSyntax(_lastWords);
      widget.onTextRecognized(calculatorSyntax);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 音声認識状態表示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isListening ? Colors.red.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isListening ? Colors.red : Colors.grey,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _isListening ? Icons.mic : Icons.mic_off,
                  size: 48,
                  color: _isListening ? Colors.red : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  _isListening ? '音声認識中...' : '音声認識待機中',
                  style: TextStyle(
                    fontSize: 16,
                    color: _isListening ? Colors.red : Colors.grey,
                  ),
                ),
                if (_lastWords.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '認識結果: $_lastWords',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 音声認識ボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _speechEnabled && !_isListening ? _startListening : null,
                icon: const Icon(Icons.mic),
                label: const Text('音声認識開始'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isListening ? _stopListening : null,
                icon: const Icon(Icons.stop),
                label: const Text('停止'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 音声入力のヒント
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '音声入力のヒント:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• 「二乗」→ ^2\n'
                  '• 「ルート」→ sqrt(\n'
                  '• 「分の」→ )/(\n'
                  '• 「かっこ」→ (\n'
                  '• 「イコール」→ =',
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
