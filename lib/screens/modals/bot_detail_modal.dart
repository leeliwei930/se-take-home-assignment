import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/providers/bot_providers.dart';
import 'package:food_order_simulator/providers/order_notifier_provider.dart';
import 'package:food_order_simulator/screens/constants/spacing.dart';
import 'package:food_order_simulator/widgets/bot_avatar.dart';
import 'package:food_order_simulator/widgets/job_timer.dart';

class BotDetailModal extends ConsumerWidget {
  const BotDetailModal({super.key, required this.botId, required this.index});
  final int botId;
  final int index;

  static show(BuildContext context, {required int botId, required int index}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BotDetailModal(
        botId: botId,
        index: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bot = ref.watch(botFactoryProvider(id: botId));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kSpacingMedium),
      child: Column(
        children: [
          BotAvatar(
            caption: 'Bot $index',
            backgroundColor: bot.status == BotStatus.idle ? Colors.green[200] : Colors.red[200],
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            switch (bot.status) {
              BotStatus.idle => 'Idle',
              BotStatus.cooking => 'Cooking',
            },
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            '${bot.orderTimerQueue.length} orders in job queue',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: bot.orderTimerQueue.length,
              itemBuilder: (context, index) {
                final orderNotifier = ref.watch(orderNotifierProvider);
                final orderId = bot.orderTimerQueue.keys.elementAt(index);
                final order = orderNotifier.vipOrdersQueue[orderId] ?? orderNotifier.normalOrdersQueue[orderId];

                if (order == null || order.completedAt == null) {
                  return const SizedBox.shrink();
                }

                return ListTile(
                  title: Text('Order $orderId'),
                  trailing: JobTimer(endTime: order.completedAt!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
