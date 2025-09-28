import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mathstep/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
      testDeviceIds: ['6BBFA936FB1B9164941690327A3F1F82'],
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
      maxAdContentRating: MaxAdContentRating.g,
    ),
  );

  debugPrint('AdMob initialized successfully with debug logging');

  runApp(const ProviderScope(child: MathStepApp()));
}

class MathStepApp extends ConsumerWidget {
  const MathStepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageStateProvider);
    final locale = languageState.language.locale;

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
    );
  }
}
