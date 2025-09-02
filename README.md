# mathstep

受験数学モバイルアプリ - 式入力からChatGPT解説まで

## 概要

MathStepは、受験生向けの数学学習アプリです。数式を入力すると、ChatGPTが詳しい解説を提供します。

### 主な機能

- 🎤 **音声入力** - 音声で数式を入力
- 📷 **OCR機能** - カメラで数式を撮影してテキスト認識
- 🤖 **ChatGPT解説** - AIによる詳細な解法解説
- 📚 **履歴管理** - 過去の問題と解説を保存
- 🎨 **LaTeX表示** - 美しい数式表示

## セットアップ

### 1. 依存関係のインストール

```bash
flutter pub get
```

### 2. APIキーの設定

1. プロジェクトルートに`.env`ファイルを作成
2. `env.example`ファイルを参考に、以下の内容を追加：

```
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_API_URL=https://api.openai.com/v1/chat/completions
OPENAI_MODEL=gpt-4
OPENAI_TEMPERATURE=0.7
OPENAI_MAX_TOKENS=2000
```

3. `your_openai_api_key_here` を実際のOpenAI APIキーに置き換え

**注意**: `.env`ファイルは機密情報を含むため、Gitにコミットされません。

### 3. アプリの実行

```bash
# iOS
flutter run

# Android
flutter run
```

## プラットフォーム対応

- ✅ iOS
- ✅ Android

## 必要な権限

### Android
- インターネット接続
- 音声認識
- カメラ
- ストレージ読み書き

### iOS
- 音声認識
- カメラ
- フォトライブラリ

## 開発

このプロジェクトはFlutterで開発されています。

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Dart公式ドキュメント](https://dart.dev/guides)
