class BotsOrchestratorState {
  final int botIdCounter;
  final Map<int, bool> botIds;

  BotsOrchestratorState({
    required this.botIdCounter,
    required this.botIds,
  });

  BotsOrchestratorState copyWith({
    int? botIdCounter,
    Map<int, bool>? botIds,
  }) {
    return BotsOrchestratorState(
      botIdCounter: botIdCounter ?? this.botIdCounter,
      botIds: botIds ?? this.botIds,
    );
  }
}
