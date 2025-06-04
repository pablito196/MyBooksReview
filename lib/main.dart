// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'navigation/app_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/books_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Por ahora, usaremos un estado hardcodeado
    const bool isAuthenticated = false;

    return ChangeNotifierProvider(
      create: (_) => BooksProvider()..getBooks(), 
      child: MaterialApp(
        title: 'Book Review',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: isAuthenticated ? const MainNavigation() : const LoginScreen(),
        routes: {
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainNavigation(),
        },
      ),
    );
  }
}
