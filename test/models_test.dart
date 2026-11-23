import 'package:flutter_test/flutter_test.dart';
import 'package:mahfazaty/models.dart';

void main() {
  test('jam3eya totals and receive date', () {
    final j = Jam3eya(
      name: 'جمعية الشغل',
      monthlyAmount: 500,
      monthsCount: 10,
      startYear: 2026,
      startMonth: 11,
      receiveMonthIndex: 4,
    );
    expect(j.totalPot, 5000);
    expect(j.receiveDate, DateTime(2027, 2));
    expect(j.isComplete, false);
    j.paidMonths[0] = true;
    j.paidMonths[1] = true;
    expect(j.paidSoFar, 1000);
    expect(j.remaining, 4000);
  });

  test('debt json roundtrip', () {
    final d = Debt(
      person: 'أحمد',
      amount: 250,
      direction: DebtDirection.owedToMe,
      note: 'شحن كاش',
    );
    final back = Debt.fromJson(d.toJson());
    expect(back.person, 'أحمد');
    expect(back.amount, 250);
    expect(back.direction, DebtDirection.owedToMe);
    expect(back.settled, false);
  });
}
