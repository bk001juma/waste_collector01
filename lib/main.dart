import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:collector/user/login.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Setup logging
  _setupLogger();

  runApp(const MyApp());
}

/// Configures the global logger
void _setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.level.name} | ${record.time} | ${record.loggerName}: ${record.message}',
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecycleHub',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        // Define other routes here, like '/home': (context) => HomePage()
      },
    );
  }

  /// Custom Material 3 theme
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0E4911), // Recycle green tone
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0E4911),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      scaffoldBackgroundColor: Colors.white,
    );
  }
}
