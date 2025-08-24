import 'dart:convert';
import 'package:crypto/crypto.dart';

int _hash32(String key) {
  final bytes = md5.convert(utf8.encode(key)).bytes;
  final n = (bytes[0] << 24) |
            (bytes[1] << 16) |
            (bytes[2] << 8)  |
            (bytes[3]);
  return n & 0x7fffffff; // pozitif 31-bit
}

int dailyId({required String medId, required int minutesSinceMidnight}) =>
    _hash32('daily|$medId|$minutesSinceMidnight');

int weeklyId({required String medId, required int weekday, required int minutesSinceMidnight}) =>
    _hash32('weekly|$medId|$weekday|$minutesSinceMidnight');

int oneOffId({required String medId, required DateTime at}) =>
    _hash32('oneoff|$medId|${at.toIso8601String()}');
