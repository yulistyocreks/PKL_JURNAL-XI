import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
const String appVersion = '2.0.11';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

Future<void> muatThemeTersimpan() async {
  final prefs = await SharedPreferences.getInstance();
  final mode = prefs.getString('theme_mode');
  if (mode == 'light') themeModeNotifier.value = ThemeMode.light;
  if (mode == 'dark') themeModeNotifier.value = ThemeMode.dark;
}

Future<void> simpanThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
  themeModeNotifier.value = mode;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await muatThemeTersimpan();
  runApp(const AktivitasPklApp());
}

class AktivitasPklApp extends StatelessWidget {
  const AktivitasPklApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0));
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: Brightness.dark,
    );

    ThemeData buatTheme(ColorScheme scheme) => ThemeData(
          useMaterial3: true,
          colorScheme: scheme,
          scaffoldBackgroundColor: scheme.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: scheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: scheme.surface,
            indicatorColor: scheme.primaryContainer,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'XI JURNAL PKL',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: buatTheme(lightScheme),
          darkTheme: buatTheme(darkScheme),
          home: const SplashScreen(),
        );
      },
    );
  }
}
