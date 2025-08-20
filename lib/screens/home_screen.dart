import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/screens/constants/spacing.dart';
import 'package:food_order_simulator/screens/sections/bot_panel_section.dart';
import 'package:food_order_simulator/screens/sections/order_panel_section.dart';
import 'package:food_order_simulator/screens/sections/order_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Food Order Simulator"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OrderPanelSection(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacingMedium,
                  vertical: kSpacingSmall,
                ),
                children: [
                  OrderSection(
                    title: 'PENDING',
                    backgroundColor: Colors.orange[50]!,
                  ),
                  OrderSection(
                    title: 'COMPLETED',
                    backgroundColor: Colors.green[50]!,
                  ),
                ],
              ),
            ),
            BotPanelSection(),
          ],
        ),
      ),
    );
  }
}
