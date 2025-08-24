// domain/entities/local_time.dart
class LocalTime {
  final int hour;   // 0..23
  final int minute; // 0..59

  const LocalTime(this.hour, this.minute)
      : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60);

  int get minutesSinceMidnight => hour * 60 + minute;

  factory LocalTime.fromMinutes(int m) {
    final h = (m ~/ 60) % 24;
    final mm = m % 60;
    return LocalTime(h, mm);
  }

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
