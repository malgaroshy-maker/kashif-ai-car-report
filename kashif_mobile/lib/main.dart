import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'data/storage/hive_storage.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KashifStorage.init();
  runApp(const ProviderScope(child: KashifApp()));
}

class KashifApp extends ConsumerWidget {
  const KashifApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'كاشف AI',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: KashifTheme.lightTheme(),
      darkTheme: KashifTheme.darkTheme(),
      themeMode: settings.themeMode,
      home: const HomeScreen(),
    );
  }
}
