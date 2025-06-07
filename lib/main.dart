import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/transaction_service.dart';
import 'services/user_profile_service.dart';
import 'services/savings_goal_service.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'utils/constants.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA383jn2WKO9PjcqyBnOZ4u7xZp7m4XXRY", // À remplacer
        appId: "1:123456789:android:abcdef", // À remplacer
        messagingSenderId: "123456789", // À remplacer
        projectId: "budgetease-xxxxx", // À remplacer
        storageBucket: "budgetease-xxxxx.appspot.com", // À remplacer
      ),
    );
    runApp(const MyApp());
  } catch (e) {
    print('Erreur d\'initialisation Firebase: $e');
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TransactionService>(create: (_) => TransactionService()),
        Provider<UserProfileService>(create: (_) => UserProfileService()),
        Provider<SavingsGoalService>(create: (_) => SavingsGoalService()),
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'BudgetEase',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const RootWidget(),
      ),
    );
  }
}

class RootWidget extends StatelessWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
