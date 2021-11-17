import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './ui/home_screen.dart';
import './providers/weight_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => WeightProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (ctx) => const HomeScreen(),
        },
      ),
    );
  }
}
