import 'dart:io';

import 'package:bootstrap/interfaces/http/oauth_token/models/oauth_token.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:fresh_dio/fresh_dio.dart';

class TokenStoreFreshDioAdapterInterceptor extends Fresh<FreshOAuthToken>
    implements TokenStore {
  TokenStoreFreshDioAdapterInterceptor(
    TokenStore store, {
    required this.refreshUrl,
  }) : _store = store,
       super(
         tokenStorage: FreshDioTokenStorageAdapter(store),
         refreshToken: (FreshOAuthToken? token, Dio dio) {
           return _refreshToken(token, dio, refreshUrl);
         },
         tokenHeader: (token) {
           return {
             HttpHeaders.authorizationHeader: token
                 .toOAuthToken()
                 .authorization,
           };
         },
       );

  final String refreshUrl;
  final TokenStore _store;

  static Future<FreshOAuthToken> _refreshToken(
    FreshOAuthToken? token,
    Dio dio,
    String refreshUrl,
  ) async {
    final data = <String, dynamic>{'refresh_token': token?.refreshToken};
    final result = await dio.post<Map<String, dynamic>>(refreshUrl, data: data);
    return FreshOAuthToken.fromJson(result.data!);
  }

  @override
  Future<void> delete() async {
    _cachedToken = null;
    await Future.wait([clearToken(), _store.delete()]);
  }

  OAuthToken? _cachedToken;

  @override
  Future<OAuthToken?> read() async => _cachedToken ?? await _store.read();

  @override
  Future<void> write(OAuthToken token) async {
    _cachedToken = token;
    await Future.wait([
      setToken(FreshOAuthToken.fromOAuthToken(token)),
      _store.write(token),
    ]);
  }
}

class FreshDioTokenStorageAdapter implements TokenStorage<FreshOAuthToken> {
  FreshDioTokenStorageAdapter(this._store);

  final TokenStore _store;

  @override
  Future<void> delete() => _store.delete();

  @override
  Future<FreshOAuthToken?> read() async {
    final token = await _store.read();
    if (token == null) return null;

    return FreshOAuthToken.fromOAuthToken(token);
  }

  @override
  Future<void> write(FreshOAuthToken token) {
    return _store.write(token.toOAuthToken());
  }
}

class FreshOAuthToken extends OAuth2Token {
  FreshOAuthToken({
    required super.accessToken,
    super.refreshToken,
    super.tokenType,
    super.expiresIn,
  });

  factory FreshOAuthToken.fromJson(Map<String, dynamic> json) {
    json = json['data'] as Map<String, dynamic>;
    return FreshOAuthToken(
      tokenType: json['token_type'] as String? ?? 'Bearer',
      accessToken: json['token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_at'] as int?,
    );
  }

  factory FreshOAuthToken.fromOAuthToken(OAuthToken token) {
    return FreshOAuthToken(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      tokenType: token.tokenType,
    );
  }

  OAuthToken toOAuthToken() {
    return OAuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType ?? 'Bearer',
    );
  }
}
