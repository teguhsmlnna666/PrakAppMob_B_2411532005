import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final loggedIn = await SessionService.isLoggedIn();

  runApp(
    ExpenseTrackerApp(
      initialRoute: loggedIn ? '/' : '/login',
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  final String initialRoute;

  const ExpenseTrackerApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',

      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,

        scaffoldBackgroundColor: Colors.white,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          floatingLabelStyle: TextStyle(
            color: Colors.blue,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),

        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.blue,
        ),
      ),

      initialRoute: initialRoute,

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/': (context) => const MainScreen(),
        '/add': (context) => const AddTransactionScreen(),
      },
    );
  }
}