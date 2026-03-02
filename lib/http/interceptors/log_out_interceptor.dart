import 'package:common/domain/events/logout_event.dart';
import 'package:common/utils/extensions/dio_extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class LogOutEventInterceptor extends Interceptor {
  LogOutEventInterceptor({required this.logoutEventGetter});
  final ValueGetter<LogOutEvent> logoutEventGetter;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.shouldLogOut()) {
      logoutEventGetter().fire();
    }
    handler.next(err);
  }
}
