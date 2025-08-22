import 'dart:async';

import 'package:equatable/equatable.dart';

enum BotStatus {
  idle,
  cooking,
}

const kMaxBotCookingOrders = 1;

class Bot extends Equatable {
  const Bot({
    required this.id,
    required this.orderTimerQueue,
  });

  final int id;
  final Map<int, Timer> orderTimerQueue;

  @override
  List<Object?> get props => [id, orderTimerQueue];

  Bot copyWith({
    int? id,
    Map<int, Timer>? orderTimerQueue,
  }) {
    return Bot(
      id: id ?? this.id,
      orderTimerQueue: orderTimerQueue ?? this.orderTimerQueue,
    );
  }

  BotStatus get status {
    if (orderTimerQueue.length >= kMaxBotCookingOrders) {
      return BotStatus.cooking;
    }

    return BotStatus.idle;
  }
}
