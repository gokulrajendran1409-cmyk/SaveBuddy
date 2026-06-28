class AmountPart {
  final int denominator;
  final int count;

  const AmountPart({required this.denominator, required this.count});
}

class ParsedAmount {
  final double total;
  final List<AmountPart> parts;
  final String summary;

  const ParsedAmount({required this.total, required this.parts, required this.summary});
}

class AmountParser {
  static const List<int> supportedDenominations = [1, 2, 5, 10, 20, 50, 100, 200, 500];

  static ParsedAmount parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const ParsedAmount(total: 0, parts: [], summary: '');
    }

    final normalized = trimmed.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final normalizedForParsing = normalized.replaceAll('×', '*');
    final terms = normalizedForParsing.split('+').where((term) => term.isNotEmpty).toList();

    final parts = <AmountPart>[];
    var total = 0.0;

    for (final term in terms) {
      final match = RegExp(r'^(\d+)(?:\*(\d+))?$').firstMatch(term);
      if (match == null) {
        continue;
      }

      final value = int.parse(match.group(1)!);
      final count = match.group(2) != null ? int.parse(match.group(2)!) : 1;

      if (!supportedDenominations.contains(value)) {
        continue;
      }

      final amount = value * count;
      total += amount.toDouble();
      parts.add(AmountPart(denominator: value, count: count));
    }

    final summary = parts.isEmpty
        ? ''
        : parts.map((part) => '${part.denominator} × ${part.count}').join(', ');

    return ParsedAmount(total: total, parts: parts, summary: summary);
  }
}
