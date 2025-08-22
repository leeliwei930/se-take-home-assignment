import 'dart:async';

import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/bot_provider_states.dart';
import 'package:food_order_simulator/providers/order_notifier_provider.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bot_providers.g.dart';

@riverpod
class BotsNotifier extends _$BotsNotifier {
  @override
  BotNotifierState build() {
    return BotNotifierState(bots: {}, botIdCounter: 0);
  }

  void addBot() {
    final bot = Bot(id: state.botIdCounter, orderFutureQueue: {});
    state = state.copyWith(
      bots: {...state.bots, bot.id: bot},
      botIdCounter: state.botIdCounter + 1,
    );
  }

  void removeLastAddedBot() {
    if (state.bots.isEmpty) return;
    final lastBot = state.bots.values.last;

    final bots = state.bots;
    bots.remove(lastBot.id);
    cancelAllOrderFromBot(lastBot);
    state = state.copyWith(bots: bots);
  }

  Bot? getIdleBot() {
    return state.bots.values.where((bot) => bot.status == BotStatus.idle).firstOrNull;
  }

  Bot? getBotById(int botId) {
    return state.bots[botId];
  }

  void poll() {
    final idleBot = getIdleBot();
    if (idleBot == null) return;

    final orderNotifier = ref.read(orderNotifierProvider);
    final vipOrder = orderNotifier.vipOrdersQueue.values
        .where((order) => order.status == OrderStatus.pending)
        .firstOrNull;
    final normalOrder = orderNotifier.normalOrdersQueue.values
        .where((order) => order.status == OrderStatus.pending)
        .firstOrNull;

    if (vipOrder != null) {
      assignOrderToBot(order: vipOrder, bot: idleBot);
    } else if (normalOrder != null) {
      assignOrderToBot(order: normalOrder, bot: idleBot);
    }
  }

  void assignOrderToBot({
    required Order order,
    required Bot bot,
  }) async {
    final orderNotifier = ref.read(orderNotifierProvider.notifier);

    final completedAt = DateTime.now().add(const Duration(seconds: 10));
    orderNotifier.updateOrderById(
      order.id,
      preparedBy: bot,
      completedAt: completedAt,
      status: OrderStatus.processing,
    );
    final orderId = order.id;

    final timer = Timer(
      const Duration(seconds: 10),
      () {
        _completeOrder(orderId);
      },
    );

    final newBot = bot.copyWith(
      orderFutureQueue: {...bot.orderFutureQueue, order.id: timer},
    );
    state = state.copyWith(bots: {...state.bots, bot.id: newBot});
  }

  void removeOrderFromBotJobQueue(int orderId, Bot bot) {
    final existingQueue = bot.orderFutureQueue;

    final timer = existingQueue.remove(orderId);
    if (timer != null) {
      timer.cancel();
    }

    final newBot = bot.copyWith(
      orderFutureQueue: existingQueue,
    );
    state = state.copyWith(bots: {...state.bots, bot.id: newBot});
  }

  void cancelAllOrderFromBot(Bot bot) {
    final orderNotifier = ref.read(orderNotifierProvider.notifier);
    final orderState = ref.read(orderNotifierProvider);
    bot.orderFutureQueue.forEach((orderId, timer) {
      final order = orderState.vipOrdersQueue[orderId] ?? orderState.normalOrdersQueue[orderId];
      // No op if order is not found
      if (order == null) return;

      // Don't cancel any order that is completed
      if (order.status == OrderStatus.completed) return;

      orderNotifier.updateOrderById(
        orderId,
        status: OrderStatus.pending,
        preparedBy: null,
        completedAt: null,
      );
      timer.cancel();
    });

    final newBot = bot.copyWith(orderFutureQueue: {});
    state = state.copyWith(bots: {...state.bots, bot.id: newBot});
  }

  void _completeOrder(int orderId) {
    final orderNotifier = ref.read(orderNotifierProvider.notifier);
    final orderNotifierState = ref.read(orderNotifierProvider);
    final order = orderNotifierState.vipOrdersQueue[orderId] ?? orderNotifierState.normalOrdersQueue[orderId];
    if (order == null) {
      return;
    }
    if (order.preparedBy == null || order.status == OrderStatus.completed) {
      return;
    }

    // Check if the bot is still available
    final bot = ref.read(botsNotifierProvider.notifier).getBotById(order.preparedBy!.id);
    if (bot == null) return;

    orderNotifier.updateOrderById(
      order.id,
      status: OrderStatus.completed,
      preparedBy: order.preparedBy,
      completedAt: order.completedAt,
    );
    removeOrderFromBotJobQueue(order.id, bot);
  }
}
