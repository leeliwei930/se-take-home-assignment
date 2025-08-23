import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/order_queue_provider.dart';

void main() {
  group('OrderQueue Provider', () {
    late ProviderContainer container;

    setUp(() {
      // Create a fresh ProviderContainer for each test
      // This ensures tests don't share state
      container = ProviderContainer();
    });

    tearDown(() {
      // Dispose the container after each test
      container.dispose();
    });

    group('Initial State', () {
      test('should initialize with correct default state', () {
        // Act
        final state = container.read(orderQueueProvider);

        // Assert
        expect(state.orderIdCounter, 0);
        expect(state.vipOrdersQueue, isEmpty);
        expect(state.normalOrdersQueue, isEmpty);
      });

      test('should have keepAlive set to true', () {
        // Arrange & Act
        final provider = orderQueueProvider;
        final state1 = container.read(provider);

        // Reading the provider multiple times should return the same instance
        final state2 = container.read(provider);

        // Assert
        expect(identical(state1, state2), isTrue);
      });
    });

    group('addVIPOrder', () {
      test('should add a VIP order to the queue', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);

        // Act
        notifier.addVIPOrder();

        // Assert
        final state = container.read(orderQueueProvider);
        expect(state.vipOrdersQueue.length, 1);
        expect(state.normalOrdersQueue.length, 0);
        expect(state.orderIdCounter, 1);

        final vipOrder = state.vipOrdersQueue[0];
        expect(vipOrder, isNotNull);
        expect(vipOrder!.id, 0);
        expect(vipOrder.status, OrderStatus.pending);
        expect(vipOrder.type, OrderPriority.vip);
        expect(vipOrder.preparedBy, isNull);
        expect(vipOrder.completedAt, isNull);
      });

      test('should add multiple VIP orders with incremental IDs', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);

        // Act
        notifier.addVIPOrder();
        notifier.addVIPOrder();
        notifier.addVIPOrder();

        // Assert
        final state = container.read(orderQueueProvider);
        expect(state.vipOrdersQueue.length, 3);
        expect(state.orderIdCounter, 3);

        expect(state.vipOrdersQueue[0]?.id, 0);
        expect(state.vipOrdersQueue[1]?.id, 1);
        expect(state.vipOrdersQueue[2]?.id, 2);

        // All should be VIP orders
        state.vipOrdersQueue.values.forEach((order) {
          expect(order.type, OrderPriority.vip);
          expect(order.status, OrderStatus.pending);
        });
      });
    });

    group('addNormalOrder', () {
      test('should add a normal order to the queue', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);

        // Act
        notifier.addNormalOrder();

        // Assert
        final state = container.read(orderQueueProvider);
        expect(state.normalOrdersQueue.length, 1);
        expect(state.vipOrdersQueue.length, 0);
        expect(state.orderIdCounter, 1);

        final normalOrder = state.normalOrdersQueue[0];
        expect(normalOrder, isNotNull);
        expect(normalOrder!.id, 0);
        expect(normalOrder.status, OrderStatus.pending);
        expect(normalOrder.type, OrderPriority.normal);
        expect(normalOrder.preparedBy, isNull);
        expect(normalOrder.completedAt, isNull);
      });

      test('should add multiple normal orders with incremental IDs', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);

        // Act
        notifier.addNormalOrder();
        notifier.addNormalOrder();
        notifier.addNormalOrder();

        // Assert
        final state = container.read(orderQueueProvider);
        expect(state.normalOrdersQueue.length, 3);
        expect(state.orderIdCounter, 3);

        expect(state.normalOrdersQueue[0]?.id, 0);
        expect(state.normalOrdersQueue[1]?.id, 1);
        expect(state.normalOrdersQueue[2]?.id, 2);

        // All should be normal orders
        state.normalOrdersQueue.values.forEach((order) {
          expect(order.type, OrderPriority.normal);
          expect(order.status, OrderStatus.pending);
        });
      });
    });

    group('Mixed Order Operations', () {
      test('should handle both VIP and normal orders with shared counter', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);

        // Act
        notifier.addVIPOrder(); // ID: 0
        notifier.addNormalOrder(); // ID: 1
        notifier.addVIPOrder(); // ID: 2
        notifier.addNormalOrder(); // ID: 3

        // Assert
        final state = container.read(orderQueueProvider);
        expect(state.orderIdCounter, 4);
        expect(state.vipOrdersQueue.length, 2);
        expect(state.normalOrdersQueue.length, 2);

        expect(state.vipOrdersQueue[0]?.id, 0);
        expect(state.normalOrdersQueue[1]?.id, 1);
        expect(state.vipOrdersQueue[2]?.id, 2);
        expect(state.normalOrdersQueue[3]?.id, 3);
      });
    });

    group('updateOrderById', () {
      test('should update VIP order status', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);
        notifier.addVIPOrder();

        // Act
        notifier.updateOrderById(0, status: OrderStatus.processing);

        // Assert
        final state = container.read(orderQueueProvider);
        final updatedOrder = state.vipOrdersQueue[0];
        expect(updatedOrder, isNotNull);
        expect(updatedOrder!.status, OrderStatus.processing);
        expect(updatedOrder.id, 0);
        expect(updatedOrder.type, OrderPriority.vip);
      });

      test('should update normal order status', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);
        notifier.addNormalOrder();

        // Act
        notifier.updateOrderById(0, status: OrderStatus.completed);

        // Assert
        final state = container.read(orderQueueProvider);
        final updatedOrder = state.normalOrdersQueue[0];
        expect(updatedOrder, isNotNull);
        expect(updatedOrder!.status, OrderStatus.completed);
        expect(updatedOrder.id, 0);
        expect(updatedOrder.type, OrderPriority.normal);
      });

      test('should update order with preparedBy bot', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);
        final bot = Bot(id: 1, orderTimerQueue: {});
        notifier.addVIPOrder();

        // Act
        notifier.updateOrderById(0, preparedBy: bot);

        // Assert
        final state = container.read(orderQueueProvider);
        final updatedOrder = state.vipOrdersQueue[0];
        expect(updatedOrder, isNotNull);
        expect(updatedOrder!.preparedBy, bot);
        expect(updatedOrder.status, OrderStatus.pending); // Should remain unchanged
      });

      test('should update order with completedAt timestamp', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);
        final completedAt = DateTime.now();
        notifier.addNormalOrder();

        // Act
        notifier.updateOrderById(0, completedAt: completedAt);

        // Assert
        final state = container.read(orderQueueProvider);
        final updatedOrder = state.normalOrdersQueue[0];
        expect(updatedOrder, isNotNull);
        expect(updatedOrder!.completedAt, completedAt);
        expect(updatedOrder.status, OrderStatus.pending); // Should remain unchanged
      });

      test('should update multiple properties at once', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);
        final bot = Bot(id: 2, orderTimerQueue: {});
        final completedAt = DateTime.now();
        notifier.addVIPOrder();

        // Act
        notifier.updateOrderById(
          0,
          status: OrderStatus.completed,
          preparedBy: bot,
          completedAt: completedAt,
        );

        // Assert
        final state = container.read(orderQueueProvider);
        final updatedOrder = state.vipOrdersQueue[0];
        expect(updatedOrder, isNotNull);
        expect(updatedOrder!.status, OrderStatus.completed);
        expect(updatedOrder.preparedBy, bot);
        expect(updatedOrder.completedAt, completedAt);
        expect(updatedOrder.id, 0);
        expect(updatedOrder.type, OrderPriority.vip);
      });

      test('should not modify anything when order ID does not exist', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);
        notifier.addVIPOrder();
        notifier.addNormalOrder();

        final stateBefore = container.read(orderQueueProvider);

        // Act
        notifier.updateOrderById(999, status: OrderStatus.completed);

        // Assert
        final stateAfter = container.read(orderQueueProvider);
        expect(stateAfter.vipOrdersQueue, stateBefore.vipOrdersQueue);
        expect(stateAfter.normalOrdersQueue, stateBefore.normalOrdersQueue);
        expect(stateAfter.orderIdCounter, stateBefore.orderIdCounter);
      });

      test('should find and update correct order among multiple orders', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);
        notifier.addVIPOrder(); // ID: 0
        notifier.addNormalOrder(); // ID: 1
        notifier.addVIPOrder(); // ID: 2
        notifier.addNormalOrder(); // ID: 3

        // Act
        notifier.updateOrderById(1, status: OrderStatus.processing);
        notifier.updateOrderById(2, status: OrderStatus.completed);

        // Assert
        final state = container.read(orderQueueProvider);

        // Check VIP orders
        expect(state.vipOrdersQueue[0]?.status, OrderStatus.pending); // Unchanged
        expect(state.vipOrdersQueue[2]?.status, OrderStatus.completed); // Updated

        // Check normal orders
        expect(state.normalOrdersQueue[1]?.status, OrderStatus.processing); // Updated
        expect(state.normalOrdersQueue[3]?.status, OrderStatus.pending); // Unchanged
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty state gracefully', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);

        // Act & Assert - should not throw
        expect(() => notifier.updateOrderById(0, status: OrderStatus.completed), returnsNormally);

        final state = container.read(orderQueueProvider);
        expect(state.vipOrdersQueue, isEmpty);
        expect(state.normalOrdersQueue, isEmpty);
        expect(state.orderIdCounter, 0);
      });

      test('should handle updates with null values correctly', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);
        notifier.addVIPOrder();

        // Act
        notifier.updateOrderById(0, status: null, preparedBy: null, completedAt: null);

        // Assert
        final state = container.read(orderQueueProvider);
        final order = state.vipOrdersQueue[0];
        expect(order, isNotNull);
        expect(order!.status, OrderStatus.pending); // Should remain unchanged
        expect(order.preparedBy, isNull);
        expect(order.completedAt, isNull);
      });

      test('should maintain order counter consistency', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);

        // Act
        for (int i = 0; i < 10; i++) {
          if (i % 2 == 0) {
            notifier.addVIPOrder();
          } else {
            notifier.addNormalOrder();
          }
        }

        // Assert
        final state = container.read(orderQueueProvider);
        expect(state.orderIdCounter, 10);
        expect(state.vipOrdersQueue.length, 5); // Even indices (0,2,4,6,8)
        expect(state.normalOrdersQueue.length, 5); // Odd indices (1,3,5,7,9)

        // Verify all IDs are unique and sequential
        final allOrders = [
          ...state.vipOrdersQueue.values,
          ...state.normalOrdersQueue.values,
        ];
        final orderIds = allOrders.map((order) => order.id).toList()..sort();
        expect(orderIds, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      });
    });

    group('State Immutability', () {
      test('should create new state instances on mutations', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);
        final initialState = container.read(orderQueueProvider);

        // Act
        notifier.addVIPOrder();
        final newState = container.read(orderQueueProvider);

        // Assert
        expect(identical(initialState, newState), isFalse);
        expect(initialState.orderIdCounter, 0);
        expect(newState.orderIdCounter, 1);
      });

      test('should not mutate original maps when updating', () {
        // Arrange
        final notifier = container.read(orderQueueProvider.notifier);
        notifier.addVIPOrder();
        notifier.addNormalOrder();

        final stateBeforeUpdate = container.read(orderQueueProvider);
        final vipQueueBefore = stateBeforeUpdate.vipOrdersQueue;
        final normalQueueBefore = stateBeforeUpdate.normalOrdersQueue;

        // Act
        notifier.updateOrderById(0, status: OrderStatus.completed);

        // Assert
        final stateAfterUpdate = container.read(orderQueueProvider);

        // Original maps should be unchanged
        expect(vipQueueBefore[0]?.status, OrderStatus.pending);
        expect(normalQueueBefore[1]?.status, OrderStatus.pending);

        // New state should have updated order
        expect(stateAfterUpdate.vipOrdersQueue[0]?.status, OrderStatus.completed);
        expect(stateAfterUpdate.normalOrdersQueue[1]?.status, OrderStatus.pending);
      });
    });

    group('Constants', () {
      test('should have correct cooking duration constant', () {
        expect(kCookingDuration, 10);
      });
    });
  });
}
