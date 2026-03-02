import 'dart:async';

import 'package:bootstrap/core.dart';
import 'implementations/dev.dart';
import 'implementations/sentry.dart';
import 'implementations/sentry_performance.dart';

export 'implementations/dev.dart';
export 'implementations/sentry.dart';
export 'implementations/sentry_performance.dart';

const Logger appLogger = MultiLogger([DevLogger(), SentryLogger()]);
const PerformanceLogger appPerformanceLogger = SentryPerformanceLogger();

class MultiLogger extends Logger {
  const MultiLogger(this.loggers);
  final List<Logger> loggers;

  @override
  FutureOr<void> init() async {
    await Future.wait(loggers.map((e) => Future.value(e.init())));
  }

  // ---------- fan-out with stack preserved ----------
  @override
  void debug(String msg, {Map<String, Object?>? extra}) {
    for (final logger in loggers) {
      logger.debug(msg, extra: extra);
    }
  }

  @override
  void info(String msg, {Map<String, Object?>? extra}) {
    for (final logger in loggers) {
      logger.info(msg, extra: extra);
    }
  }

  @override
  void warn(String msg, {Map<String, Object?>? extra}) {
    for (final logger in loggers) {
      logger.warn(msg, extra: extra);
    }
  }

  @override
  void error(
    String msg, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? extra,
  }) {
    for (final logger in loggers) {
      logger.error(msg, error: error, stack: stack, extra: extra);
    }
  }

  @override
  void exception(
    Object throwable, {
    StackTrace? stack,
    Map<String, Object?>? extra,
  }) {
    for (final logger in loggers) {
      logger.exception(throwable, stack: stack, extra: extra);
    }
  }
}
