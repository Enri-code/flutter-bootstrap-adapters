// my_logger/logger/dev.dart
import 'dart:async';
import 'dart:developer';

import 'package:bootstrap/core.dart';
import 'package:flutter/foundation.dart';

enum Level {
  debug,
  info,
  warning,
  error,
  fatal;

  int get value {
    switch (this) {
      case Level.debug:
        return 500;
      case Level.info:
        return 800;
      case Level.warning:
        return 900;
      case Level.error:
        return 100;
      case Level.fatal:
        return 1200;
    }
  }
}

class DevLogger extends Logger {
  const DevLogger();

  @override
  FutureOr<void> init() async {
    // Global Flutter error hooks (safe to call multiple times)
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

  void _print(Level level, String msg, Map<String, Object?>? extra) {
    log('[${level.name}] $msg ${extra ?? ''}', level: level.value);
  }

  @override
  void debug(String msg, {Map<String, Object?>? extra}) =>
      _print(Level.debug, msg, extra);
  @override
  void info(String msg, {Map<String, Object?>? extra}) =>
      _print(Level.info, msg, extra);
  @override
  void warn(String msg, {Map<String, Object?>? extra}) =>
      _print(Level.warning, msg, extra);

  @override
  void error(
    String msg, {
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? extra,
  }) {
    final data = {
      ...?extra,
      'error': error?.toString(),
      'stack': ?stack?.toString(),
    };
    _print(Level.error, msg, data.isEmpty ? null : data);
  }

  @override
  void exception(
    Object throwable, {
    StackTrace? stack,
    Map<String, Object?>? extra,
  }) {
    _print(Level.fatal, '$throwable', {...?extra, 'stack': ?stack?.toString()});
  }
}
