import 'dart:async';
import 'package:bootstrap/interfaces/time/time_service.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:time_config_checker/time_config_checker.dart';

/// Implementation of TimeService using NTP synchronization.
///
/// Features:
/// - Fetches time from NTP servers (pool.ntp.org)
/// - Checks if system time is automatic, throws exception if not
/// - Detects day changes in user's local timezone
class NtpTimeService implements TimeService {
  @override
  Future<DateTime> getTime() async {
    if (await _isSystemTimeAutomatic()) return DateTime.now();

    try {
      return NTP.now(timeout: const Duration(seconds: 10));
    } catch (_) {
      throw const SystemTimeNotAutomaticException();
    }
  }

  @override
  Stream<void> trackTime(
    Duration time, {
    bool emitIfPastTime = false,
    bool repeat = false,
  }) async* {
    final currentTime = await getTime();
    final currentDay = DateUtils.dateOnly(currentTime);

    var targetTime = currentDay.add(time);

    if (targetTime.isAfter(currentTime)) {
      if (emitIfPastTime) yield null;
      targetTime = targetTime.add(const Duration(days: 1));
    }

    final duration = targetTime.difference(currentTime);

    await Future.delayed(duration);

    yield null;

    if (repeat) yield* Stream.periodic(Duration(hours: 24));
  }

  /// Check if system time is set to automatic.
  Future<bool> _isSystemTimeAutomatic() async {
    final config = await const TimeConfigChecker().getTimeConfig();
    return config.isAutomaticTime && config.isAutomaticTimeZone;
  }
}
