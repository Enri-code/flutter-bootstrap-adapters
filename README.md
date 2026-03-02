# Adapters

Infrastructure adapters package that provides concrete implementations and re-exports reusable packages.

## Overview

This package serves as a central hub for infrastructure concerns, providing:
- Concrete implementations of core interfaces
- Re-exports of reusable packages (auth_core, network_queue, push_notifications)
- Platform-specific adapters

## Included Packages

### Re-exported Packages

- **auth_core** - Token storage and authentication
- **network_queue** - Offline-first network queue
- **push_notifications** - Local and push notifications

### Adapters

- **Connectivity** - Network connectivity monitoring
- **DI** - Dependency injection with get_it
- **HTTP** - Dio HTTP client factory
- **Logger** - Logging implementations (dev, Sentry)
- **Router** - GoRouter factory
- **Store** - In-memory and SharedPreferences storage
- **Time** - NTP time service

## Usage

```dart
import 'package:adapters/adapters.dart';

// All adapters and re-exported packages available
```

## Structure

```
lib/
├── connectivity/          # Network connectivity
├── di/                    # Dependency injection
├── http/                  # HTTP client
│   └── client/
├── logger/                # Logging
│   └── implementations/
├── router/                # Routing
├── store/                 # Storage
├── time/                  # Time service
└── adapters.dart          # Main export
```

## Dependencies

- `core` - Core interfaces
- `auth_core` - Authentication (re-exported)
- `network_queue` - Queue system (re-exported)
- `push_notifications` - Notifications (re-exported)
- `dio` - HTTP client
- `get_it` - DI
- `go_router` - Routing
- `sentry_flutter` - Error tracking
- `shared_preferences` - Storage
- `connectivity_plus` - Connectivity
- `ntp` - Time sync
