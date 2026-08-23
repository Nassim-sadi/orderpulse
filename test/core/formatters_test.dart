import 'package:flutter_test/flutter_test.dart';
import 'package:cod_delivery_app/core/utils/formatters.dart';

void main() {
  group('Formatters.dzd', () {
    test('formats whole amounts', () {
      expect(Formatters.dzd(5100), '5,100 DZD');
    });

    test('formats zero', () {
      expect(Formatters.dzd(0), '0 DZD');
    });
  });

  group('Formatters.countdown', () {
    test('pads minutes and seconds', () {
      expect(Formatters.countdown(const Duration(minutes: 14, seconds: 5)),
          '14:05');
    });

    test('clamps negative durations to zero', () {
      expect(
          Formatters.countdown(const Duration(minutes: -2)), '00:00');
    });
  });

  group('Formatters.isoDate', () {
    test('formats as yyyy-MM-dd', () {
      expect(
        Formatters.isoDate(DateTime(2026, 8, 22)),
        '2026-08-22',
      );
    });
  });
}
