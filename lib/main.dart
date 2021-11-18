import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './ui/home_screen.dart';
import './providers/weight_provider.dart';
import './ui/manage_weight/manage_weight_screen.dart';
import './ui/auth/auth_screen.dart';
import './constants/firebase_constants.dart' as fb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      key: ObjectKey(fb.firebaseAuth.currentUser?.uid),
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => WeightProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: fb.firebaseAuth.authStateChanges(),
          builder: (ctx, userSnapshot) {
            print('user found');
            if (userSnapshot.hasData) {
              return const HomeScreen();
            }
            print('user lost');

            return const AuthScreen();
          },
        ),
        routes: {
          ManageWeightScreen.routeName: (ctx) => const ManageWeightScreen(),
        },
      ),
    );
  }
}
