String _id() => DateTime.now().microsecondsSinceEpoch.toString();

/// نوع العملية: مصروف أو دخل
enum TxType { expense, income }

class WalletTx {
  WalletTx({
    String? id,
    required this.type,
    required this.amount,
    required this.category,
    this.note = '',
    DateTime? date,
  }) : id = id ?? _id(),
       date = date ?? DateTime.now();

  final String id;
  final TxType type;
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
  };

  factory WalletTx.fromJson(Map<String, dynamic> j) => WalletTx(
    id: j['id'] as String,
    type: TxType.values.byName(j['type'] as String),
    amount: (j['amount'] as num).toDouble(),
    category: j['category'] as String,
    note: (j['note'] as String?) ?? '',
    date: DateTime.parse(j['date'] as String),
  );
}

/// اتجاه السلف: لي (حد مدينلي) أو عليا (أنا مدين)
enum DebtDirection { owedToMe, iOwe }

class Debt {
  Debt({
    String? id,
    required this.person,
    required this.amount,
    required this.direction,
    this.note = '',
    DateTime? date,
    this.settled = false,
    this.settledAt,
  }) : id = id ?? _id(),
       date = date ?? DateTime.now();

  final String id;
  final String person;
  final double amount;
  final DebtDirection direction;
  final String note;
  final DateTime date;
  bool settled;
  DateTime? settledAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'person': person,
    'amount': amount,
    'direction': direction.name,
    'note': note,
    'date': date.toIso8601String(),
    'settled': settled,
    'settledAt': settledAt?.toIso8601String(),
  };

  factory Debt.fromJson(Map<String, dynamic> j) => Debt(
    id: j['id'] as String,
    person: j['person'] as String,
    amount: (j['amount'] as num).toDouble(),
    direction: DebtDirection.values.byName(j['direction'] as String),
    note: (j['note'] as String?) ?? '',
    date: DateTime.parse(j['date'] as String),
    settled: (j['settled'] as bool?) ?? false,
    settledAt: j['settledAt'] != null
        ? DateTime.parse(j['settledAt'] as String)
        : null,
  );
}

/// جمعية: قسط شهري × عدد شهور، ودور القبض بتاعك
class Jam3eya {
  Jam3eya({
    String? id,
    required this.name,
    required this.monthlyAmount,
    required this.monthsCount,
    required this.startYear,
    required this.startMonth,
    required this.receiveMonthIndex,
    List<bool>? paidMonths,
    this.received = false,
  }) : id = id ?? _id(),
       paidMonths = paidMonths ?? List<bool>.filled(monthsCount, false);

  final String id;
  final String name;
  final double monthlyAmount;
  final int monthsCount;
  final int startYear;
  final int startMonth;

  /// رقم الشهر اللي هتقبض فيه (1-based)
  final int receiveMonthIndex;
  final List<bool> paidMonths;
  bool received;

  /// إجمالي اللي هتقبضه لما ييجي دورك
  double get totalPot => monthlyAmount * monthsCount;

  int get paidCount => paidMonths.where((p) => p).length;

  double get paidSoFar => paidCount * monthlyAmount;

  double get remaining => totalPot - paidSoFar;

  bool get isComplete => paidCount >= monthsCount;

  /// تاريخ شهر معين (1-based) من بداية الجمعية
  DateTime monthDate(int index1Based) =>
      DateTime(startYear, startMonth + index1Based - 1);

  DateTime get receiveDate => monthDate(receiveMonthIndex);

  /// الشهر الحالي جوه الجمعية (1-based)، أو null لو لسه مبدأتش
  int? get currentMonthIndex {
    final now = DateTime.now();
    final idx = (now.year - startYear) * 12 + (now.month - startMonth) + 1;
    if (idx < 1) return null;
    if (idx > monthsCount) return monthsCount;
    return idx;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'monthlyAmount': monthlyAmount,
    'monthsCount': monthsCount,
    'startYear': startYear,
    'startMonth': startMonth,
    'receiveMonthIndex': receiveMonthIndex,
    'paidMonths': paidMonths,
    'received': received,
  };

  factory Jam3eya.fromJson(Map<String, dynamic> j) => Jam3eya(
    id: j['id'] as String,
    name: j['name'] as String,
    monthlyAmount: (j['monthlyAmount'] as num).toDouble(),
    monthsCount: j['monthsCount'] as int,
    startYear: j['startYear'] as int,
    startMonth: j['startMonth'] as int,
    receiveMonthIndex: j['receiveMonthIndex'] as int,
    paidMonths: (j['paidMonths'] as List<dynamic>)
        .map((e) => e as bool)
        .toList(),
    received: (j['received'] as bool?) ?? false,
  );
}
