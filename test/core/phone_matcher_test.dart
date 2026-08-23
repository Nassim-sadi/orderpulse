import 'package:cod_delivery_app/core/utils/phone_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('phoneNumbersMatch', () {
    test('matches identical numbers', () {
      expect(phoneNumbersMatch('0550123456', '0550123456'), isTrue);
    });

    test('ignores spaces and dashes', () {
      expect(phoneNumbersMatch('055 01-23 456', '0550123456'), isTrue);
      expect(
          phoneNumbersMatch('0550-123-456', '05 50 12 34 56'), isTrue);
    });

    test('strips country-code plus prefix', () {
      expect(phoneNumbersMatch('+213550123456', '0550123456'), isTrue);
    });

    test('matches on shared suffix of at least six digits', () {
      expect(phoneNumbersMatch('00213661987654', '0661987654'), isTrue);
    });

    test('rejects different numbers with same length', () {
      expect(phoneNumbersMatch('0550123457', '0550123456'), isFalse);
    });

    test('rejects matches shorter than six digits', () {
      expect(phoneNumbersMatch('123456', '654321'), isFalse);
      expect(phoneNumbersMatch('99', '99'), isFalse);
    });

    test('handles null and empty logged numbers safely', () {
      expect(phoneNumbersMatch(null, '0550123456'), isFalse);
      expect(phoneNumbersMatch('', '0550123456'), isFalse);
    });

    test('handles empty client number', () {
      expect(phoneNumbersMatch('0550123456', ''), isFalse);
    });
  });
}
