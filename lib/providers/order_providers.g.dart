// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$completedOrdersHash() => r'37868ec9275989661223a2e5e53631f4d3ce6fc1';

/// See also [CompletedOrders].
@ProviderFor(CompletedOrders)
final completedOrdersProvider =
    AutoDisposeNotifierProvider<CompletedOrders, List<Order>>.internal(
      CompletedOrders.new,
      name: r'completedOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$completedOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CompletedOrders = AutoDisposeNotifier<List<Order>>;
String _$pendingOrdersHash() => r'9993ec01d0c610b4e87b8b6c027bd5684921df10';

/// See also [PendingOrders].
@ProviderFor(PendingOrders)
final pendingOrdersProvider =
    AutoDisposeNotifierProvider<PendingOrders, List<Order>>.internal(
      PendingOrders.new,
      name: r'pendingOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PendingOrders = AutoDisposeNotifier<List<Order>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
