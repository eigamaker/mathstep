# MathStep

AI数学チューターアプリ - ChatGPTを活用した数学学習支援

## 概要

MathStepは、ChatGPTを活用した数学学習支援アプリです。数式を入力すると、AIが段階的に解法を解説し、理解を深めることができます。教育カテゴリのアプリとして、学生から大人まで幅広いユーザーに利用されています。

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

### 2. 環境変数の設定

#### 開発環境の場合
1. プロジェクトルートに`.env`ファイルを作成
2. `env.development.example`ファイルをコピーして`.env`として使用
3. 実際のAPIキーと広告ユニットIDに置き換え

#### 本番環境の場合
1. プロジェクトルートに`.env.production`ファイルを作成
2. `env.production.example`ファイルをコピーして`.env.production`として使用
3. 本番用のAPIキーと広告ユニットIDに置き換え

#### 必要な環境変数
```
# OpenAI API設定
OPENAI_API_KEY=your_api_key_here
OPENAI_API_URL=https://api.openai.com/v1/chat/completions
OPENAI_MODEL=gpt-4o-mini
OPENAI_TEMPERATURE=0.7
OPENAI_MAX_TOKENS=2000
OPENAI_VISION_MODEL=gpt-4o-mini

# AdMob設定
ADMOB_APP_ID_ANDROID=your_android_app_id
ADMOB_APP_ID_IOS=your_ios_app_id
ADMOB_BANNER_AD_UNIT_ID_ANDROID=your_banner_ad_unit_id
ADMOB_BANNER_AD_UNIT_ID_IOS=your_banner_ad_unit_id
ADMOB_INTERSTITIAL_AD_UNIT_ID_ANDROID=your_interstitial_ad_unit_id
ADMOB_INTERSTITIAL_AD_UNIT_ID_IOS=your_interstitial_ad_unit_id
ADMOB_REWARDED_AD_UNIT_ID_ANDROID=your_rewarded_ad_unit_id
ADMOB_REWARDED_AD_UNIT_ID_IOS=your_rewarded_ad_unit_id
```

**重要**: 
- `.env`ファイルは機密情報を含むため、Gitにコミットされません
- 新しいリポジトリをクローンした際は、必ず環境変数ファイルを作成してください
- 開発用と本番用で異なるAPIキーと広告ユニットIDを使用してください

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

## リリースビルド

### Android
```bash
# キーストアを生成（初回のみ）
scripts\generate_keystore.bat

# リリースビルドを実行
scripts\build_release.bat
```

### iOS
1. Xcodeでプロジェクトを開く
2. 開発者証明書とプロビジョニングプロファイルを設定
3. Archiveを作成してApp Store Connectにアップロード

## App Store配信

### Bundle ID
- `com.profilecode.mathstep`

### 必要な設定
1. **Android署名**: `android/key.properties`でキーストア設定
2. **iOS証明書**: 開発者証明書とApp Store配布用プロビジョニングプロファイル
3. **APIキー**: 本番用のOpenAI APIキーを設定
4. **AdMob**: 本番用の広告ユニットIDを設定

### メタデータ
詳細なApp Store用メタデータは`app_store_metadata.md`を参照してください。

## 開発

このプロジェクトはFlutterで開発されています。

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Dart公式ドキュメント](https://dart.dev/guides)
