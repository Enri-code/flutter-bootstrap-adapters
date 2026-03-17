import 'dart:async';
import 'package:bootstrap/interfaces/store/store.dart';

/// Mixin for [KVPrimitiveStore] that adds stream and watch functionality.
/// This mixin can be applied to any [KVPrimitiveStore] to make it [StreamableKVPrimitiveStore].
mixin KVPrimitiveStoreStreamMixin on KVPrimitiveStore {
  final _controllers = <String, StreamController<dynamic>>{};

  Stream<V?> watch<V>(String key) {
    final controller = _controllers.putIfAbsent(key, () {
      return StreamController<dynamic>.broadcast(
        onCancel: () {
          _controllers[key]?.close();
          _controllers.remove(key);
        },
      );
    });
    return controller.stream.cast<V?>();
  }

  @override
  Future<void> set<V>(String key, V value) async {
    await super.set(key, value);
    _controllers[key]?.add(value);
  }

  @override
  Future<void> delete(String key) async {
    await super.delete(key);
    _controllers[key]?.add(null);
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}

/// Mixin for [KVObjectStore] that adds stream and watch functionality.
mixin KVObjectStoreStreamMixin<ObjectType> on KVObjectStore<ObjectType> {
  final _controllers = <String, StreamController<ObjectType?>>{};

  Stream<ObjectType?> watch(String key) {
    final controller = _controllers.putIfAbsent(key, () {
      return StreamController<ObjectType?>.broadcast(
        onCancel: () {
          _controllers[key]?.close();
          _controllers.remove(key);
        },
      );
    });
    return controller.stream;
  }

  @override
  Future<void> set(String key, ObjectType value) async {
    await super.set(key, value);
    _controllers[key]?.add(value);
  }

  @override
  Future<void> delete(String key) async {
    await super.delete(key);
    _controllers[key]?.add(null);
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}

/// Mixin for [PrimitiveStore] that adds stream and watch functionality.
mixin PrimitiveStoreStreamMixin<V> on PrimitiveStore<V> {
  StreamController<V?>? _controller;

  Stream<V?> watch() {
    _controller ??= StreamController<V?>.broadcast(
      onCancel: () {
        _controller?.close();
        _controller = null;
      },
    );
    return _controller!.stream;
  }

  @override
  Future<void> set(V value) async {
    await super.set(value);
    _controller?.add(value);
  }

  @override
  Future<void> delete() async {
    await super.delete();
    _controller?.add(null);
  }

  void dispose() {
    _controller?.close();
    _controller = null;
  }
}

/// Mixin for [ObjectStore] that adds stream and watch functionality.
mixin ObjectStoreStreamMixin<ObjectType> on ObjectStore<ObjectType> {
  StreamController<ObjectType?>? _controller;

  Stream<ObjectType?> watch() {
    _controller ??= StreamController<ObjectType?>.broadcast(
      onCancel: () {
        _controller?.close();
        _controller = null;
      },
    );
    return _controller!.stream;
  }

  @override
  Future<void> set(ObjectType value) async {
    await super.set(value);
    _controller?.add(value);
  }

  @override
  Future<void> delete() async {
    await super.delete();
    _controller?.add(null);
  }

  void dispose() {
    _controller?.close();
    _controller = null;
  }
}
