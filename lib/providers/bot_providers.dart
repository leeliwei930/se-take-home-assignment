import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/bot_provider_states.dart';
import 'package:food_order_simulator/providers/order_queue_provider.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bot_providers.g.dart';

const kBotCookingDuration = 10;

@riverpod
class BotFactory extends _$BotFactory {
  @override
  Bot build({
    required int id,
  }) {
    ref.onDispose(() {
      if (kDebugMode) {
        log('BotFactory disposed: $id');
      }
    });

    return Bot(
      id: id,
      orderTimerQueue: {},
    );
  }

  void enqueueOrder(Order order) {
    final orderQueueNotifier = ref.read(orderQueueProvider.notifier);

    final completedAt = DateTime.now().add(const Duration(seconds: kBotCookingDuration));
    orderQueueNotifier.updateOrderById(
      order.id,
      preparedBy: state,
      status: OrderStatus.processing,
      completedAt: completedAt,
    );

    final timer = Timer(
      const Duration(seconds: kBotCookingDuration),
      () => _completeOrder(order.id),
    );

    final newBot = state.copyWith(
      orderTimerQueue: {...state.orderTimerQueue, order.id: timer},
    );
    state = newBot;
  }

  void dropAllOrders() {
    final bot = state;
    if (bot.orderTimerQueue.isEmpty) return;

    bot.orderTimerQueue.forEach((orderId, timer) {
      timer.cancel();

      final orderQueueNotifier = ref.read(orderQueueProvider.notifier);
      orderQueueNotifier.updateOrderById(
        orderId,
        status: OrderStatus.pending,
        preparedBy: null,
        completedAt: null,
      );
    });

    // Clear the bot's order timer queue
    final newBot = state.copyWith(orderTimerQueue: {});
    state = newBot;
  }

  void _completeOrder(int orderId) {
    final orderQueueNotifier = ref.read(orderQueueProvider.notifier);
    final orderQueueState = ref.read(orderQueueProvider);

    final order = orderQueueState.vipOrdersQueue[orderId] ?? orderQueueState.normalOrdersQueue[orderId];
    if (order == null) return;

    orderQueueNotifier.updateOrderById(
      orderId,
      status: OrderStatus.completed,
      preparedBy: state,
      completedAt: order.completedAt,
    );

    final jobQueue = state.orderTimerQueue;
    final timer = jobQueue.remove(orderId);
    if (timer != null) {
      timer.cancel();
    }

    final newBot = state.copyWith(orderTimerQueue: jobQueue);
    state = newBot;
  }
}

@riverpod
class BotsOrchestrator extends _$BotsOrchestrator {
  @override
  BotsOrchestratorState build() {
    return BotsOrchestratorState(botIdCounter: 0, botIds: {});
  }

  void addBot() {
    state = state.copyWith(
      botIdCounter: state.botIdCounter + 1,
      botIds: {...state.botIds, state.botIdCounter: true},
    );
  }

  void removeLastAddedBot() {
    if (state.botIds.isEmpty) return;

    final lastBotId = state.botIds.keys.last;
    final botNotifier = ref.read(botFactoryProvider(id: lastBotId).notifier);
    botNotifier.dropAllOrders();

    final botsIds = state.botIds;
    botsIds.remove(lastBotId);

    state = state.copyWith(botIds: botsIds);
  }

  Bot? getIdleBot() {
    final botIds = state.botIds.keys;
    for (var botId in botIds) {
      final bot = ref.read(botFactoryProvider(id: botId));
      if (bot.status == BotStatus.idle) {
        return bot;
      }
    }
    return null;
  }

  void poll() {
    final idleBot = getIdleBot();
    if (idleBot == null) return;

    final orderQueueState = ref.read(orderQueueProvider);
    final vipOrder = orderQueueState.vipOrdersQueue.values
        .where((order) => order.status == OrderStatus.pending)
        .firstOrNull;

    final botNotifier = ref.read(botFactoryProvider(id: idleBot.id).notifier);

    if (vipOrder != null) {
      botNotifier.enqueueOrder(vipOrder);
      return;
    }

    final normalOrder = orderQueueState.normalOrdersQueue.values
        .where((order) => order.status == OrderStatus.pending)
        .firstOrNull;
    if (normalOrder != null) {
      botNotifier.enqueueOrder(normalOrder);
      return;
    }
  }
}
