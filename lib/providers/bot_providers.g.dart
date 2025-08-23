// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$botFactoryHash() => r'890e85edcfe400c78df164a3150c3ebd169a8956';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$BotFactory extends BuildlessAutoDisposeNotifier<Bot> {
  late final int id;

  Bot build({required int id});
}

/// See also [BotFactory].
@ProviderFor(BotFactory)
const botFactoryProvider = BotFactoryFamily();

/// See also [BotFactory].
class BotFactoryFamily extends Family<Bot> {
  /// See also [BotFactory].
  const BotFactoryFamily();

  /// See also [BotFactory].
  BotFactoryProvider call({required int id}) {
    return BotFactoryProvider(id: id);
  }

  @override
  BotFactoryProvider getProviderOverride(
    covariant BotFactoryProvider provider,
  ) {
    return call(id: provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'botFactoryProvider';
}

/// See also [BotFactory].
class BotFactoryProvider
    extends AutoDisposeNotifierProviderImpl<BotFactory, Bot> {
  /// See also [BotFactory].
  BotFactoryProvider({required int id})
    : this._internal(
        () => BotFactory()..id = id,
        from: botFactoryProvider,
        name: r'botFactoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$botFactoryHash,
        dependencies: BotFactoryFamily._dependencies,
        allTransitiveDependencies: BotFactoryFamily._allTransitiveDependencies,
        id: id,
      );

  BotFactoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Bot runNotifierBuild(covariant BotFactory notifier) {
    return notifier.build(id: id);
  }

  @override
  Override overrideWith(BotFactory Function() create) {
    return ProviderOverride(
      origin: this,
      override: BotFactoryProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<BotFactory, Bot> createElement() {
    return _BotFactoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BotFactoryProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BotFactoryRef on AutoDisposeNotifierProviderRef<Bot> {
  /// The parameter `id` of this provider.
  int get id;
}

class _BotFactoryProviderElement
    extends AutoDisposeNotifierProviderElement<BotFactory, Bot>
    with BotFactoryRef {
  _BotFactoryProviderElement(super.provider);

  @override
  int get id => (origin as BotFactoryProvider).id;
}

String _$botsOrchestratorHash() => r'abf281885c05b9ee97b113b87484efe3af9fc5fb';

/// See also [BotsOrchestrator].
@ProviderFor(BotsOrchestrator)
final botsOrchestratorProvider =
    AutoDisposeNotifierProvider<
      BotsOrchestrator,
      BotsOrchestratorState
    >.internal(
      BotsOrchestrator.new,
      name: r'botsOrchestratorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$botsOrchestratorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BotsOrchestrator = AutoDisposeNotifier<BotsOrchestratorState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
