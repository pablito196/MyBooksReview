import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'navigation/app_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/books_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; 
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; 
import 'package:my_book_review_flutter/utils/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const useFirebaseEmulators = true;

  if (useFirebaseEmulators) {
    
    final String emulatorHost = kIsWeb ? 'localhost' : '192.168.0.100';

    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8181);
    FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
    FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);

    
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug, 
      appleProvider: AppleProvider.debug,     
      
      webProvider: ReCaptchaV3Provider('6LeIxAcTAAAAAJcZVRqyHh7ROCRnJNPrbuTG_TPz'),
    );
    
    await seedUsersWithAuth();
  } else {
    
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity, 
      appleProvider: AppleProvider.deviceCheck,      
      webProvider: ReCaptchaV3Provider('TU_CLAVE_RECAPTCHA_V3_PARA_PRODUCCION_WEB'),
    );
    
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    const bool isAuthenticated = false; 

    return ChangeNotifierProvider(
      create: (_) => BooksProvider()..getBooks(), 
      child: MaterialApp(
        title: 'Book Review',
        theme: ThemeData(
          
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF2E7D32), 
            onPrimary: Colors.white,
            secondary: Color(0xFF81C784),
            onSecondary: Colors.black,
            error: Color(0xFFC62828), 
            onError: Colors.white,
            surface: Colors.white, 
            onSurface: Colors.black,
          ),
          scaffoldBackgroundColor: const Color(0xFFF1F8E9), 
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32), 
            foregroundColor: Colors.white, 
            elevation: 2, 
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide.none, 
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32), 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), 
              ),
              padding: const EdgeInsets.symmetric(vertical: 16), 
            ),
          ),
        ),
       
        home: isAuthenticated ? const MainNavigation() : const LoginScreen(),
        
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainNavigation(),
        },
      ),
    );
  }
}