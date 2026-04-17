// logger/implementations/sentry.dart
import 'dart:async';

import 'package:bootstrap/core.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryLogger extends Logger {
  const SentryLogger();

  @override
  FutureOr<void> init() {
    FlutterError.onError = (details) {
      error(
        'flutter_error',
        stack: details.stack,
        extra: {
          'exception': details.exceptionAsString(),
          'library': details.library,
          'context': details.context?.toDescription(),
        },
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      exception(error, stack: stack);
      return true;
    };
  }

  @override
  void debug(String msg, {Map<String, Object?>? extra}) =>
      _crumb(SentryLevel.debug, msg, extra);
  @override
  void info(String msg, {Map<String, Object?>? extra}) =>
      _crumb(SentryLevel.info, msg, extra);
  @override
  void warn(String msg, {Map<String, Object?>? extra}) {
    unawaited(
      Sentry.captureMessage(
        msg,
        level: SentryLevel.warning,
        withScope: (s) {
          if (extra != null) s.setExtras(extra);
        },
      ),
    );
  }

  @override
  void error(
    String msg, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? extra,
  }) {
    // fire-and-forget; don't block UI
    unawaited(
      Sentry.captureMessage(
        msg,
        level: SentryLevel.error,
        withScope: (s) {
          if (extra != null) s.setExtras(extra);
        },
      ),
    );
  }

  @override
  void exception(
    Object throwable, {
    StackTrace? stack,
    Map<String, Object?>? extra,
  }) {
    unawaited(
      Sentry.captureException(
        throwable,
        stackTrace: stack,
        withScope: (s) {
          if (extra != null) s.setExtras(extra);
        },
      ),
    );
  }

  void _crumb(SentryLevel level, String msg, Map<String, Object?>? extra) {
    unawaited(
      Sentry.addBreadcrumb(Breadcrumb(level: level, message: msg, data: extra)),
    );
  }
}

extension ExtrasScope on Scope {
  void setExtras(Map<String, Object?> extra) {
    for (final entry in extra.entries) {
      // ignore: discarded_futures
      setContexts(entry.key, entry.value);
    }
  }
}
