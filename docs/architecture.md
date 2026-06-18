# Layers, Streams, Invariants, and Architectural Decisions

## Related Docs

- [Navigation](common/navigation.md)

## Future Structure Analysis: Example

### Directory Structure

```
example/
├─ controller/
│  └─ example_controller.dart
├─ data/
│  └─ example_repository.dart
├─ models/
│  ├─ example.dart
│  ├─ example_other_1.dart
│  ├─ example_other_2.dart
│  └─ example_other_3.dart
└─ widgets/
   ├─ controllers/
   │  └─ example_data_controller.dart
   ├─ desktop/example_desktop_widget.dart
   ├─ mobile/example_mobile_widget.dart
   ├─ tablet/example_tablet_widget.dart
   └─ example_config_widget.dart
```

## 1. Data Layer (data/)

Data layer is responsible for data fetching and persisting logic. All repositories should contain an `interface` class like `abstract interface class IExampleRepository {}` which starts with the letter `I` as `interface`, and its implementation like `class ExampleRepository implements IExampleRepository {}`. Fake implementations for testing purposes should also be provided with @visibleForTesting annotation.

When a repository also has fixture-backed unit tests under `test/unit_test/src/feature/<domain>/data/fixtures/`, prefer building fake repository response constants from the same payload shapes. This keeps `Repository$Fake` behavior close to the transport contract validated by tests and reduces silent drift between fake data and mocked API responses. `SaleRepository$Fake` is the reference example for this pattern.

### Transport Layer And Client Selection

The project currently has two transport entrypoints exposed by `packages/api` or the main app `src/common/api_client`

- `ApiClient$HTTP`: middleware-based `package:http` transport that returns full response metadata

Repository choice should be explicit:

- use `ApiClient$HTTP` by default for new repositories and when migrating existing repositories
- keep repository constructors explicit about the transport they need; do not hide HTTP/Dio selection behind feature-local aliases
- account for the `ApiClient$HTTP` response contract during migration: responses must be JSON objects with an `application/json` content type

Do not migrate endpoints that return files, plain text, binary payloads, or
other non-JSON bodies to `ApiClient$HTTP` until the backend response format or
the transport contract is adapted for that use case.

Connectivity guards must represent general internet reachability, not backend
health. `ConnectivityService` is the shared source for both Dio and HTTP
preflight checks; backend outages should surface as request/server errors
instead of switching the global offline banner on.

Do not place feature/session-specific transport logic inside `packages/api` or the main app `src/common/api_client`.
App-specific token refresh, logout, app metadata injection, and Sentry binding
must stay in the main app or the relevant feature module.

### Local Persistence And Cache Placement

- The project already has two built-in persistence mechanisms in the dependency graph: `Database` for structured/local relational state and `SharedPreferencesAsync` for small key-value state.
- Before introducing any new cache abstraction, first decide whether the data should live in `Database` or in `SharedPreferencesAsync`.
- Do not add a separate generic cache store for application data unless the existing persistence layers are demonstrably insufficient for the specific scenario.

**Example: `example_repository.dart` (required)**

```dart
/// {@template example_repository}
/// ExampleRepository class.
/// Used to getting the example's data.
/// {@endtemplate}
abstract interface class IExampleRepository {}

/// {@macro example_repository}
class ExampleRepository implements IExampleRepository {
	/// {@macro example_repository}
  ExampleRepository(ApiClient$HTTP client) : _client = client;

	/// Api client for repository.
  final ApiClient$HTTP _client;
}

/// Fake implementation of [IExampleRepository] for testing purposes.
@visibleForTesting
class ExampleRepository$Fake implements IExampleRepository {
  ExampleRepository$Fake({
    Duration fakeDalay = const Duration(milliseconds: int.fromEnvironment('FAKE_DELAY', defaultValue: 500)),
  }) : _fakeDalay = fakeDalay;

  final Duration _fakeDalay;
  Future<void> _delay([double k = 1.0]) => Future<void>.delayed(_fakeDalay * k);
}
```

For non-trivial repositories, fake responses should follow the same backend-like envelopes used in fixture files, for example `count + data`, `count + sales`, `count + memberships`, or nested objects such as `cashboxes`. Avoid inventing a simplified fake-only response shape if the real repository and its tests already rely on a richer contract.

### Transport ownership rules

The following transport concerns are considered reusable and belong in
`packages/api` or the main app `src/common/api_client`:

- connectivity guards
- deduplication
- retry and backoff
- timeout handling
- transport-safe logging
- shared exceptions and response wrappers

The following concerns are application-owned and should remain outside the
package or move into feature modules:

- authentication refresh and logout orchestration
- app metadata headers based on app models
- Sentry integration that binds to app controller state

Android app metadata that reports device service ecosystems must resolve GMS/HMS availability from the platform layer, not from vendor/manufacturer strings. Manufacturer remains diagnostic metadata only; service flags come from runtime platform checks.

## 2. Model Layer (models/)

Models represent business entities and are immutable. Use required in constructors for all fields including nullable ones.

**Example: `example.dart` (optional)**

```dart
@immutable
class Example {
  const Example({
    required this.id,
    required this.categoryID,
    required this.number,
    required this.createdAt,
    required this.enumiration,
    required this.otherEntity,
    required this.items,
    // ... other fields
  });

  // Factory constructor for creating a model from JSON (Map<String, Object?>)
  factory Example.fromJson(Map<String, Object?> json, [Currency? currency]) {
  if (json.isEmpty) throw FormatException('Example | JSON is empty', json);
  if (json case <String, Object?>{'id': int id}) {
    return Example(
      id: id,
      number: switch (json['number']) {
        String s when s.isNotEmpty => int.tryParse(s),
        double d when d >= 0 => d.toInt(),
        int i when i >= 0 => i,
        _ => null,
      },
      createdAt: switch (json['createdAt'] ?? json['created_at']) {
        String s when s.isNotEmpty => DateTime.parse(s).toLocal(),
        DateTime dt => dt.toLocal(),
        _ => null,
      },
      enumiration: switch (json['enumiration']) {
        String e when e.isNotEmpty => Enumiration.fromValue(e, fallback: Enumiration.unknown),
        _ => Enumiration.unknown,
      },
      otherEntity: switch (json['otherEntity'] ?? json['other_entity']) {
        Map<String, Object?> e => OtherEntity.fromJson(e),
        _ => null,
      },
      items: switch (json['items']) {
        List<Object?> list when list.isNotEmpty =>
          list.whereType<Map<String, Object?>>()
              .map((e) => Example$Item.fromJson(e, currency ?? Config.currency))
              .whereType<Example$Item>()
              .toList(growable: false),
        _ => const <Example$Item>[],
      },
      // ... other fields
    );
  }
  throw FormatException('Example | JSON is invalid', json);
}

  // Properties
  final int id;
  final int? categoryID;
  final int? number;
  final DateTime? createdAt;
  final Enumiration enumiration;
  final OtherEntity? otherEntity;
  final List<Example$Item> items;
  // ... other fields

  // Copy with method for immutability
  Example copyWith({
    int? id,
    int? categoryID,
    int? number,
    DateTime? createdAt,
    Enumiration? enumiration,
    OtherEntity? otherEntity,
    List<Example$Item>? items,
    /*... other fields */
  }) {
    return Example(
      id: id ?? this.id,
      categoryID: categoryID ?? this.categoryID,
      number: number ?? this.number,
      createdAt: createdAt ?? this.createdAt,
      enumiration: enumiration ?? this.enumiration,
      otherEntity: otherEntity ?? this.otherEntity,
      items: items ?? this.items,
      // ... other fields
    );
  }

  @override
  String toString() {
    final parts = <String>['id: $id'];
    if (categoryID != null) parts.add('categoryID: $categoryID');
    if (number != null) parts.add('number: $number');
    if (createdAt != null) parts.add('createdAt: $createdAt');
    if (enumiration != Enumiration.unknown) parts.add('enumiration: $enumiration');
    if (otherEntity != null) parts.add('otherEntity: $otherEntity');
    if (items.isNotEmpty) parts.add('items: ${items.length}');
    // ... other fields
    return 'Example.$id{${parts.join(', ')}}';
  }
}
```

## 3. Controller Layer (controller/)

Controllers manage state and business logic using reactive programming patterns. Controllers should be extended from `AppController$Sequential`, `ValueListenable` or `ChangeNotifier`.

**Example: `example_controller.dart` (required)**

```dart
sealed class ExampleState extends _$ExampleStateBase {
  const ExampleState({
    required super.data,
    required super.message,
    super.error,
    super.stackTrace,
  });

  const factory ExampleState.idle({
    required List<MItem>? data,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = ExampleState$Idle;

  const factory ExampleState.processing({
    required List<MItem>? data,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = ExampleState$Processing;

  const factory ExampleState.failed({
    required List<MItem>? data,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = ExampleState$Failed;
}

final class ExampleState$Idle extends ExampleState {
  const ExampleState$Idle({
    required super.data,
    super.message = 'Idle',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'idle';
}

final class ExampleState$Processing extends ExampleState {
  const ExampleState$Processing({
    required super.data,
    super.message = 'Processing',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'processing';
}

final class ExampleState$Failed extends ExampleState {
  const ExampleState$Failed({
    required super.data,
    super.message = 'Failed',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'failed';
}

typedef ExampleStateMatch<R, S extends ExampleState> = R Function(S state);

@immutable
abstract base class _$ExampleStateBase {
  const _$ExampleStateBase({
    required this.data,
    required this.message,
    this.error,
    this.stackTrace,
  });

  abstract final String type;

  /// Data entity payload.
  @nonVirtual
  final List<MItem>? data;

  /// Message or state description.
  @nonVirtual
  final String message;

  /// Error if any.
  @nonVirtual
  final Object? error;

  /// Optional object for error additional data.
  @nonVirtual
  final StackTrace? stackTrace;

  bool get hasData => data != null && data!.isNotEmpty;

  /// Check if is Processing.
  bool get isProcessing => this is ExampleState$Processing;

  /// Check if is Failed.
  bool get isFailed => this is ExampleState$Failed;

  /// Check if is Idle.
  bool get isIdle => this is ExampleState$Idle;

  R map<R>({
    required ExampleStateMatch<R, ExampleState$Processing> processing,
    required ExampleStateMatch<R, ExampleState$Failed> failed,
    required ExampleStateMatch<R, ExampleState$Idle> idle,
  }) => switch (this) {
    ExampleState$Processing s => processing(s),
    ExampleState$Failed s => failed(s),
    ExampleState$Idle s => idle(s),
    _ => throw AssertionError(),
  };

  R maybeMap<R>({
    required R Function() orElse,
    ExampleStateMatch<R, ExampleState$Processing>? processing,
    ExampleStateMatch<R, ExampleState$Failed>? failed,
    ExampleStateMatch<R, ExampleState$Idle>? idle,
  }) => map<R>(
    processing: processing ?? (_) => orElse(),
    failed: failed ?? (_) => orElse(),
    idle: idle ?? (_) => orElse(),
  );

  R? mapOrNull<R>({
    ExampleStateMatch<R, ExampleState$Processing>? processing,
    ExampleStateMatch<R, ExampleState$Failed>? failed,
    ExampleStateMatch<R, ExampleState$Idle>? idle,
  }) => map<R?>(
    processing: processing ?? (_) => null,
    failed: failed ?? (_) => null,
    idle: idle ?? (_) => null,
  );

  @override
  int get hashCode => Object.hash(data, count, ids, message, type);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _$ExampleStateBase && type == other.type && identical(data, other.data));

  @override
  String toString() => 'ExampleState.$type{message: $message}';
}

// Define the controller
final class ExampleController extends AppController$Sequential<ExampleState> {
  ExampleController({required IExampleRepository repository, ExampleState? state})
    : _repository = repository,
      super(
        initialState: state ?? const ExampleState.idle(data: null, message: 'Initial'),
        name: 'ExampleController',
      );

  final IExampleRepository _repository;

  Future<void> fetchData({
    void Function(Object error)? onError,
    void Function()? onProcessing,
    void Function()? onSucceeded,
    void Function()? onDone,
  }) => handle(
    () async {
      setState(
        ExampleState.processing(
          data: state.data,
          message: 'Fetching the data...',
        ),
      );
      onProcessing?.call();
      l.i('Fetching the data...');
      final data = await _repository.fetchData();
      setState(
        ExampleState.idle(
          data: data,
          message: '${data.length} data fetched',
        ),
      );
      onSucceeded?.call();
    },
    error: (e, s) async {
      setState(
        ExampleState.failed(
          data: state.data,
          error: e,
          stackTrace: s,
          message: 'Failed to fetch data: ${ErrorUtil.formatMessage(e)}',
        ),
      );
      onError?.call(e);
    },
    done: () async {
      setState(ExampleState.idle(data: state.data, error: state.error, stackTrace: state.stackTrace));
      onDone?.call();
    },
    name: 'fetchData',
    meta: <String, Object?>{}, // Any additional metadata
  );
}

// Consumer usage (simplified)
StateConsumer<ExampleController, ExampleState>(
  controller: controller,
  buildWhen: (previous, current) => previous.data != current.data,
  builder: (_, state, __) => state.map(
    processing: (_) => const CircularProgressIndicator(),
    failed: (s) => Text('Error: ${s.message}'),
    idle: (_) => const Text('Idle'),
  ),
);
```

## 4. Widget Layer (widgets/)

Widgets are responsible for UI and presentation logic. They should be as dumb as possible, and all business logic should be handled in controllers. Widgets can be divided into subdirectories based on their purpose (e.g., `controllers/` for widgets that manage their own state, `desktop/`, `mobile/`, `tablet/` for platform-specific widgets, etc.).