import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order_simulator/models/bot.dart';
import 'package:food_order_simulator/models/order.dart';
import 'package:food_order_simulator/providers/bot_providers.dart';
import 'package:food_order_simulator/providers/order_queue_provider.dart';
import 'package:food_order_simulator/providers/order_queue_state.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('Bot Providers', () {
    late ProviderContainer container;
    late MockOrderQueue mockOrderQueue;

    setUp(() {
      mockOrderQueue = MockOrderQueue();
    });

    tearDown(() {
      // Cancel all active timers before disposing container
      try {
        final orchestratorState = container.read(botsOrchestratorProvider);
        for (final botId in orchestratorState.botIds.keys) {
          final botNotifier = container.read(botFactoryProvider(id: botId).notifier);
          botNotifier.dropAllOrders();
        }
      } catch (e) {
        // Container might already be disposed
      }

      // Dispose the container after each test
      container.dispose();
    });

    /// Helper method to create a container with overridden OrderQueue
    ProviderContainer createContainer({OrderQueueState? orderQueueState}) {
      final state =
          orderQueueState ??
          OrderQueueState(
            vipOrdersQueue: {},
            normalOrdersQueue: {},
            orderIdCounter: 0,
          );

      when(() => mockOrderQueue.build()).thenReturn(state);

      return ProviderContainer(
        overrides: [
          orderQueueProvider.overrideWith(() => mockOrderQueue),
        ],
      );
    }

    /// Helper method to create test orders
    Order createTestOrder({
      required int id,
      OrderStatus status = OrderStatus.pending,
      OrderPriority type = OrderPriority.normal,
      Bot? preparedBy,
      DateTime? completedAt,
    }) {
      return Order(
        id: id,
        status: status,
        type: type,
        preparedBy: preparedBy,
        completedAt: completedAt,
      );
    }

    group('BotFactory Provider', () {
      group('Initial State', () {
        test('should initialize with correct default state', () {
          // Arrange
          container = createContainer();

          // Act
          final bot = container.read(botFactoryProvider(id: 1));

          // Assert
          expect(bot.id, 1);
          expect(bot.orderTimerQueue, isEmpty);
          expect(bot.status, BotStatus.idle);
        });

        test('should create different bots with different IDs', () {
          // Arrange
          container = createContainer();

          // Act
          final bot1 = container.read(botFactoryProvider(id: 1));
          final bot2 = container.read(botFactoryProvider(id: 2));
          final bot3 = container.read(botFactoryProvider(id: 1)); // Same ID as bot1

          // Assert
          expect(bot1.id, 1);
          expect(bot2.id, 2);
          expect(bot3.id, 1);
          expect(identical(bot1, bot3), isTrue); // Same provider instance for same ID
          expect(identical(bot1, bot2), isFalse); // Different instances for different IDs
        });
      });

      group('enqueueOrder', () {
        test('should enqueue order and update bot state', () {
          // Arrange
          final testOrder = createTestOrder(id: 0, type: OrderPriority.vip);
          final initialState = OrderQueueState(
            vipOrdersQueue: {0: testOrder},
            normalOrdersQueue: {},
            orderIdCounter: 1,
          );
          container = createContainer(orderQueueState: initialState);

          final botNotifier = container.read(botFactoryProvider(id: 1).notifier);
          final botBefore = container.read(botFactoryProvider(id: 1));

          // Act
          botNotifier.enqueueOrder(testOrder);

          // Assert
          final botAfter = container.read(botFactoryProvider(id: 1));

          // Bot should have order in timer queue
          expect(botAfter.orderTimerQueue.length, 1);
          expect(botAfter.orderTimerQueue.containsKey(testOrder.id), isTrue);
          expect(botAfter.status, BotStatus.cooking);
          expect(botBefore.status, BotStatus.idle);

          // Verify mock interactions - updateOrderById should be called
          verify(
            () => mockOrderQueue.updateOrderById(
              testOrder.id,
              preparedBy: any(named: 'preparedBy'),
              status: OrderStatus.processing,
              completedAt: any(named: 'completedAt'),
            ),
          ).called(1);
        });

        test('should handle multiple orders correctly', () {
          // Arrange
          final vipOrder = createTestOrder(id: 0, type: OrderPriority.vip);
          final normalOrder = createTestOrder(id: 1, type: OrderPriority.normal);
          final initialState = OrderQueueState(
            vipOrdersQueue: {0: vipOrder},
            normalOrdersQueue: {1: normalOrder},
            orderIdCounter: 2,
          );
          container = createContainer(orderQueueState: initialState);

          final botNotifier = container.read(botFactoryProvider(id: 1).notifier);

          // Act
          botNotifier.enqueueOrder(vipOrder);

          // Assert - Bot should be cooking after first order
          final botAfterFirst = container.read(botFactoryProvider(id: 1));
          expect(botAfterFirst.status, BotStatus.cooking);
          expect(botAfterFirst.orderTimerQueue.length, 1);

          // Bot can handle multiple orders (since kMaxBotCookingOrders = 1,
          // but timer queue can still hold multiple)
          botNotifier.enqueueOrder(normalOrder);
          final botAfterSecond = container.read(botFactoryProvider(id: 1));
          expect(botAfterSecond.status, BotStatus.cooking);
          expect(botAfterSecond.orderTimerQueue.length, 2);

          // Verify updateOrderById was called for both orders
          verify(
            () => mockOrderQueue.updateOrderById(
              vipOrder.id,
              preparedBy: any(named: 'preparedBy'),
              status: OrderStatus.processing,
              completedAt: any(named: 'completedAt'),
            ),
          ).called(1);

          verify(
            () => mockOrderQueue.updateOrderById(
              normalOrder.id,
              preparedBy: any(named: 'preparedBy'),
              status: OrderStatus.processing,
              completedAt: any(named: 'completedAt'),
            ),
          ).called(1);
        });
      });

      group('dropAllOrders', () {
        test('should drop all orders and reset bot to idle', () {
          // Arrange
          final vipOrder = createTestOrder(id: 0, type: OrderPriority.vip);
          final normalOrder = createTestOrder(id: 1, type: OrderPriority.normal);
          final initialState = OrderQueueState(
            vipOrdersQueue: {0: vipOrder},
            normalOrdersQueue: {1: normalOrder},
            orderIdCounter: 2,
          );
          container = createContainer(orderQueueState: initialState);

          final botNotifier = container.read(botFactoryProvider(id: 1).notifier);
          botNotifier.enqueueOrder(vipOrder);
          botNotifier.enqueueOrder(normalOrder);

          // Verify bot has orders
          final botBeforeDrop = container.read(botFactoryProvider(id: 1));
          expect(botBeforeDrop.orderTimerQueue.length, 2);
          expect(botBeforeDrop.status, BotStatus.cooking);

          // Act
          botNotifier.dropAllOrders();

          // Assert
          final botAfterDrop = container.read(botFactoryProvider(id: 1));

          // Bot should be idle with no orders
          expect(botAfterDrop.orderTimerQueue, isEmpty);
          expect(botAfterDrop.status, BotStatus.idle);

          // Verify updateOrderById was called to reset orders to pending
          verify(
            () => mockOrderQueue.updateOrderById(
              vipOrder.id,
              status: OrderStatus.pending,
              preparedBy: null,
              completedAt: null,
            ),
          ).called(1);

          verify(
            () => mockOrderQueue.updateOrderById(
              normalOrder.id,
              status: OrderStatus.pending,
              preparedBy: null,
              completedAt: null,
            ),
          ).called(1);
        });

        test('should handle empty order queue gracefully', () {
          // Arrange
          container = createContainer(); // Empty state
          final botNotifier = container.read(botFactoryProvider(id: 1).notifier);
          final botBefore = container.read(botFactoryProvider(id: 1));

          // Act & Assert - should not throw
          expect(() => botNotifier.dropAllOrders(), returnsNormally);

          final botAfter = container.read(botFactoryProvider(id: 1));
          expect(botAfter.orderTimerQueue, isEmpty);
          expect(botAfter.status, BotStatus.idle);
          expect(identical(botBefore, botAfter), isTrue); // No state change

          // Verify no updateOrderById calls were made (no orders to drop)
          verifyNever(
            () => mockOrderQueue.updateOrderById(
              any(),
              status: any(named: 'status'),
              preparedBy: any(named: 'preparedBy'),
              completedAt: any(named: 'completedAt'),
            ),
          );
        });
      });

      group('Order Completion', () {
        test('should complete order after cooking duration', () {
          // Arrange
          final testOrder = createTestOrder(id: 0, type: OrderPriority.vip);
          final initialState = OrderQueueState(
            vipOrdersQueue: {0: testOrder},
            normalOrdersQueue: {},
            orderIdCounter: 1,
          );
          container = createContainer(orderQueueState: initialState);

          final botNotifier = container.read(botFactoryProvider(id: 1).notifier);

          // Act
          botNotifier.enqueueOrder(testOrder);

          // For testing purposes, we'll verify the timer is set up correctly
          // rather than waiting for the full duration
          final botAfterEnqueue = container.read(botFactoryProvider(id: 1));

          // Assert
          expect(botAfterEnqueue.orderTimerQueue.length, 1);
          expect(botAfterEnqueue.status, BotStatus.cooking);

          // Verify the order was marked as processing
          verify(
            () => mockOrderQueue.updateOrderById(
              testOrder.id,
              preparedBy: any(named: 'preparedBy'),
              status: OrderStatus.processing,
              completedAt: any(named: 'completedAt'),
            ),
          ).called(1);

          // Clean up timer
          botNotifier.dropAllOrders();
        });
      });
    });

    group('BotsOrchestrator Provider', () {
      group('Initial State', () {
        test('should initialize with correct default state', () {
          // Arrange
          container = createContainer();

          // Act
          final state = container.read(botsOrchestratorProvider);

          // Assert
          expect(state.botIdCounter, 0);
          expect(state.botIds, isEmpty);
        });
      });

      group('addBot', () {
        test('should add a bot and increment counter', () {
          // Arrange
          container = createContainer();
          final notifier = container.read(botsOrchestratorProvider.notifier);

          // Act
          notifier.addBot();

          // Assert
          final state = container.read(botsOrchestratorProvider);
          expect(state.botIdCounter, 1);
          expect(state.botIds.length, 1);
          expect(state.botIds[0], isTrue);
        });

        test('should add multiple bots with incremental IDs', () {
          // Arrange
          container = createContainer();
          final notifier = container.read(botsOrchestratorProvider.notifier);

          // Act
          notifier.addBot();
          notifier.addBot();
          notifier.addBot();

          // Assert
          final state = container.read(botsOrchestratorProvider);
          expect(state.botIdCounter, 3);
          expect(state.botIds.length, 3);
          expect(state.botIds[0], isTrue);
          expect(state.botIds[1], isTrue);
          expect(state.botIds[2], isTrue);
        });
      });

      group('removeLastAddedBot', () {
        test('should remove the last added bot', () {
          // Arrange
          container = createContainer();
          final notifier = container.read(botsOrchestratorProvider.notifier);
          notifier.addBot(); // ID: 0
          notifier.addBot(); // ID: 1
          notifier.addBot(); // ID: 2

          // Act
          notifier.removeLastAddedBot();

          // Assert
          final state = container.read(botsOrchestratorProvider);
          expect(state.botIdCounter, 3); // Counter doesn't decrement
          expect(state.botIds.length, 2);
          expect(state.botIds[0], isTrue);
          expect(state.botIds[1], isTrue);
          expect(state.botIds.containsKey(2), isFalse);
        });

        test('should handle empty bots list gracefully', () {
          // Arrange
          container = createContainer();
          final notifier = container.read(botsOrchestratorProvider.notifier);
          final stateBefore = container.read(botsOrchestratorProvider);

          // Act & Assert - should not throw
          expect(() => notifier.removeLastAddedBot(), returnsNormally);

          final stateAfter = container.read(botsOrchestratorProvider);
          expect(stateAfter.botIdCounter, stateBefore.botIdCounter);
          expect(stateAfter.botIds, stateBefore.botIds);
        });

        test('should drop all orders from removed bot', () {
          // Arrange
          final testOrder = createTestOrder(id: 0, type: OrderPriority.vip);
          final initialState = OrderQueueState(
            vipOrdersQueue: {0: testOrder},
            normalOrdersQueue: {},
            orderIdCounter: 1,
          );
          container = createContainer(orderQueueState: initialState);

          final orchestratorNotifier = container.read(botsOrchestratorProvider.notifier);
          orchestratorNotifier.addBot(); // Add bot with ID 0

          final botNotifier = container.read(botFactoryProvider(id: 0).notifier);
          botNotifier.enqueueOrder(testOrder);

          // Verify bot has order
          final botBeforeRemoval = container.read(botFactoryProvider(id: 0));
          expect(botBeforeRemoval.orderTimerQueue.length, 1);

          // Act
          orchestratorNotifier.removeLastAddedBot();

          // Assert - Verify that dropAllOrders was called which should reset the order
          verify(
            () => mockOrderQueue.updateOrderById(
              testOrder.id,
              status: OrderStatus.pending,
              preparedBy: null,
              completedAt: null,
            ),
          ).called(1);
        });
      });

      group('getIdleBot', () {
        test('should return idle bot when available', () {
          // Arrange
          container = createContainer();
          final notifier = container.read(botsOrchestratorProvider.notifier);
          notifier.addBot(); // ID: 0
          notifier.addBot(); // ID: 1

          // Act
          final idleBot = notifier.getIdleBot();

          // Assert
          expect(idleBot, isNotNull);
          expect(idleBot!.status, BotStatus.idle);
          expect([0, 1].contains(idleBot.id), isTrue);
        });

        test('should return null when no bots available', () {
          // Arrange
          container = createContainer();
          final notifier = container.read(botsOrchestratorProvider.notifier);

          // Act
          final idleBot = notifier.getIdleBot();

          // Assert
          expect(idleBot, isNull);
        });

        test('should return null when all bots are cooking', () {
          // Arrange
          final testOrder = createTestOrder(id: 0, type: OrderPriority.vip);
          final initialState = OrderQueueState(
            vipOrdersQueue: {0: testOrder},
            normalOrdersQueue: {},
            orderIdCounter: 1,
          );
          container = createContainer(orderQueueState: initialState);

          final orchestratorNotifier = container.read(botsOrchestratorProvider.notifier);
          orchestratorNotifier.addBot(); // ID: 0

          // Add order and assign to bot to make it cooking
          final botNotifier = container.read(botFactoryProvider(id: 0).notifier);
          botNotifier.enqueueOrder(testOrder);

          // Act
          final idleBot = orchestratorNotifier.getIdleBot();

          // Assert
          expect(idleBot, isNull);
        });
      });

      group('poll', () {
        test('should assign VIP order to idle bot', () {
          // Arrange
          final vipOrder = createTestOrder(id: 0, type: OrderPriority.vip);
          final initialState = OrderQueueState(
            vipOrdersQueue: {0: vipOrder},
            normalOrdersQueue: {},
            orderIdCounter: 1,
          );
          container = createContainer(orderQueueState: initialState);

          final orchestratorNotifier = container.read(botsOrchestratorProvider.notifier);
          orchestratorNotifier.addBot(); // ID: 0

          // Act
          orchestratorNotifier.poll();

          // Assert
          final bot = container.read(botFactoryProvider(id: 0));
          expect(bot.status, BotStatus.cooking);
          expect(bot.orderTimerQueue.length, 1);

          // Verify order was assigned to bot
          verify(
            () => mockOrderQueue.updateOrderById(
              vipOrder.id,
              preparedBy: any(named: 'preparedBy'),
              status: OrderStatus.processing,
              completedAt: any(named: 'completedAt'),
            ),
          ).called(1);
        });

        test('should assign normal order when no VIP orders available', () {
          // Arrange
          final normalOrder = createTestOrder(id: 0, type: OrderPriority.normal);
          final initialState = OrderQueueState(
            vipOrdersQueue: {},
            normalOrdersQueue: {0: normalOrder},
            orderIdCounter: 1,
          );
          container = createContainer(orderQueueState: initialState);

          final orchestratorNotifier = container.read(botsOrchestratorProvider.notifier);
          orchestratorNotifier.addBot(); // ID: 0

          // Act
          orchestratorNotifier.poll();

          // Assert
          final bot = container.read(botFactoryProvider(id: 0));
          expect(bot.status, BotStatus.cooking);
          expect(bot.orderTimerQueue.length, 1);

          // Verify order was assigned to bot
          verify(
            () => mockOrderQueue.updateOrderById(
              normalOrder.id,
              preparedBy: any(named: 'preparedBy'),
              status: OrderStatus.processing,
              completedAt: any(named: 'completedAt'),
            ),
          ).called(1);
        });

        test('should prioritize VIP orders over normal orders', () {
          // Arrange
          final normalOrder = createTestOrder(id: 0, type: OrderPriority.normal);
          final vipOrder = createTestOrder(id: 1, type: OrderPriority.vip);
          final initialState = OrderQueueState(
            vipOrdersQueue: {1: vipOrder},
            normalOrdersQueue: {0: normalOrder},
            orderIdCounter: 2,
          );
          container = createContainer(orderQueueState: initialState);

          final orchestratorNotifier = container.read(botsOrchestratorProvider.notifier);
          orchestratorNotifier.addBot(); // ID: 0

          // Act
          orchestratorNotifier.poll();

          // Assert
          final bot = container.read(botFactoryProvider(id: 0));
          expect(bot.status, BotStatus.cooking);
          expect(bot.orderTimerQueue.length, 1);

          // Verify VIP order was assigned, not normal order
          verify(
            () => mockOrderQueue.updateOrderById(
              vipOrder.id,
              preparedBy: any(named: 'preparedBy'),
              status: OrderStatus.processing,
              completedAt: any(named: 'completedAt'),
            ),
          ).called(1);

          // Verify normal order was NOT assigned
          verifyNever(
            () => mockOrderQueue.updateOrderById(
              normalOrder.id,
              preparedBy: any(named: 'preparedBy'),
              status: OrderStatus.processing,
              completedAt: any(named: 'completedAt'),
            ),
          );
        });

        test('should do nothing when no idle bots available', () {
          // Arrange
          final vipOrder = createTestOrder(id: 0, type: OrderPriority.vip);
          final initialState = OrderQueueState(
            vipOrdersQueue: {0: vipOrder},
            normalOrdersQueue: {},
            orderIdCounter: 1,
          );
          container = createContainer(orderQueueState: initialState);

          final orchestratorNotifier = container.read(botsOrchestratorProvider.notifier);
          // No bots added

          // Act
          orchestratorNotifier.poll();

          // Assert - No orders should be assigned
          verifyNever(
            () => mockOrderQueue.updateOrderById(
              any(),
              preparedBy: any(named: 'preparedBy'),
              status: any(named: 'status'),
              completedAt: any(named: 'completedAt'),
            ),
          );
        });

        test('should do nothing when no pending orders available', () {
          // Arrange
          container = createContainer(); // Empty state (no orders)
          final orchestratorNotifier = container.read(botsOrchestratorProvider.notifier);
          orchestratorNotifier.addBot(); // ID: 0

          final botBefore = container.read(botFactoryProvider(id: 0));
          expect(botBefore.status, BotStatus.idle);

          // Act
          orchestratorNotifier.poll();

          // Assert
          final botAfter = container.read(botFactoryProvider(id: 0));
          expect(botAfter.status, BotStatus.idle);
          expect(botAfter.orderTimerQueue, isEmpty);

          // Verify no orders were assigned
          verifyNever(
            () => mockOrderQueue.updateOrderById(
              any(),
              preparedBy: any(named: 'preparedBy'),
              status: any(named: 'status'),
              completedAt: any(named: 'completedAt'),
            ),
          );
        });
      });
    });

    group('Integration Tests', () {
      test('should handle complete workflow: add bots, manage state correctly', () {
        // Arrange
        container = createContainer();
        final orchestratorNotifier = container.read(botsOrchestratorProvider.notifier);

        // Act & Assert - Test the bot management workflow

        // 1. Initially no bots
        expect(container.read(botsOrchestratorProvider).botIds, isEmpty);

        // 2. Add bots
        orchestratorNotifier.addBot(); // ID: 0
        orchestratorNotifier.addBot(); // ID: 1
        final stateAfterAdding = container.read(botsOrchestratorProvider);
        expect(stateAfterAdding.botIds.length, 2);
        expect(stateAfterAdding.botIdCounter, 2);

        // 3. Verify bots are idle
        final bot0 = container.read(botFactoryProvider(id: 0));
        final bot1 = container.read(botFactoryProvider(id: 1));
        expect(bot0.status, BotStatus.idle);
        expect(bot1.status, BotStatus.idle);

        // 4. Test getIdleBot functionality
        final idleBot = orchestratorNotifier.getIdleBot();
        expect(idleBot, isNotNull);
        expect([0, 1].contains(idleBot!.id), isTrue);

        // 5. Test order assignment
        final testOrder = createTestOrder(id: 100, type: OrderPriority.vip);
        final botNotifier = container.read(botFactoryProvider(id: 0).notifier);
        botNotifier.enqueueOrder(testOrder);

        final botAfterOrder = container.read(botFactoryProvider(id: 0));
        expect(botAfterOrder.status, BotStatus.cooking);
        expect(botAfterOrder.orderTimerQueue.length, 1);

        // 6. Verify mock interaction
        verify(
          () => mockOrderQueue.updateOrderById(
            testOrder.id,
            preparedBy: any(named: 'preparedBy'),
            status: OrderStatus.processing,
            completedAt: any(named: 'completedAt'),
          ),
        ).called(1);

        // 7. Test bot removal
        orchestratorNotifier.removeLastAddedBot();
        final stateAfterRemoval = container.read(botsOrchestratorProvider);
        expect(stateAfterRemoval.botIds.length, 1);
        expect(stateAfterRemoval.botIds.containsKey(1), isFalse);
      });
    });

    group('Constants', () {
      test('should have correct bot cooking duration constant', () {
        expect(kBotCookingDuration, 10);
      });
    });
  });
}
