import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/models/order.dart';

void main() {
  group('Order', () {
    test('should create an Order with required properties', () {
      // Arrange
      final id = 1;
      final status = OrderStatus.pending;
      final type = OrderPriority.normal;

      // Act
      final order = Order(
        id: id,
        status: status,
        type: type,
      );

      // Assert
      expect(order.id, id);
      expect(order.status, status);
      expect(order.type, type);
      expect(order.preparedBy, null);
      expect(order.completedAt, null);
    });

    test('should create an Order with all properties', () {
      // Arrange
      final id = 1;
      final status = OrderStatus.completed;
      final type = OrderPriority.vip;
      final bot = Bot(id: 1, orderTimerQueue: {});
      final completedAt = DateTime.now();

      // Act
      final order = Order(
        id: id,
        status: status,
        type: type,
        preparedBy: bot,
        completedAt: completedAt,
      );

      // Assert
      expect(order.id, id);
      expect(order.status, status);
      expect(order.type, type);
      expect(order.preparedBy, bot);
      expect(order.completedAt, completedAt);
    });

    test('copyWith should return a new Order with updated status', () {
      // Arrange
      final order = Order(id: 1, status: OrderStatus.pending, type: OrderPriority.normal);

      // Act
      final updatedOrder = order.copyWith(status: OrderStatus.processing);

      // Assert
      expect(updatedOrder.id, order.id);
      expect(updatedOrder.status, OrderStatus.processing);
      expect(updatedOrder.type, order.type);
      expect(updatedOrder.preparedBy, order.preparedBy);
      expect(updatedOrder.completedAt, order.completedAt);
    });

    test('copyWith should return a new Order with updated type', () {
      // Arrange
      final order = Order(id: 1, status: OrderStatus.pending, type: OrderPriority.normal);

      // Act
      final updatedOrder = order.copyWith(type: OrderPriority.vip);

      // Assert
      expect(updatedOrder.id, order.id);
      expect(updatedOrder.status, order.status);
      expect(updatedOrder.type, OrderPriority.vip);
      expect(updatedOrder.preparedBy, order.preparedBy);
      expect(updatedOrder.completedAt, order.completedAt);
    });

    test('copyWith should return a new Order with updated preparedBy', () {
      // Arrange
      final order = Order(id: 1, status: OrderStatus.pending, type: OrderPriority.normal);
      final bot = Bot(id: 2, orderTimerQueue: {});

      // Act
      final updatedOrder = order.copyWith(preparedBy: bot);

      // Assert
      expect(updatedOrder.id, order.id);
      expect(updatedOrder.status, order.status);
      expect(updatedOrder.type, order.type);
      expect(updatedOrder.preparedBy, bot);
      expect(updatedOrder.completedAt, order.completedAt);
    });

    test('copyWith should return a new Order with updated completedAt', () {
      // Arrange
      final order = Order(id: 1, status: OrderStatus.pending, type: OrderPriority.normal);
      final completedAt = DateTime.now();

      // Act
      final updatedOrder = order.copyWith(completedAt: completedAt);

      // Assert
      expect(updatedOrder.id, order.id);
      expect(updatedOrder.status, order.status);
      expect(updatedOrder.type, order.type);
      expect(updatedOrder.preparedBy, order.preparedBy);
      expect(updatedOrder.completedAt, completedAt);
    });

    test('copyWith should return a new Order with multiple updated properties', () {
      // Arrange
      final order = Order(id: 1, status: OrderStatus.pending, type: OrderPriority.normal);
      final bot = Bot(id: 3, orderTimerQueue: {});
      final completedAt = DateTime.now();

      // Act
      final updatedOrder = order.copyWith(
        status: OrderStatus.completed,
        preparedBy: bot,
        completedAt: completedAt,
      );

      // Assert
      expect(updatedOrder.id, order.id);
      expect(updatedOrder.status, OrderStatus.completed);
      expect(updatedOrder.type, order.type);
      expect(updatedOrder.preparedBy, bot);
      expect(updatedOrder.completedAt, completedAt);
    });

    test('props should contain id, status, type, preparedBy and completedAt', () {
      // Arrange
      final id = 1;
      final status = OrderStatus.pending;
      final type = OrderPriority.normal;
      final bot = Bot(id: 4, orderTimerQueue: {});
      final completedAt = DateTime.now();
      final order = Order(
        id: id,
        status: status,
        type: type,
        preparedBy: bot,
        completedAt: completedAt,
      );

      // Act & Assert
      expect(order.props, [id, status, type, bot, completedAt]);
    });

    test('orders with same properties should be equal', () {
      // Arrange
      final order1 = Order(id: 1, status: OrderStatus.pending, type: OrderPriority.normal);
      final order2 = Order(id: 1, status: OrderStatus.pending, type: OrderPriority.normal);

      // Act & Assert
      expect(order1, equals(order2));
    });

    test('orders with different properties should not be equal', () {
      // Arrange
      final order1 = Order(id: 1, status: OrderStatus.pending, type: OrderPriority.normal);
      final order2 = Order(id: 2, status: OrderStatus.pending, type: OrderPriority.normal);
      final order3 = Order(id: 1, status: OrderStatus.processing, type: OrderPriority.normal);
      final order4 = Order(id: 1, status: OrderStatus.pending, type: OrderPriority.vip);

      // Act & Assert
      expect(order1, isNot(equals(order2)));
      expect(order1, isNot(equals(order3)));
      expect(order1, isNot(equals(order4)));
    });
  });
}
