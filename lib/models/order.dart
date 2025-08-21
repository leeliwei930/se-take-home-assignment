import 'dart:async';

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
    required this.cookTimer,
    required this.status,
    required this.type,
    this.preparedBy,
  });

  final int id;
  final Timer cookTimer;
  final OrderStatus status;
  final OrderPriority type;
  final Bot? preparedBy;

  @override
  List<Object?> get props => [id, cookTimer, status, type, preparedBy];
}
