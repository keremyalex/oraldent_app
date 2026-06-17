class PeriodontogramaAiTranscription {
  const PeriodontogramaAiTranscription({
    required this.text,
    required this.periodontogram,
  });

  factory PeriodontogramaAiTranscription.fromJson(Map<String, dynamic> json) {
    return PeriodontogramaAiTranscription(
      text: json['text'] as String? ?? '',
      periodontogram: PeriodontogramaAiResult.fromJson(
        json['periodontogram'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final String text;
  final PeriodontogramaAiResult periodontogram;
}

class PeriodontogramaAiParseResponse {
  const PeriodontogramaAiParseResponse({required this.periodontogram});

  factory PeriodontogramaAiParseResponse.fromJson(Map<String, dynamic> json) {
    return PeriodontogramaAiParseResponse(
      periodontogram: PeriodontogramaAiResult.fromJson(
        json['periodontogram'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final PeriodontogramaAiResult periodontogram;
}

class PeriodontogramaAiResult {
  const PeriodontogramaAiResult({
    required this.raw,
    required this.items,
    required this.byTooth,
    required this.unparsedSegments,
    this.currentTooth,
  });

  factory PeriodontogramaAiResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PeriodontogramaAiItem.fromJson)
        .toList();
    final byToothJson = json['by_tooth'] as Map<String, dynamic>? ?? const {};
    final byTooth = <int, List<PeriodontogramaAiItem>>{};

    for (final entry in byToothJson.entries) {
      final tooth = int.tryParse(entry.key);
      final values = entry.value;
      if (tooth == null || values is! List) {
        continue;
      }
      byTooth[tooth] = values
          .whereType<Map<String, dynamic>>()
          .map(PeriodontogramaAiItem.fromJson)
          .toList();
    }

    return PeriodontogramaAiResult(
      raw: json['raw'] as String? ?? '',
      currentTooth: json['current_tooth'] as int?,
      items: items,
      byTooth: byTooth,
      unparsedSegments:
          (json['unparsed_segments'] as List<dynamic>? ?? const [])
              .map((value) => value.toString())
              .toList(),
    );
  }

  final String raw;
  final int? currentTooth;
  final List<PeriodontogramaAiItem> items;
  final Map<int, List<PeriodontogramaAiItem>> byTooth;
  final List<String> unparsedSegments;

  bool get hasData => byTooth.isNotEmpty;
}

class PeriodontogramaAiItem {
  const PeriodontogramaAiItem({
    required this.action,
    this.tooth,
    this.surface,
    this.values = const [],
    this.positive,
    this.grade,
    this.mm,
  });

  factory PeriodontogramaAiItem.fromJson(Map<String, dynamic> json) {
    return PeriodontogramaAiItem(
      action: json['action'] as String? ?? '',
      tooth: json['tooth'] as int?,
      surface: json['surface'] as String?,
      values: (json['values'] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((value) => value.toInt())
          .toList(),
      positive: json['positive'] as bool?,
      grade: (json['grade'] as num?)?.toInt(),
      mm: (json['mm'] as num?)?.toInt(),
    );
  }

  final String action;
  final int? tooth;
  final String? surface;
  final List<int> values;
  final bool? positive;
  final int? grade;
  final int? mm;
}
