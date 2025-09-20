import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .envファイルを読み込み（存在する場合のみ）
  try {
    await dotenv.load(fileName: ".env");
    print('Successfully loaded .env file');
  } catch (e) {
    // .envファイルが存在しない場合は無視
    print('Warning: .env file not found. Using default configuration.');
    // dotenvを手動で初期化
    dotenv.testLoad(fileInput: '');
  }
  
  runApp(const ProviderScope(child: MathStepApp()));
}

class MathStepApp extends StatelessWidget {
  const MathStepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MathStep',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
