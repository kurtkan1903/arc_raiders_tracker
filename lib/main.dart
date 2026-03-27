import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';

// Tema kontrolü için global bir bildirimci
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Kayıtlı tema tercihini yükle
  final prefs = await SharedPreferences.getInstance();
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? true;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  runApp(const ArcRaidersApp());
}

class ArcRaidersApp extends StatelessWidget {
  const ArcRaidersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ARC Raiders Tracker', // Raider -> Raiders olarak düzeltildi
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: Colors.orangeAccent,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: Colors.orangeAccent,
            scaffoldBackgroundColor: const Color(0xFF0A0A0A),
            appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
