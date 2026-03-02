import 'dart:async';
import 'dart:io' show Platform;
import 'package:bootstrap/interfaces/http/oauth_token/models/codec.dart';
import 'package:bootstrap/interfaces/http/oauth_token/models/oauth_token.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'in_memory_token_store.dart';

final class SecureTokenStore implements TokenStore {
  SecureTokenStore({
    FlutterSecureStorage? storage,
    String namespace = 'auth',
    OAuthTokenCodec? codec,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _key = '$namespace.tokens',
       _codec = codec ?? const OAuthTokenCodec();

  final String _key;
  final FlutterSecureStorage _storage;
  final OAuthTokenCodec _codec;

  OAuthToken? _cached;

  @override
  Future<OAuthToken?> read() async {
    if (_cached != null) return _cached;
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;

      return _cached = _codec.fromJson(raw);
    } catch (_) {
      await delete(); // purge corrupted record
      return null;
    }
  }

  @override
  Future<void> write(OAuthToken token) async {
    _cached = token;
    await _storage.write(key: _key, value: _codec.toJson(token));
  }

  @override
  Future<void> delete() async {
    _cached = null;
    await _storage.delete(key: _key);
  }
}

TokenStore createTokenStore() {
  return kDebugMode && Platform.isAndroid
      ? InMemoryTokenStore()
      : SecureTokenStore();
}
