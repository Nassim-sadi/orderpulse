import 'package:intl/intl.dart';

abstract final class Formatters {
  static final NumberFormat _dzd = NumberFormat.decimalPattern('en');

  static String dzd(num amount) => '${_dzd.format(amount)} DZD';

  static String time(DateTime dt) => DateFormat.Hm().format(dt.toLocal());

  static String dateTime(DateTime dt) =>
      DateFormat('dd MMM • HH:mm').format(dt.toLocal());

  static String isoDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  static String countdown(Duration remaining) {
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    final minutes = clamped.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = clamped.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
