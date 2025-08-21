import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/providers/bot_notifier_provider.dart';
import 'package:food_order_simulator/screens/constants/shadow.dart';
import 'package:food_order_simulator/screens/constants/spacing.dart';
import 'package:food_order_simulator/widgets/bot_avatar.dart';

class BotPanelSection extends ConsumerWidget {
  const BotPanelSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botNotifierState = ref.watch(botNotifierProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: kBoxShadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kSpacingMedium,
              vertical: kSpacingSmall,
            ),
            child: Text('BOT Control Panel'),
          ),
          SizedBox(
            height: 100,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: botNotifierState.bots.length,
              padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
              separatorBuilder: (context, index) {
                return const SizedBox(width: kSpacingXSmall);
              },
              itemBuilder: (context, index) {
                final bot = botNotifierState.bots[index];
                return IntrinsicHeight(
                  child: BotAvatar(
                    caption: 'Bot ${bot.id}',
                    backgroundColor: bot.status == BotStatus.idle ? Colors.blue[200] : Colors.green[200],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(kSpacingXSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    ref.read(botNotifierProvider.notifier).addBot();
                  },
                  icon: Icon(Icons.add),
                  label: const Text('Bot'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.lightBlue[100],
                    foregroundColor: Colors.blue[900],
                  ),
                ),
                const SizedBox(width: kSpacingXSmall),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(botNotifierProvider.notifier).removeLastAddedBot();
                  },
                  icon: Icon(Icons.remove),
                  label: const Text('Bot'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red[300],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
