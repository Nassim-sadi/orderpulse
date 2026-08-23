bool phoneNumbersMatch(String? loggedNumber, String clientPhone) {
  if (loggedNumber == null ||
      loggedNumber.isEmpty ||
      clientPhone.isEmpty) {
    return false;
  }
  final a = _normalize(loggedNumber);
  final b = _normalize(clientPhone);
  for (final variantA in _variants(a)) {
    for (final variantB in _variants(b)) {
      if (_mutualSuffixMatch(variantA, variantB)) return true;
    }
  }
  return false;
}

const int _minMatchDigits = 6;

bool _mutualSuffixMatch(String a, String b) {
  final tailLength = a.length < b.length ? a.length : b.length;
  if (tailLength < _minMatchDigits) return false;
  return a.endsWith(b.substring(b.length - tailLength)) &&
      b.endsWith(a.substring(a.length - tailLength));
}

Set<String> _variants(String number) =>
    number.startsWith('0') ? {number, number.substring(1)} : {number};

String _normalize(String number) => number.replaceAll(
      RegExp(r'[\s\-\(\)\+]'),
      '',
    );
