## 0.0.3

### Bug Fixes

- Downgraded **connectivity_plus** to ^6.1.3

## 0.0.1

### Initial Release

#### Features

- **Connectivity**: Network connectivity monitoring with ConnectivityAdapter
  - Real-time connection status tracking
  - Support for WiFi, mobile, and ethernet
  - Broadcast stream for multiple listeners

- **Dependency Injection**: GetIt-based DI container
  - Singleton and lazy singleton registration
  - Async dependency support
  - Type-safe dependency resolution

- **HTTP Client**: Dio-based HTTP client with advanced features
  - DioFactory for client creation
  - Smart retry mechanism with dio_smart_retry
  - OAuth token management with automatic refresh (fresh_dio)
  - Secure token storage using FlutterSecureStorage
  - In-memory token storage for development

- **Logging**: Multi-logger system
  - DevLogger for development with console output
  - SentryLogger for production error tracking
  - SentryPerformanceLogger for performance monitoring
  - Automatic Flutter error capture
  - Breadcrumb tracking

- **Router**: GoRouter factory for modular routing
  - Support for navigation observers
  - Deep linking support
  - State restoration

- **Storage**: Flexible storage implementations
  - KVPrimitiveStore for key-value primitive types
  - KVObjectStore for JSON-serializable objects
  - SharedPreferences-based persistent storage
  - In-memory storage for testing

- **Time Service**: NTP-based time synchronization
  - Automatic time configuration validation
  - Midnight detection for day-change events
  - Fallback to system time when available

- **Network Queue**: Queue management for offline-first operations
  - NetworkQueueManagerImpl for queue lifecycle
  - QueueRunner for task execution
  - Automatic retry on connectivity restore
  - Task lifecycle callbacks (success, retry, fail)

#### Dependencies

- bootstrap (git)
- dio ^5.9.0
- dio_smart_retry ^7.0.1
- fresh_dio ^0.4.4
- go_router ^17.0.1
- get_it ^9.0.5
- flutter_secure_storage ^10.0.0
- shared_preferences ^2.5.3
- sentry_flutter ^9.8.0
- connectivity_plus ^7.0.0
- ntp ^2.0.0
- time_config_checker ^0.0.15
