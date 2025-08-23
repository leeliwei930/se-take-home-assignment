// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$completedOrdersHash() => r'7a96e89ac3a966d624bde2ffd7fe03e3e5c31c37';

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
String _$pendingOrdersHash() => r'735447a948fad7c008b0f198ffdbfee8372e2130';

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
