import 'package:equatable/equatable.dart';
import 'package:food_order_simulator/models/order.dart';

enum BotStatus {
  idle,
  cooking,
}

class Bot extends Equatable {
  const Bot({
    required this.id,
    required this.status,
    required this.orderFutureQueue,
  });

  final int id;
  final BotStatus status;
  final Map<int, Future<void>> orderFutureQueue;

  @override
  List<Object?> get props => [id, status, orderFutureQueue];

  Bot copyWith({
    int? id,
    Map<int, Future<void>>? orderFutureQueue,
    BotStatus? status,
  }) {
    return Bot(
      id: id ?? this.id,
      status: status ?? this.status,
      orderFutureQueue: orderFutureQueue ?? this.orderFutureQueue,
    );
  }
}
