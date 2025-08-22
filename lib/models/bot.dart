import 'package:equatable/equatable.dart';
import 'package:food_order_simulator/models/order.dart';

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
  final Map<int, Future<void>> orderFutureQueue;

  @override
  List<Object?> get props => [id, orderFutureQueue];

  Bot copyWith({
    int? id,
    Map<int, Future<void>>? orderFutureQueue,
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
