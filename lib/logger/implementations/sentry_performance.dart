import 'dart:async';

import 'package:bootstrap/interfaces/logger/performance_logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry-based performance tracker.
///
/// Tracks operation durations and sends them to Sentry for monitoring.
/// Operations appear in Sentry's Performance tab.
///
/// Usage:
/// ```dart
/// final perfLogger = SentryPerformanceLogger();
/// final timer = perfLogger.start('mark_task_complete');
/// try {
///   await markTask();
///   timer.stop(); // Success
/// } catch (e) {
///   timer.stop(failed: true); // Failure
///   rethrow;
/// }
/// ```
class SentryPerformanceLogger implements PerformanceLogger {
  const SentryPerformanceLogger();

  @override
  FutureOr<void> init() {
    // Nothing to initialize - uses SentryLogger's initialization
  }

  @override
  PerformanceTimer start(String operationName) {
    return _SentryTimer(operationName);
  }
}

/// Timer that tracks operation duration using Sentry transactions.
class _SentryTimer implements PerformanceTimer {
  _SentryTimer(this.operationName)
    : _stopwatch = Stopwatch()..start(),
      _transaction = Sentry.startTransaction(
        operationName,
        'operation',
        bindToScope: true,
      );

  final String operationName;
  final Stopwatch _stopwatch;
  final ISentrySpan _transaction;

  @override
  void stop({bool failed = false, Map<String, dynamic>? extra}) {
    _stopwatch.stop();

    // Add metadata
    if (extra != null) {
      for (final entry in extra.entries) {
        _transaction.setData(entry.key, entry.value);
      }
    }

    // Add duration
    _transaction.setData('duration_ms', _stopwatch.elapsedMilliseconds);

    // Finish transaction with appropriate status
    final status = failed
        ? const SpanStatus.internalError()
        : const SpanStatus.ok();
    _transaction.finish(status: status);

    // Also log as breadcrumb for debugging
    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: failed
              ? 'Failed: $operationName'
              : 'Completed: $operationName',
          level: failed ? SentryLevel.error : SentryLevel.info,
          category: 'performance',
          data: {
            'duration_ms': _stopwatch.elapsedMilliseconds,
            'failed': failed,
            if (extra != null) ...extra,
          },
        ),
      ),
    );
  }

  @override
  Duration get elapsed => _stopwatch.elapsed;
}
