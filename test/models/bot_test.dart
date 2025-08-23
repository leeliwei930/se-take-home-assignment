import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_order_simulator/models/bot.dart';

void main() {
  group('Bot', () {
    test('should create a Bot with correct properties', () {
      // Arrange
      final id = 1;
      final orderTimerQueue = <int, Timer>{};

      // Act
      final bot = Bot(
        id: id,
        orderTimerQueue: orderTimerQueue,
      );

      // Assert
      expect(bot.id, id);
      expect(bot.orderTimerQueue, orderTimerQueue);
    });

    test('status should be idle when orderTimerQueue is empty', () {
      // Arrange
      final bot = Bot(
        id: 1,
        orderTimerQueue: {},
      );

      // Act & Assert
      expect(bot.status, BotStatus.idle);
    });

    test('status should be cooking when orderTimerQueue has orders', () {
      // Arrange
      final mockTimer = Timer(Duration.zero, () {});
      final bot = Bot(
        id: 1,
        orderTimerQueue: {123: mockTimer},
      );

      // Act & Assert
      expect(bot.status, BotStatus.cooking);

      // Cleanup
      mockTimer.cancel();
    });

    test('copyWith should return a new Bot with updated properties', () {
      // Arrange
      final originalBot = Bot(id: 1, orderTimerQueue: {});
      final newOrderTimerQueue = <int, Timer>{123: Timer(Duration.zero, () {})};

      // Act
      final updatedBot = originalBot.copyWith(
        id: 2,
        orderTimerQueue: newOrderTimerQueue,
      );

      // Assert
      expect(updatedBot.id, 2);
      expect(updatedBot.orderTimerQueue, newOrderTimerQueue);
      expect(updatedBot, isNot(equals(originalBot)));

      // Cleanup
      for (final timer in newOrderTimerQueue.values) {
        timer.cancel();
      }
    });

    test('copyWith should keep original values when parameters are null', () {
      // Arrange
      final originalBot = Bot(id: 1, orderTimerQueue: {});

      // Act
      final updatedBot = originalBot.copyWith();

      // Assert
      expect(updatedBot.id, 1);
      expect(updatedBot.orderTimerQueue, {});
      expect(updatedBot, equals(originalBot));
    });

    test('props should contain id and orderTimerQueue', () {
      // Arrange
      final id = 1;
      final orderTimerQueue = <int, Timer>{};
      final bot = Bot(id: id, orderTimerQueue: orderTimerQueue);

      // Act & Assert
      expect(bot.props, [id, orderTimerQueue]);
    });

    test('bots with same properties should be equal', () {
      // Arrange
      final bot1 = Bot(id: 1, orderTimerQueue: {});
      final bot2 = Bot(id: 1, orderTimerQueue: {});

      // Act & Assert
      expect(bot1, equals(bot2));
    });

    test('bots with different properties should not be equal', () {
      // Arrange
      final bot1 = Bot(id: 1, orderTimerQueue: {});
      final bot2 = Bot(id: 2, orderTimerQueue: {});
      final mockTimer = Timer(Duration.zero, () {});
      final bot3 = Bot(id: 1, orderTimerQueue: {123: mockTimer});

      // Act & Assert
      expect(bot1, isNot(equals(bot2)));
      expect(bot1, isNot(equals(bot3)));

      // Cleanup
      mockTimer.cancel();
    });
  });
}
