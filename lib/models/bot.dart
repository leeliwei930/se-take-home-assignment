import 'dart:async';

import 'package:equatable/equatable.dart';

enum BotStatus {
  idle,
  cooking,
}

class Bot extends Equatable {
  const Bot({
    required this.id,
    required this.orderFutureQueue,
  });

  final int id;
  final Map<int, Timer> orderFutureQueue;

  @override
  List<Object?> get props => [id, orderFutureQueue];

  Bot copyWith({
    int? id,
    Map<int, Timer>? orderFutureQueue,
  }) {
    return Bot(
      id: id ?? this.id,
      orderFutureQueue: orderFutureQueue ?? this.orderFutureQueue,
    );
  }

  BotStatus get status {
    if (orderFutureQueue.isEmpty) return BotStatus.idle;
    return BotStatus.cooking;
  }
}
