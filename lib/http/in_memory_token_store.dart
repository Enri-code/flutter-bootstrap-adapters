import 'dart:async';
import 'package:bootstrap/interfaces/http/oauth_token/models/oauth_token.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:bootstrap/interfaces/store/primitive_store.dart';
import '../store/in_memory_store.dart';

class InMemoryTokenStore implements TokenStore {
  InMemoryTokenStore([ObjectStore<OAuthToken>? storage])
    : _storage = storage ?? InMemoryObjectStore();

  final ObjectStore<OAuthToken> _storage;

  @override
  Future<OAuthToken?> read() => _storage.get();

  @override
  Future<void> write(OAuthToken token) => _storage.set(token);

  @override
  Future<void> delete() => _storage.delete();
}
