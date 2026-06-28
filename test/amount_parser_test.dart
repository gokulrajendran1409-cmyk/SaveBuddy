import 'package:flutter_test/flutter_test.dart';
import 'package:piggy_bank_app/src/providers/transaction_provider.dart';
import 'package:piggy_bank_app/src/utils/amount_parser.dart';

void main() {
  group('Amount parser', () {
    test('calculates remaining balance after a withdrawal', () {
      final provider = TransactionProvider();
      expect(provider.getRemainingBalanceForWithdrawal(150), -150);
    });

    test('parses calculator-style multiplications into a total and breakdown', () {
      final parsed = AmountParser.parse('10*2');

      expect(parsed.total, 20);
      expect(parsed.parts, hasLength(1));
      expect(parsed.parts.first.denominator, 10);
      expect(parsed.parts.first.count, 2);
    });

    test('supports whitespace and multiple denominations', () {
      final parsed = AmountParser.parse(' 20 * 5  + 5*4 ');

      expect(parsed.total, 120);
      expect(parsed.parts, hasLength(2));
      expect(parsed.parts.first.denominator, 20);
      expect(parsed.parts.first.count, 5);
      expect(parsed.parts.last.denominator, 5);
      expect(parsed.parts.last.count, 4);
    });

    test('parses keypad style expressions with plus and multiply', () {
      final parsed = AmountParser.parse('10*2+20*5');

      expect(parsed.total, 120);
      expect(parsed.parts, hasLength(2));
      expect(parsed.parts.first.denominator, 10);
      expect(parsed.parts.first.count, 2);
      expect(parsed.parts.last.denominator, 20);
      expect(parsed.parts.last.count, 5);
    });
  });
}
