import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/screens/home_screen.dart';

class FoodOrderSimulatorApp extends StatefulWidget {
  const FoodOrderSimulatorApp({super.key});

  @override
  State<FoodOrderSimulatorApp> createState() => _FoodOrderSimulatorAppState();
}

class _FoodOrderSimulatorAppState extends State<FoodOrderSimulatorApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
      ),
    );
  }
}
