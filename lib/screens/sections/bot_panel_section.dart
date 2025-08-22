import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/providers/bot_providers.dart';
import 'package:food_order_simulator/screens/constants/shadow.dart';
import 'package:food_order_simulator/screens/constants/spacing.dart';
import 'package:food_order_simulator/screens/modals/bot_detail_modal.dart';
import 'package:food_order_simulator/widgets/bot_avatar.dart';

class BotPanelSection extends ConsumerWidget {
  const BotPanelSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botsOrchestrator = ref.watch(botsOrchestratorProvider);
    final bottomInsets = MediaQuery.of(context).viewPadding.bottom;

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
              itemCount: botsOrchestrator.botIds.keys.length,
              padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
              separatorBuilder: (context, index) {
                return const SizedBox(width: kSpacingXSmall);
              },
              itemBuilder: (context, index) {
                final botId = botsOrchestrator.botIds.keys.elementAt(index);
                final bot = ref.watch(botFactoryProvider(id: botId));

                return IntrinsicHeight(
                  child: BotAvatar(
                    caption: 'Bot ${index + 1}',
                    backgroundColor: bot.status == BotStatus.idle ? Colors.green[200] : Colors.red[200],
                    onTap: () => BotDetailModal.show(
                      context,
                      botId: bot.id,
                      index: index + 1,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: kSpacingXSmall,
              right: kSpacingXSmall,
              bottom: kSpacingXSmall + bottomInsets,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    ref.read(botsOrchestratorProvider.notifier).addBot();
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
                    ref.read(botsOrchestratorProvider.notifier).removeLastAddedBot();
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
