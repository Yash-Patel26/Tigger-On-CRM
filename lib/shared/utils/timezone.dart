class TimezoneUtil {
  static const Duration _istOffset = Duration(hours: 5, minutes: 30);

  static DateTime toIST(DateTime dateTime) {
    final DateTime utc = dateTime.isUtc ? dateTime : dateTime.toUtc();
    return utc.add(_istOffset);
  }

  static DateTime nowIST() {
    return DateTime.now().toUtc().add(_istOffset);
  }
}
