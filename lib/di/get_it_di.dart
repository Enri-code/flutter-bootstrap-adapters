import 'package:bootstrap/core.dart';
import 'package:get_it/get_it.dart';

class GetItDI implements DI {
  final _instance = GetIt.asNewInstance();

  // ---------- Registration ----------
  @override
  void registerSingleton<T extends Object>(T instance) {
    _instance.registerSingleton<T>(instance);
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factory) {
    _instance.registerLazySingleton<T>(factory);
  }

  @override
  void registerSingletonAsync<T extends Object>(Future<T> Function() factory) =>
      _instance.registerSingletonAsync<T>(factory);

  // ---------- Resolve ----------
  @override
  T get<T extends Object>() => _instance.get<T>();

  @override
  Future<T> getAsync<T extends Object>() => _instance.getAsync<T>();

  @override
  T? maybeGet<T extends Object>() {
    return _instance.isRegistered<T>() ? _instance.get<T>() : null;
  }

  @override
  bool isRegistered<T extends Object>() => _instance.isRegistered<T>();

  // ---------- Lifecycle ----------
  @override
  Future<void> reset() => _instance.reset();
}
