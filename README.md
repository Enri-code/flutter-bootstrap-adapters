# Adapters

Infrastructure adapters package providing concrete implementations of core interfaces for Flutter applications.

## Overview

This package provides production-ready implementations for common infrastructure concerns:
- Network connectivity monitoring
- Dependency injection (DI)
- HTTP client with retry and token refresh
- Logging (development and Sentry)
- Routing with GoRouter
- Storage (in-memory and persistent)
- Time synchronization with NTP
- Network queue management

## Features

### Connectivity
- Real-time network status monitoring
- Support for WiFi, mobile, and ethernet connections
- Broadcast stream for multiple listeners

### Dependency Injection
- GetIt-based DI container
- Singleton and lazy singleton registration
- Async dependency support

### HTTP Client
- Dio-based HTTP client factory
- Smart retry mechanism
- OAuth token management with automatic refresh
- Secure token storage (FlutterSecureStorage)
- In-memory token storage for development

### Logging
- Multi-logger support (dev + Sentry)
- Performance tracking with Sentry transactions
- Automatic Flutter error capture
- Breadcrumb tracking

### Router
- GoRouter factory for modular routing
- Support for navigation observers
- Deep linking and restoration

### Storage
- Key-value primitive storage (SharedPreferences)
- Object storage with JSON serialization
- In-memory storage for testing/development

### Time Service
- NTP time synchronization
- Automatic time configuration validation
- Midnight detection for day-change events

### Network Queue
- Queue manager for offline-first operations
- Automatic retry on connectivity restore
- Task lifecycle management

## Usage

```dart
import 'package:adapters/adapters.dart';

// Connectivity
final connectivity = ConnectivityAdapter(Connectivity());
final isOnline = connectivity.isConnected;

// DI
final di = GetItDI();
di.registerSingleton<MyService>(MyService());

// HTTP Client
final dio = DioFactory.build(
  baseUrl: 'https://api.example.com',
  timeout: Duration(seconds: 30),
);

// Logging
await appLogger.init();
appLogger.info('Application started');

// Storage
final store = createKVPrimitiveStore();
await store.set('key', 'value');

// Time Service
final timeService = NtpTimeService();
final currentTime = await timeService.getTime();
```

## Structure

```
lib/
├── connectivity/          # Network connectivity monitoring
├── di/                    # Dependency injection (GetIt)
├── http/                  # HTTP client and token management
│   ├── client/           # Dio factory
│   └── interceptors/     # Fresh Dio token refresh
├── logger/                # Logging implementations
│   └── implementations/  # Dev, Sentry, Performance
├── queue/                 # Network queue management
│   ├── manager/          # Queue manager
│   └── runner/           # Queue runner
├── router/                # GoRouter factory
├── store/                 # Storage implementations
├── time/                  # NTP time service
└── adapters.dart          # Main export
```

## Dependencies

- `bootstrap` - Core interfaces
- `dio` - HTTP client
- `dio_smart_retry` - Retry logic
- `fresh_dio` - Token refresh
- `get_it` - Dependency injection
- `go_router` - Routing
- `sentry_flutter` - Error tracking
- `shared_preferences` - Persistent storage
- `flutter_secure_storage` - Secure token storage
- `connectivity_plus` - Connectivity monitoring
- `ntp` - Time synchronization
- `time_config_checker` - Time configuration validation
