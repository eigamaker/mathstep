import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mathstep/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'constants/app_colors.dart';
import 'localization/app_language.dart';
import 'providers/language_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file when available.
  try {
    await dotenv.load();
    debugPrint('Successfully loaded .env file');
    debugPrint('Loaded environment variables: ${dotenv.env.keys.toList()}');
    debugPrint('OPENAI_API_KEY length: ${dotenv.env['OPENAI_API_KEY']?.length ?? 0}');
  } catch (e) {
    // When .env is not found, proceed with defaults.
    debugPrint('Warning: .env file not found. Using default configuration.');
    debugPrint('Error details: $e');
    dotenv.testLoad(fileInput: '');
  }

  // Initialize AdMob.
  final mobileAds = MobileAds.instance;
  await mobileAds.initialize();

  // Configure a consistent debug-friendly request.
  await mobileAds.updateRequestConfiguration(
    RequestConfiguration(
      // testDeviceIds: ['6BBFA936FB1B9164941690327A3F1F82'], // Commented out for production
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
      maxAdContentRating: MaxAdContentRating.g,
    ),
  );

  debugPrint('AdMob initialized successfully');

  runApp(const ProviderScope(child: MathStepApp()));
}

class MathStepApp extends ConsumerWidget {
  const MathStepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageStateProvider);
    final locale = languageState.language.locale;

    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLanguage.supportedLanguages
          .map((language) => language.locale)
          .toList(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'MathStep',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightColorScheme.primary,
            foregroundColor: lightColorScheme.onPrimary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: lightColorScheme.primary,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: lightColorScheme.primary,
            side: BorderSide(color: lightColorScheme.primary),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: darkColorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: darkColorScheme.surface,
          foregroundColor: darkColorScheme.onSurface,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkColorScheme.primary,
            foregroundColor: darkColorScheme.onPrimary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkColorScheme.primary,
          foregroundColor: darkColorScheme.onPrimary,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: darkColorScheme.primary,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: darkColorScheme.primary,
            side: BorderSide(color: darkColorScheme.primary),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
