/// Afghanistan phone number formatting (+93) for admin list display.
abstract final class PhoneUtils {
  static const String countryCode = '+93';

  static bool isValidAfghanPhone(String phone) {
    return RegExp(r'^\+937\d{8}$').hasMatch(phone);
  }

  static String formatForDisplay(String e164Phone) {
    if (!e164Phone.startsWith(countryCode)) return e164Phone;
    final national = '0${e164Phone.substring(countryCode.length)}';
    if (national.length != 10) return e164Phone;
    final formatted =
        '${national.substring(0, 4)} ${national.substring(4, 7)} ${national.substring(7)}';
    return '\u2066$formatted\u2069';
  }
}
