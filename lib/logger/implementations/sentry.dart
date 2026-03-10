// logger/implementations/sentry.dart
import 'dart:async';

import 'package:bootstrap/core.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryLogger extends Logger {
  const SentryLogger();

  static bool _enabled = false;

  /// Check if Sentry is enabled
  static bool get isEnabled => _enabled;

  static Future<void> initSentry(
    String dsn, {
    String? environment,
    bool analyticsEnabled = false,
  }) async {
    await SentryFlutter.init((o) {
      o
        ..dsn = dsn
        ..enableAppHangTracking = true
        ..environment = environment
        ..tracesSampleRate = analyticsEnabled ? 0.2 : 0.0
        ..enableAutoPerformanceTracing = true
        ..beforeSend = (event, hint) {
          return event
            ..request?.headers = _redact(event.request?.headers) ?? {}
            ..request?.cookies = null;
        };
    });
    _enabled = true;
  }

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

  static Map<String, String>? _redact(Map<String, String>? headers) {
    if (headers == null) return null;
    final h = Map.of(headers);
    for (final k in h.keys) {
      final key = k.toLowerCase();
      if (key.contains('authorization') || key.contains('token')) {
        h[k] = 'REDACTED';
      }
    }
    return h;
  }

  @override
  void debug(String msg, {Map<String, Object?>? extra}) =>
      _crumb(SentryLevel.debug, msg, extra);
  @override
  void info(String msg, {Map<String, Object?>? extra}) =>
      _crumb(SentryLevel.info, msg, extra);
  @override
  void warn(String msg, {Map<String, Object?>? extra}) =>
      _crumb(SentryLevel.warning, msg, extra);

  @override
  void error(
    String msg, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? extra,
  }) {
    if (!_enabled) return;
    _crumb(SentryLevel.error, msg, extra);
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
    if (!_enabled) return;
    _crumb(SentryLevel.fatal, throwable.toString(), extra);
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
    if (!_enabled) return;
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
