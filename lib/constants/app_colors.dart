import 'package:flutter/material.dart';

/// アプリケーション全体で使用する統一されたカラーパレット
class AppColors {
  // プライマリカラー（メインのブルー系）
  static const Color primary = Color(0xFF2F3B69); // 新しいプライマリーカラー
  static const Color primaryLight = Color(0xFF4A5A8A); // より明るいブルー
  static const Color primaryDark = Color(0xFF1A2338); // より暗いブルー
  static const Color primaryContainer = Color(0xFFE8EBF2); // 薄いブルー
  static const Color primarySurface = Color(0xFFF2F4F8); // より薄いブルー

  // セカンダリカラー（アクセント用の緑系）
  static const Color secondary = Color(0xFF388E3C); // Material Green 700
  static const Color secondaryLight = Color(0xFF66BB6A); // Material Green 400
  static const Color secondaryContainer = Color(0xFFE8F5E8); // 薄い緑

  // 成功・確認用（緑系）
  static const Color success = Color(0xFF2E7D32); // Material Green 800
  static const Color successLight = Color(0xFF4CAF50); // Material Green 500
  static const Color successContainer = Color(0xFFE8F5E8); // 薄い緑

  // 警告・注意用（オレンジ系）
  static const Color warning = Color(0xFFF57C00); // Material Orange 700
  static const Color warningLight = Color(0xFFFF9800); // Material Orange 500
  static const Color warningContainer = Color(0xFFFFF3E0); // 薄いオレンジ

  // エラー・削除用（赤系）
  static const Color error = Color(0xFFD32F2F); // Material Red 700
  static const Color errorLight = Color(0xFFEF5350); // Material Red 400
  static const Color errorContainer = Color(0xFFFFEBEE); // 薄い赤

  // 情報・ヘルプ用（ティール系）
  static const Color info = Color(0xFF00695C); // Material Teal 800
  static const Color infoLight = Color(0xFF26A69A); // Material Teal 500
  static const Color infoContainer = Color(0xFFE0F2F1); // 薄いティール

  // ニュートラルカラー（グレー系）
  static const Color neutral = Color(0xFF424242); // Material Grey 800
  static const Color neutralLight = Color(0xFF757575); // Material Grey 600
  static const Color neutralContainer = Color(0xFFF5F5F5); // Material Grey 100
  static const Color neutralSurface = Color(0xFFFAFAFA); // より薄いグレー

  // 背景・表面用
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // ボーダー・分割線用
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFE0E0E0);

  // テキスト用
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;

  // グラデーション用
  static const List<Color> primaryGradient = [
    Color(0xFF2F3B69),
    Color(0xFF4A5A8A),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF388E3C),
    Color(0xFF66BB6A),
  ];

  static const List<Color> surfaceGradient = [
    Color(0xFFF5F5F5),
    Color(0xFFE0E0E0),
  ];

  // キーパッド用の色分け
  static const Color keyNumber = primary;
  static const Color keyOperator = warning;
  static const Color keyFunction = info;
  static const Color keySpecial = secondary;
  static const Color keyDelete = error;
  static const Color keyAction = success;
}
