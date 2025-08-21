import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/order_notifier_provider.dart';
import 'package:food_order_simulator/providers/order_providers.dart';
import 'package:food_order_simulator/screens/constants/shadow.dart';
import 'package:food_order_simulator/screens/constants/spacing.dart';

class OrderPanelSection extends ConsumerWidget {
  const OrderPanelSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: kBoxShadowLight,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingSmall,
        vertical: kSpacingSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FilledButton.icon(
              icon: Icon(Icons.add),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.black,
              ),
              label: const Text('New Normal Order'),
              onPressed: () {
                final orderNotifier = ref.read(orderNotifierProvider.notifier);

                orderNotifier.addNormalOrder();
              },
            ),
          ),
          const SizedBox(width: kSpacingXSmall),
          Expanded(
            child: FilledButton.icon(
              icon: Icon(Icons.add),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              label: const Text('New VIP Order'),
              onPressed: () {
                final orderNotifier = ref.read(orderNotifierProvider.notifier);

                orderNotifier.addVIPOrder();
              },
            ),
          ),
        ],
      ),
    );
  }
}
