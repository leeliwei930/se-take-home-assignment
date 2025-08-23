import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/order_queue_provider.dart';
import 'package:food_order_simulator/providers/order_queue_state.dart';
import 'package:food_order_simulator/providers/order_providers.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('Order Providers', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    /// Helper method to create a container with overridden OrderQueue state
    ProviderContainer createContainer({required OrderQueueState orderQueueState}) {
      final mockOrderQueue = MockOrderQueue();
      when(() => mockOrderQueue.build()).thenReturn(orderQueueState);

      return ProviderContainer(
        overrides: [
          // Override the orderQueueProvider to return our test state
          orderQueueProvider.overrideWith(() => mockOrderQueue),
        ],
      );
    }

    /// Helper method to create test orders
    List<Order> createTestOrders() {
      return [
        Order(id: 1, status: OrderStatus.pending, type: OrderPriority.vip),
        Order(id: 2, status: OrderStatus.processing, type: OrderPriority.normal),
        Order(id: 3, status: OrderStatus.completed, type: OrderPriority.vip),
        Order(id: 4, status: OrderStatus.completed, type: OrderPriority.normal),
        Order(id: 5, status: OrderStatus.pending, type: OrderPriority.normal),
      ];
    }

    group('CompletedOrders Provider', () {
      test('should return empty list when no completed orders exist', () {
        // Arrange
        final orderQueueState = OrderQueueState(
          orderIdCounter: 0,
          vipOrdersQueue: {},
          normalOrdersQueue: {},
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final completedOrders = container.read(completedOrdersProvider);

        // Assert
        expect(completedOrders, isEmpty);
      });

      test('should return only completed orders from both VIP and normal queues', () {
        // Arrange
        final orders = createTestOrders();
        final orderQueueState = OrderQueueState(
          orderIdCounter: 5,
          vipOrdersQueue: {
            1: orders[0], // pending
            3: orders[2], // completed
          },
          normalOrdersQueue: {
            2: orders[1], // processing
            4: orders[3], // completed
            5: orders[4], // pending
          },
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final completedOrders = container.read(completedOrdersProvider);

        // Assert
        expect(completedOrders.length, 2);
        expect(completedOrders.map((order) => order.id), containsAll([3, 4]));
        expect(completedOrders.every((order) => order.status == OrderStatus.completed), isTrue);
      });

      test('should return completed VIP orders when only VIP orders are completed', () {
        // Arrange
        final orders = createTestOrders();
        final orderQueueState = OrderQueueState(
          orderIdCounter: 3,
          vipOrdersQueue: {
            3: orders[2], // completed VIP
          },
          normalOrdersQueue: {
            1: orders[0], // pending normal
            2: orders[1], // processing normal
          },
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final completedOrders = container.read(completedOrdersProvider);

        // Assert
        expect(completedOrders.length, 1);
        expect(completedOrders.first.id, 3);
        expect(completedOrders.first.type, OrderPriority.vip);
        expect(completedOrders.first.status, OrderStatus.completed);
      });

      test('should return completed normal orders when only normal orders are completed', () {
        // Arrange
        final orders = createTestOrders();
        final orderQueueState = OrderQueueState(
          orderIdCounter: 3,
          vipOrdersQueue: {
            1: orders[0], // pending VIP
          },
          normalOrdersQueue: {
            4: orders[3], // completed normal
            2: orders[1], // processing normal
          },
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final completedOrders = container.read(completedOrdersProvider);

        // Assert
        expect(completedOrders.length, 1);
        expect(completedOrders.first.id, 4);
        expect(completedOrders.first.type, OrderPriority.normal);
        expect(completedOrders.first.status, OrderStatus.completed);
      });
    });

    group('PendingOrders Provider', () {
      test('should return empty list when no pending/processing orders exist', () {
        // Arrange
        final orderQueueState = OrderQueueState(
          orderIdCounter: 1,
          vipOrdersQueue: {
            3: Order(id: 3, status: OrderStatus.completed, type: OrderPriority.vip),
          },
          normalOrdersQueue: {
            4: Order(id: 4, status: OrderStatus.completed, type: OrderPriority.normal),
          },
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final pendingOrders = container.read(pendingOrdersProvider);

        // Assert
        expect(pendingOrders, isEmpty);
      });

      test('should return both pending and processing orders from both queues', () {
        // Arrange
        final orders = createTestOrders();
        final orderQueueState = OrderQueueState(
          orderIdCounter: 5,
          vipOrdersQueue: {
            1: orders[0], // pending
            3: orders[2], // completed (should not be included)
          },
          normalOrdersQueue: {
            2: orders[1], // processing
            4: orders[3], // completed (should not be included)
            5: orders[4], // pending
          },
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final pendingOrders = container.read(pendingOrdersProvider);

        // Assert
        expect(pendingOrders.length, 3);
        expect(pendingOrders.map((order) => order.id), containsAll([1, 2, 5]));

        // Check that all returned orders are either pending or processing
        expect(
          pendingOrders.every((order) => order.status == OrderStatus.pending || order.status == OrderStatus.processing),
          isTrue,
        );

        // Verify we don't have any completed orders
        expect(pendingOrders.any((order) => order.status == OrderStatus.completed), isFalse);
      });

      test('should return only pending orders when no processing orders exist', () {
        // Arrange
        final orderQueueState = OrderQueueState(
          orderIdCounter: 3,
          vipOrdersQueue: {
            1: Order(id: 1, status: OrderStatus.pending, type: OrderPriority.vip),
          },
          normalOrdersQueue: {
            2: Order(id: 2, status: OrderStatus.pending, type: OrderPriority.normal),
            3: Order(id: 3, status: OrderStatus.completed, type: OrderPriority.normal),
          },
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final pendingOrders = container.read(pendingOrdersProvider);

        // Assert
        expect(pendingOrders.length, 2);
        expect(pendingOrders.map((order) => order.id), containsAll([1, 2]));
        expect(pendingOrders.every((order) => order.status == OrderStatus.pending), isTrue);
      });

      test('should handle mix of VIP and normal orders correctly', () {
        // Arrange
        final orderQueueState = OrderQueueState(
          orderIdCounter: 6,
          vipOrdersQueue: {
            1: Order(id: 1, status: OrderStatus.pending, type: OrderPriority.vip),
            2: Order(id: 2, status: OrderStatus.processing, type: OrderPriority.vip),
            3: Order(id: 3, status: OrderStatus.completed, type: OrderPriority.vip),
          },
          normalOrdersQueue: {
            4: Order(id: 4, status: OrderStatus.pending, type: OrderPriority.normal),
            5: Order(id: 5, status: OrderStatus.processing, type: OrderPriority.normal),
            6: Order(id: 6, status: OrderStatus.completed, type: OrderPriority.normal),
          },
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final pendingOrders = container.read(pendingOrdersProvider);

        // Assert
        expect(pendingOrders.length, 4);
        expect(pendingOrders.map((order) => order.id), containsAll([1, 2, 4, 5]));

        // Check VIP orders
        final vipOrders = pendingOrders.where((order) => order.type == OrderPriority.vip);
        expect(vipOrders.length, 2);
        expect(vipOrders.map((order) => order.id), containsAll([1, 2]));

        // Check normal orders
        final normalOrders = pendingOrders.where((order) => order.type == OrderPriority.normal);
        expect(normalOrders.length, 2);
        expect(normalOrders.map((order) => order.id), containsAll([4, 5]));
      });
    });

    group('Provider Integration', () {
      test('should work together correctly with the same order queue state', () {
        // Arrange
        final orders = createTestOrders();
        final orderQueueState = OrderQueueState(
          orderIdCounter: 5,
          vipOrdersQueue: {
            1: orders[0], // pending
            3: orders[2], // completed
          },
          normalOrdersQueue: {
            2: orders[1], // processing
            4: orders[3], // completed
            5: orders[4], // pending
          },
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final completedOrders = container.read(completedOrdersProvider);
        final pendingOrders = container.read(pendingOrdersProvider);

        // Assert
        expect(completedOrders.length, 2);
        expect(pendingOrders.length, 3);

        // Ensure no overlap between completed and pending
        final completedIds = completedOrders.map((order) => order.id).toSet();
        final pendingIds = pendingOrders.map((order) => order.id).toSet();
        expect(completedIds.intersection(pendingIds), isEmpty);

        // Ensure total count matches
        expect(completedIds.union(pendingIds).length, 5);
      });

      test('should handle edge case with empty order queues', () {
        // Arrange
        final orderQueueState = OrderQueueState(
          orderIdCounter: 0,
          vipOrdersQueue: {},
          normalOrdersQueue: {},
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final completedOrders = container.read(completedOrdersProvider);
        final pendingOrders = container.read(pendingOrdersProvider);

        // Assert
        expect(completedOrders, isEmpty);
        expect(pendingOrders, isEmpty);
      });

      test('should return consistent results when providers depend on same data', () {
        // Arrange
        final orderQueueState = OrderQueueState(
          orderIdCounter: 3,
          vipOrdersQueue: {
            1: Order(id: 1, status: OrderStatus.pending, type: OrderPriority.vip),
            2: Order(id: 2, status: OrderStatus.completed, type: OrderPriority.vip),
          },
          normalOrdersQueue: {
            3: Order(id: 3, status: OrderStatus.processing, type: OrderPriority.normal),
          },
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act - Read providers multiple times
        final completedOrders1 = container.read(completedOrdersProvider);
        final completedOrders2 = container.read(completedOrdersProvider);
        final pendingOrders1 = container.read(pendingOrdersProvider);
        final pendingOrders2 = container.read(pendingOrdersProvider);

        // Assert - Results should be consistent
        expect(completedOrders1, equals(completedOrders2));
        expect(pendingOrders1, equals(pendingOrders2));

        expect(completedOrders1.length, 1);
        expect(pendingOrders1.length, 2);

        expect(completedOrders1.first.id, 2);
        expect(pendingOrders1.map((order) => order.id), containsAll([1, 3]));
      });
    });

    group('Edge Cases', () {
      test('should handle orders with same ID in different queues', () {
        // This shouldn't happen in normal usage, but let's test it anyway
        final orderQueueState = OrderQueueState(
          orderIdCounter: 2,
          vipOrdersQueue: {
            1: Order(id: 1, status: OrderStatus.completed, type: OrderPriority.vip),
          },
          normalOrdersQueue: {
            1: Order(id: 1, status: OrderStatus.pending, type: OrderPriority.normal),
          },
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final completedOrders = container.read(completedOrdersProvider);
        final pendingOrders = container.read(pendingOrdersProvider);

        // Assert
        expect(completedOrders.length, 1);
        expect(pendingOrders.length, 1);
        expect(completedOrders.first.type, OrderPriority.vip);
        expect(pendingOrders.first.type, OrderPriority.normal);
      });

      test('should handle large number of orders', () {
        // Arrange
        final vipOrders = <int, Order>{};
        final normalOrders = <int, Order>{};

        for (int i = 0; i < 100; i++) {
          if (i % 3 == 0) {
            vipOrders[i] = Order(id: i, status: OrderStatus.completed, type: OrderPriority.vip);
          } else if (i % 3 == 1) {
            normalOrders[i] = Order(id: i, status: OrderStatus.pending, type: OrderPriority.normal);
          } else {
            normalOrders[i] = Order(id: i, status: OrderStatus.processing, type: OrderPriority.normal);
          }
        }

        final orderQueueState = OrderQueueState(
          orderIdCounter: 100,
          vipOrdersQueue: vipOrders,
          normalOrdersQueue: normalOrders,
        );
        container = createContainer(orderQueueState: orderQueueState);

        // Act
        final completedOrders = container.read(completedOrdersProvider);
        final pendingOrders = container.read(pendingOrdersProvider);

        // Assert
        expect(completedOrders.length, 34); // Every 3rd item (0, 3, 6, ... 99)
        expect(pendingOrders.length, 66); // Remaining items

        expect(completedOrders.every((order) => order.status == OrderStatus.completed), isTrue);
        expect(
          pendingOrders.every((order) => order.status == OrderStatus.pending || order.status == OrderStatus.processing),
          isTrue,
        );
      });
    });
  });
}
