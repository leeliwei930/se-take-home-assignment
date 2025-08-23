import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/providers/order_queue_provider.dart';
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
      child: Wrap(
        children: [
          FilledButton.icon(
            icon: Icon(Icons.add),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue[100],
              foregroundColor: Colors.black,
            ),
            label: const Text(
              'New Normal Order',
            ),
            onPressed: () {
              final orderNotifier = ref.read(orderQueueProvider.notifier);

              orderNotifier.addNormalOrder();
            },
          ),
          const SizedBox(width: kSpacingXSmall),
          FilledButton.icon(
            icon: Icon(Icons.add),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            label: const Text(
              'New VIP Order',
            ),
            onPressed: () {
              final orderQueueNotifier = ref.read(orderQueueProvider.notifier);

              orderQueueNotifier.addVIPOrder();
            },
          ),
        ],
      ),
    );
  }
}
