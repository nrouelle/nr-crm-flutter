import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/prospects_page.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRM Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF023047),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF023047), // Bleu marine profond
          secondary: const Color(0xFF219ebc), // Turquoise
          tertiary: const Color(0xFFffb703), // Jaune doré
          surface: const Color(0xFFf8fffe),
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF023047),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: const Color(0xFF023047).withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFfb8500), // Orange vif
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF219ebc),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        // Erreur d'initialisation Firebase
        if (snapshot.hasError) {
          AppLogger.error(
            'Erreur d\'initialisation Firebase',
            snapshot.error,
            snapshot.stackTrace,
          );
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Erreur d\'initialisation Firebase',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vérifiez votre configuration Firebase',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      AppLogger.info('Tentative de redémarrage de l\'application');
                      // Force un rebuild du widget
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        // Firebase en cours d'initialisation
        if (snapshot.connectionState == ConnectionState.waiting) {
          AppLogger.info('Initialisation Firebase en cours...');
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initialisation...'),
                ],
              ),
            ),
          );
        }

        // Firebase initialisé, vérifier l'authentification
        AppLogger.info('Firebase initialisé avec succès');
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              AppLogger.debug('Vérification de l\'état d\'authentification...');
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              AppLogger.error(
                'Erreur lors de la vérification d\'authentification',
                snapshot.error,
                snapshot.stackTrace,
              );
            }

            if (snapshot.hasData) {
              AppLogger.info('Utilisateur connecté: ${snapshot.data?.email}');
              return const ProspectsPage(title: 'CRM Flutter');
            } else {
              AppLogger.info('Utilisateur non connecté, redirection vers login');
              return const LoginPage();
            }
          },
        );
      },
    );
  }
}

