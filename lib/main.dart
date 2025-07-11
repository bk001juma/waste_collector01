import 'package:RecycleHub/provider/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:RecycleHub/admin/admin.dart';
import 'package:RecycleHub/user/home.dart';
import 'package:RecycleHub/user/login.dart';
import 'package:RecycleHub/user/register.dart';
import 'package:RecycleHub/user/schedule.dart';
import 'package:RecycleHub/user/tips.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'RecycleHub',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomePage(uid: ''),
        '/schedule': (context) => SchedulePickupForm(
              initialAdditionalNotes: '',
              initialAmountOfWaste: 0,
              initialPickupTime: '',
              initialPickupDate: DateTime.now(),
              initialWasteType: '',
              scheduleId: '',
              initialStreet: '',
            ),
        '/tips': (context) => const RecyclingTips(),
        '/admin': (context) => const AdminApp(uid: ''),
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0E4911),
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0E4911),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xFF121212)
          : Colors.white,
    );
  }
}
