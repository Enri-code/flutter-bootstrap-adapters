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
  /// Controller for day change stream
  final _midnightController = StreamController<void>.broadcast();

  /// Timer for day change detection
  Timer? _dayChangeTimer;

  @override
  Stream<void> get onMidnight => _midnightController.stream;

  @override
  Future<DateTime> getTime() async {
    if (await _isSystemTimeAutomatic()) return DateTime.now();

    try {
      return NTP.now(timeout: const Duration(seconds: 10));
    } catch (e) {
      throw const SystemTimeNotAutomaticException();
    }
  }

  @override
  /// Schedule next day change check
  Future<void> trackMidnight() async {
    final currentDay = await getTime();

    final midnight = DateUtils.dateOnly(
      currentDay,
    ).add(const Duration(days: 1));

    final timeUntilMidnight = midnight.difference(currentDay);

    _dayChangeTimer?.cancel();
    _dayChangeTimer = Timer(timeUntilMidnight, _checkDayChange);
  }

  /// Check if day has changed and emit event
  Future<void> _checkDayChange() async {
    _midnightController.add(null);
    return trackMidnight();
  }

  /// Check if system time is set to automatic.
  Future<bool> _isSystemTimeAutomatic() async {
    final config = await const TimeConfigChecker().getTimeConfig();
    return config.isAutomaticTime && config.isAutomaticTimeZone;
  }

  /// Dispose resources
  @override
  Future<void> dispose() async {
    _dayChangeTimer?.cancel();
    await _midnightController.close();
  }
}
