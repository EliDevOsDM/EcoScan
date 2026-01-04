import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
      title: 'EcoScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Verde hoja
          primary: const Color(0xFF4CAF50), // Verde hoja
          secondary: const Color(0xFFA5D6A7), // Verde claro
          tertiary: const Color(0xFF00ACC1), // Azul agua
          surface: const Color(0xFFF5F5F5), // Blanco humo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Blanco humo
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFF333333), // Gris oscuro
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Verde hoja
          primary: const Color(0xFF66BB6A), // Verde más claro para dark mode
          secondary: const Color(0xFF81C784), // Verde claro para dark mode
          tertiary: const Color(0xFF26C6DA), // Azul agua más claro
          surface: const Color(0xFF1E1E1E), // Superficie oscura
          background: const Color(0xFF121212), // Fondo oscuro
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212), // Fondo oscuro
        cardTheme: CardTheme(
          elevation: 4,
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFFE0E0E0), // Texto claro para dark mode
          ),
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: const LoginScreen(),
        );
      },
    );
  }
}
