import 'package:equatable/equatable.dart';
import 'package:food_order_simulator/models/bot.dart';

enum OrderStatus {
  pending,
  processing,
  completed,
}

enum OrderPriority {
  normal,
  vip,
}

class Order extends Equatable {
  Order({
    required this.id,
    required this.status,
    required this.type,
    this.preparedBy,
    this.completedAt,
  });

  final int id;
  final OrderStatus status;
  final OrderPriority type;
  final Bot? preparedBy;
  final DateTime? completedAt;

  @override
  List<Object?> get props => [id, status, type, preparedBy, completedAt];

  Order copyWith({
    OrderStatus? status,
    OrderPriority? type,
    Bot? preparedBy,
    DateTime? completedAt,
  }) {
    return Order(
      id: id,
      completedAt: completedAt,
      status: status ?? this.status,
      type: type ?? this.type,
      preparedBy: preparedBy,
    );
  }
}
