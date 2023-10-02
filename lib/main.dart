import 'package:brl_course_review_app/firebase_options.dart';
import 'package:brl_course_review_app/login.dart';
import 'package:brl_course_review_app/review_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get user => _auth.currentUser;
  bool get isLoggedIn => user != null && user!.emailVerified;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'BRL COURSE REVIEW',
        theme: ThemeData.light(
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark(
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: isLoggedIn ? const ReviewScreen() : const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/review': (context) => const ReviewScreen(),
          '/logout': (context) => const LoginScreen(),
          '/signup': (context) => const LoginScreen(),
          '/forgot-password': (context) => const LoginScreen(),
        });
  }
}
