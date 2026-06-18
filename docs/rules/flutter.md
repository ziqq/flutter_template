# Flutter Rules

This file now contains only Flutter-specific rules and patterns.

Related rule files:
- [dart.md](dart.md) for language-level Dart conventions
- [architecture.md](architecture.md) for layering and project structure
- [models.md](models.md) for entities and serialization
- [workflow.md](workflow.md) for tooling, logging, and codegen
- [testing-preferences.md](testing-preferences.md) for test strategy
- [documentation.md](documentation.md) for comments and API docs
- [ui.md](ui.md) for visual design, color, and typography


## Flutter Style Guide
- Widgets are for UI.
- Prefer composition over inheritance when building widget trees.
- Keep widgets immutable whenever possible.
- Separate ephemeral widget state from application state.
- Compose complex UI from smaller reusable widgets.


## Flutter Best Practices
- Prefer small private widget classes over private methods returning widgets.
- Break down large `build()` methods into smaller widget units.
- Use `ListView.builder` or `SliverList` for long lazy lists.
- Use `compute()` for expensive CPU-bound work such as large JSON parsing.
- Use `const` constructors whenever possible.
- Do not perform network calls or expensive computation inside `build()`.


### State Management
- **Dependency Injection:** Use simple manual constructor dependency injection
  to make a class's dependencies explicit in its API, and to manage dependencies
  between different layers of the application.
- **Built-in Solutions:** Prefer Flutter's built-in state management solutions.
  Do not use a third-party package unless explicitly requested.
- **Streams:** Use `Streams` and `StreamBuilder` for handling a sequence of
  asynchronous events.
- **Futures:** Use `Futures` and `FutureBuilder` for handling a single
  asynchronous operation that will complete in the future.
- **ValueNotifier:** Use `ValueNotifier` with `ValueListenableBuilder` for
  simple, local state that involves a single value.
  ```dart
  // Define a ValueNotifier to hold the state.
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  // Use ValueListenableBuilder to listen and rebuild.
  ValueListenableBuilder<int>(
    valueListenable: _counter,
    builder: (context, value, child) {
      return Text('Count: $value');
    },
  );
    ```

- **ChangeNotifier:** For state that is more complex or shared across multiple
  widgets, use `ChangeNotifier`. Use for simple state without asynchronous data flows.
- **ListenableBuilder:** Use `ListenableBuilder` to listen to changes from a
  `ChangeNotifier` or other `Listenable`.
- **Control (Controller Pattern):** Use `StateConsumer` (or `ControlStateConsumer` if available in UI layer) with controllers extending `AppController$Sequential<TState>` for complex asynchronous flows (fetch / mutate / batch ops). Sealed immutable state variants `ExampleState` pattern (idle / processing / failed). No third‑party state libs.
- **Controller Boundaries:** Do not inject one controller into another controller and do not read foreign controller state inside a controller. Cross-controller orchestration, platform stream subscriptions, and other lifecycle-bound listeners must live in a widget or scope with an explicit `initState`/`dispose` lifecycle.

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
      final data = await _repository.fetchData();
      setState(
        ExampleState.processing(
          data: data,
          message: '${data.length} data fetched',
        ),
      );
      onSucceeded?.call();
    },
    error: (e, st) async {
      setState(
        ExampleState.failed(
          data: state.data,
          error: e,
          stackTrace: st,
          message: 'Failed to fetch data: ${ErrorUtil.formatMessage(e)}',
        ),
      );
      onError?.call(e);
    },
    done: () async {
      setState(ExampleState.idle(data: state.data));
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


### Scope (InheritedModel) Pattern
Feature-level state is exposed to the widget tree through **Scope** widgets.
Each Scope is a `StatefulWidget` that owns a controller, listens to its changes,
and re-publishes selected slices of state via a private `InheritedModel`.
Consumers subscribe to **aspects** so they rebuild only when the slice they
depend on actually changes.

#### File layout
`lib/src/feature/<domain>/widget/<domain>_scope.dart`

#### Naming conventions
|       Entity            |          Name          |
|-------------------------|------------------------|
| Public scope widget     | `<Feature>Scope`       |
| Private state class     | `_<Feature>ScopeState` |
| Private inherited model | `_Inherited<Feature>`  |
| Aspect enum             | `_<Feature>Aspect`     |

#### Structure overview
- **`<Feature>Scope`** (public `StatefulWidget`)
   * Accepts `child` (and optionally `lazy`).
   * Exposes **static helpers** that delegate to the inherited model.
     Each helper accepts `BuildContext` + `{bool listen = true}`.
   * `of(context)` returns the controller without subscribing (aspect `none`).
   * Typed accessors (e.g. `userOf`, `stateOf`, `accountsOf`) pass the
     corresponding aspect so that consumers only rebuild for their slice.
   * Command helpers (`signIn`, `signOut`, …) delegate directly to the
     controller — no aspect needed.

- **`_<Feature>ScopeState`**
   * Creates / disposes the controller.
   * Listens via `_onStateChanged`: diff previous vs next state, call
     `setState` only when something actually changed.
   * Caches the last known state for `identical` checks.

- **`_<Feature>Aspect`** (private enum)
   * `none` — read-only, no rebuild subscription.
   * One value per logical slice (e.g. `state`, `user`, `accounts`, `id`…).

- **`_Inherited<Feature>`** (`InheritedModel<_<Feature>Aspect>`)
   * Stores the full state object + scope reference.
   * Exposes computed getters for convenience (e.g. `User get user`).
   * `maybeOf` / `of` use exhaustive `switch` on aspect:
     - `none` → `getInheritedWidgetOfExactType` (no subscription).
     - Full state → `dependOnInheritedWidgetOfExactType`.
     - Specific slice → `InheritedModel.inheritFrom(context, aspect: …)`.
   * `_notFoundInheritedWidgetOfExactType()` → throws `ArgumentError`
     with `'out_of_scope'`.
   * `updateShouldNotify` — coarse check (any visible field changed).
   * `updateShouldNotifyDependent` — fine-grained per-aspect check using
     `switch` with `when` guards and `identical` / `==` /
     `DeepCollectionEquality`.

#### Template
```dart
import 'package:flutter/widgets.dart';

// ---- 1. Aspect enum ---- //

enum _ExampleAspect {
  /// Do not notify about changes.
  none,

  /// Overall state has changed.
  state,

  /// Items list has changed.
  items,
}

// ---- 2. Public Scope widget ---- //

/// {@template example_scope}
/// ExampleScope widget.
/// {@endtemplate}
class ExampleScope extends StatefulWidget {
  /// {@macro example_scope}
  const ExampleScope({required this.child, super.key});

  /// The widget below this widget in the tree.
  final Widget child;

  /// Get the [ExampleController] without subscribing to changes.
  static ExampleController of(BuildContext context) =>
      _InheritedExample.of(context).scope._controller;

  /// Get the current [ExampleState], optionally subscribing.
  static ExampleState stateOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _InheritedExample.of(
        context,
        aspect: listen ? _ExampleAspect.state : _ExampleAspect.none,
      ).state;

  /// Get items, optionally subscribing.
  static List<Item> itemsOf(
    BuildContext context, {
    bool listen = true,
  }) =>
      _InheritedExample.of(
        context,
        aspect: listen ? _ExampleAspect.items : _ExampleAspect.none,
      ).items;

  /// Command: fetch items (no subscription needed).
  static Future<void> fetchItems(BuildContext context) =>
      of(context).fetchItems();

  @override
  State<ExampleScope> createState() => _ExampleScopeState();
}

// ---- 3. Private State ---- //

class _ExampleScopeState extends State<ExampleScope> {
  late final ExampleController _controller;
  late ExampleState _state;

  @override
  void initState() {
    super.initState();
    _controller = ExampleController(/* inject deps */)
      ..addListener(_onStateChanged);
    _state = _controller.state;
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStateChanged)
      ..dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    final next = _controller.state;
    if (identical(_state, next)) return;
    _state = next;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => _InheritedExample(
    scope: this,
    state: _state,
    child: widget.child,
  );
}

// ---- 4. Private InheritedModel ---- //

class _InheritedExample extends InheritedModel<_ExampleAspect> {
  const _InheritedExample({
    required this.state,
    required this.scope,
    required super.child,
  });

  final ExampleState state;
  final _ExampleScopeState scope;

  List<Item> get items => state.items ?? const <Item>[];

  // -- Lookup helpers -- //

  static _InheritedExample? maybeOf(
    BuildContext context, {
    _ExampleAspect aspect = _ExampleAspect.none,
  }) =>
      switch (aspect) {
        // Do not notify about changes.
        _ExampleAspect.none =>
          context.getInheritedWidgetOfExactType<_InheritedExample>(),

        // Notify about every change.
        _ExampleAspect.state =>
          context.dependOnInheritedWidgetOfExactType<_InheritedExample>(),

        // Notify only when items change.
        _ExampleAspect.items => InheritedModel.inheritFrom<_InheritedExample>(
          context,
          aspect: _ExampleAspect.items,
        ),
      };

  static Never _notFoundInheritedWidgetOfExactType() =>
      throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a _InheritedExample of the exact type',
        'out_of_scope',
      );

  static _InheritedExample of(
    BuildContext context, {
    _ExampleAspect aspect = _ExampleAspect.none,
  }) =>
      maybeOf(context, aspect: aspect) ??
      _notFoundInheritedWidgetOfExactType();

  // -- Notification logic -- //

  @override
  bool updateShouldNotify(covariant _InheritedExample oldWidget) =>
      !identical(oldWidget.state, state);

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedExample oldWidget,
    Set<_ExampleAspect> dependencies,
  ) {
    for (final d in dependencies) {
      switch (d) {
        case _ExampleAspect.items
            when !identical(oldWidget.items, items):
          return true;
        case _ExampleAspect.state
            when !identical(oldWidget.state, state):
          return true;
        default:
          continue;
      }
    }
    return false;
  }
}
```

#### Rules
- **One scope per feature**. Cross-feature data flows through constructor DI or
  a shared `Dependencies` object, never by nesting scopes inside each other's
  `build`.
- **`none` aspect** always uses `getInheritedWidgetOfExactType` (read-only,
  zero rebuild cost). Use it for commands and writes.
- **`state` aspect** maps to `dependOnInheritedWidgetOfExactType` (rebuilds on
  any change). Use only when the consumer truly needs the entire state.
- **Named aspects** map to `InheritedModel.inheritFrom` with the corresponding
  enum value. `updateShouldNotifyDependent` decides per-aspect via `switch` +
  `when` guards.
- **`identical`** for reference-equal checks on lists / objects cached in the
  controller state. Use `==` or `DeepCollectionEquality` only when the
  controller may produce structurally-equal but referentially-different objects.
- **State `==` / `hashCode` contract**: use the same comparison semantics in
  both methods. Examples:
  `listEquals(items, other.items)` -> `Object.hashAll(items)`;
  `mapEquals(meta, other.meta)` -> order-independent entry hashing;
  `identical(data, other.data)` -> hash the `data` object itself, not its deep contents.
- **State messages are usually diagnostic, not identity**. If `message` does
  not participate in `==`, it must not participate in `hashCode` either.
- **Do not mix shallow and deep semantics for the same field**. A state that
  compares a list by contents and hashes it by object identity has a broken
  contract and can cause missed rebuilds or unstable cache/set behavior.
- **`_notFoundInheritedWidgetOfExactType`** throws `ArgumentError` with
  `'out_of_scope'` — consistent across all scopes.
- **`_onStateChanged`** must guard `if (!mounted) return;` and skip
  `setState` when the state is `identical`.
- Static helpers follow the pattern:
  `static T fooOf(BuildContext context, {bool listen = true})` where
  `listen: false` passes `_Aspect.none` and `listen: true` passes the
  matching aspect.

### Routing
- **AppNavigator:** Use the app-owned `AppNavigator` and typed `AppPage`
  classes for app page navigation. Keep app page definitions in
  `lib/src/common/router/app_pages.dart`.
- **Feature navigation:** Use `context.ext.pushPage`, `context.ext.pushPage`,
  `context.ext.replacePage`, `context.ext.replaceWithAnimation`,
  `context.ext.resetPages`, and `context.ext.pop` for app-owned pages.
- **Nested flows:** Host nested app flows with `AppNavigator.controlled(...)` and
  a local `ValueNotifier<AppNavigationState>` controller. Do not write internal
  nested steps into the root app stack.
- **Root stack:** Pass `rootNavigator: true` only when the action must target the
  furthest app-owned stack.

  ```dart
  context.ext.pushPage(SaleCardPage(id: sale.id.toString()));
  context.ext.replaceWithAnimation(SaleCardPage(id: sale.id.toString()));
  context.ext.pop(rootNavigator: true);
  ```
- **Authentication Redirects:** Configured intro `AuthenticationScope` widget to
  handle authentication flows, ensuring users are redirected to the login screen
  when unauthorized, and back to their intended destination after successful
  login.

- **Flutter Navigator:** Use the built-in `Navigator` for local Flutter-owned
  surfaces that are not app pages, such as dialogs, bottom sheets, action
  sheets, and temporary `MaterialPageRoute` flows.

  ```dart
  Navigator.of(context, rootNavigator: true).pop<void>();
  ```
### Theming

- **Centralized Theme:** Define a centralized `ThemeData` object to ensure a
  consistent application-wide style.
- **Light and Dark Themes:** Implement support for both light and dark themes,
  ideal for a user-facing theme toggle (`ThemeMode.light`, `ThemeMode.dark`,
  `ThemeMode.system`).
- **Color Scheme Generation:** Generate harmonious color palettes from a single
  color using `ColorScheme.fromSeed`.
- **Color Palette:** Include a wide range of color concentrations and hues in
  the palette to create a vibrant and energetic look and feel.
- **Component Themes:** Use specific theme properties (e.g., `appBarTheme`,
  `elevatedButtonTheme`) to customize the appearance of individual Material
  components.
- **Custom Fonts:** For custom fonts, use the `google_fonts` package. Define a
  `TextTheme` to apply fonts consistently.

### Assets and images

- **Image Guidelines:** If images are needed, make them relevant and meaningful,
  with appropriate size, layout, and licensing. Provide placeholder images if
  real ones are not available.
- **Asset Declaration:** Declare all asset paths in your `pubspec.yaml` file.
- **Local Images:** Use `Image.asset` for local images from your asset bundle.
- **Network images:** Use `NetworkImage` for images loaded from the network.
- **Cached images:** For cached images, use a package like `cached_network_image`.
- **Custom Icons:** Use `ImageIcon` to display an icon from an `ImageProvider`,
  useful for custom icons not in the `Icons` class.
- **Network Images:** Use `Image.network` to display images from a URL, and
  always include `loadingBuilder` and `errorBuilder` for a better user experience.

### UI theming and styling code

- **Responsiveness:** Use `LayoutBuilder` or `MediaQuery` to create responsive UIs.
- **Text:** Use `Theme.of(context).textTheme` for text styles.
- **UI Theme:** Use `Theme.of(context).uiTheme` for UI kit theme styles.

## Material Theming Best Practices

### Embrace `ThemeData` and Material 3
- **Use `ColorScheme.fromSeed()`:** Use this to generate a complete, harmonious
  color palette for both light and dark modes from a single seed color.
- **Define Light and Dark Themes:** Provide both `theme` and `darkTheme` to your
  `MaterialApp` to support system brightness settings seamlessly.
- **Centralize Component Styles:** Customize specific component themes (e.g.,
  `elevatedButtonTheme`, `cardTheme`, `appBarTheme`) within `ThemeData` to
  ensure consistency.
- **Dark/Light Mode and Theme Toggle:** Implement support for both light and
  dark themes using `theme` and `darkTheme` properties of `MaterialApp`. The
  `themeMode` property can be dynamically controlled (e.g., via a
  `ChangeNotifierProvider`) to allow for toggling between `ThemeMode.light`,
  `ThemeMode.dark`, or `ThemeMode.system`.
- **Typography:** Define a `TextTheme` within `ThemeData` to standardize font
	styles across the app.
- **UI Theme:** Define a `UITheme` within `ThemeData` to standardize UI styles
	across the app.

```dart
// main.dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.bold),
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.green; // Color when pressed
      }
      return Colors.red; // Default color
    },
  ),
);
```


## Layout best practices

### Building flexible and overflow-safe layouts

#### For Rows and Columns
- **`Expanded`:** Fill remaining available space along the main axis.
- **`Flexible`:** Shrink to fit, but not necessarily grow. Don't combine
  `Flexible` and `Expanded` in the same `Row` or `Column`.
- **`Wrap`:** When widgets would overflow a `Row` or `Column`, move them to
  the next line.

#### For general content
- **`SingleChildScrollView`:** Content intrinsically larger than the viewport
  but of fixed size.
- **`ListView` / `GridView`:** For long lists/grids, always use a builder
  constructor (`.builder`).
- **`FittedBox`:** Scale or fit a single child widget within its parent.
- **`LayoutBuilder`:** Complex, responsive layouts based on available space.

### Layering widgets with Stack
- **`Positioned`:** Precisely place a child within a `Stack` by anchoring to edges.
- **`Align`:** Position a child using alignments like `Alignment.center`.

### Advanced layout with overlays
- **`OverlayPortal`:** Show UI elements (like custom dropdowns or tooltips)
  "on top" of everything else.
  Example:
  ```dart
  class MyDropdown extends StatefulWidget {
    const MyDropdown({super.key});

    @override
    State<MyDropdown> createState() => _MyDropdownState();
  }

  class _MyDropdownState extends State<MyDropdown> {
    final _controller = OverlayPortalController();

    @override
    Widget build(BuildContext context) {
      return OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (BuildContext context) {
          return const Positioned(
            top: 50,
            left: 10,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('I am an overlay!'),
              ),
            ),
          );
        },
        child: ElevatedButton(
          onPressed: _controller.toggle,
          child: const Text('Toggle Overlay'),
        ),
      );
    }
  }
  ```


## Color scheme best practices

### Contrast ratios
- **WCAG Guidelines:** Meet WCAG 2.1 standards.
- **Minimum Contrast:**
  - **Normal Text:** At least **4.5:1**.
  - **Large Text:** (18pt or 14pt bold) At least **3:1**.

### Palette selection
- **Primary, Secondary, and Accent:** Define a clear color hierarchy.
- **The 60-30-10 Rule:**
  - **60%** Primary/Neutral Color (Dominant)
  - **30%** Secondary Color
  - **10%** Accent Color

### Complementary colors
- Use with caution — excellent for accent colors, poor for text/background pairings.


## Font best practices

### Font selection
- **Limit Font Families:** Stick to one or two font families.
- **Prioritize Legibility:** Sans-serif fonts are generally preferred for UI body text.
- **System Fonts:** Consider platform-native system fonts.
- **Google Fonts:** For variety, use the `google_fonts` package.

### Hierarchy and scale
- Establish a set of font sizes for different text elements.
- Use font weight to differentiate text effectively.
- Use color and opacity to de-emphasize less important text.

### Readability
- **Line Height (Leading):** Typically **1.4x to 1.6x** the font size.
- **Line Length:** For body text, aim for **45-75 characters**.
- **Avoid All Caps:** Do not use all caps for long-form text.


## Documentation
- **`dartdoc`:** Write `dartdoc`-style comments for all public APIs.

### Documentation philosophy
- **Comment wisely:** Explain *why* the code is written a certain way, not
  *what* the code does. The code itself should be self-explanatory.
- **Document for the user:** Write documentation with the reader in mind.
- **No useless documentation:** If it only restates the obvious from the code's
  name, it's not helpful.
- **Consistency is key:** Use consistent terminology throughout.

### Commenting style
- **Use `///` for doc comments.**
- **Start with a single-sentence summary** ending with a period.
- **Separate the summary:** Add a blank line after the first sentence.
- **Avoid redundancy:** Don't repeat information obvious from the code's context.
- **Don't document both getter and setter** — document one; tools treat them as a single field.
- **Important:** Don't delete comments, but feel free to add more if it would
  help the reader understand the code better.

### Writing style
- **Be brief.**
- **Avoid jargon and acronyms** unless widely understood.
- **Use Markdown sparingly** — never use HTML for formatting.
- **Use backticks for code** — enclose code blocks in backtick fences with language.

### What to document
- **Public APIs are a priority.**
- **Consider private APIs** — it's a good idea to document them as well.
- **Library-level comments are helpful** — provide a general overview.
- **Include code samples** where appropriate.
- **Explain parameters, return values, and exceptions** in prose.
- **Place doc comments before annotations.**


## Accessibility (A11Y)
Implement accessibility features to empower all users:

- **Color Contrast:** Text contrast ratio of at least **4.5:1** against its background.
- **Dynamic Text Scaling:** Ensure usability when users increase system font size.
- **Semantic Labels:** Use the `Semantics` widget for clear, descriptive labels.
- **Screen Reader Testing:** Test with TalkBack (Android) and VoiceOver (iOS).


## High-Performance Canvas Rendering
Guidelines based on [plugfox.dev/high-performance-canvas-rendering](https://plugfox.dev/high-performance-canvas-rendering/).
Apply these rules when writing `CustomPainter`, custom `RenderObject`, or any code that draws directly on `Canvas`.

### Choosing the Rendering Strategy
| Approach                                        | When to Use                                           |
|-------------------------------------------------|-------------------------------------------------------|
| `CustomPaint` + `CustomPainter`                 | Simple-to-moderate complexity, few repaints           |
| `LeafRenderObjectWidget` + custom `RenderBox`   | Complex scenes, precise lifecycle control, game loops |
| `repaint` package (`RePaint` / `RePainterBase`) | Optimised fine-grained repaint logic                  |

- For most calendar / event painting tasks, `CustomPainter` with a `repaint` listenable is sufficient.
- Promote to `LeafRenderObjectWidget` when you need vsync tickers, pointer-event forwarding, or per-frame updates.

### Repaint Strategy
- **Never** wrap `CustomPaint` inside `AnimatedBuilder`, `BlocBuilder`, `ValueListenableBuilder`, or any builder solely to trigger repaints.
- **Never** call `setState()` to repaint a painter — this causes a full widget rebuild.
- **Always** pass a `Listenable` (e.g. `ChangeNotifier`, `ValueNotifier`, `AnimationController`) via the `repaint` parameter of `CustomPainter`:
  ```dart
  CustomPaint(
    painter: MyPainter(repaint: myNotifier),
  );
  ```
- For custom `RenderObject`s, call `markNeedsPaint()` directly after state mutations instead of triggering widget rebuilds.
- Use `RepaintBoundary` (or `isRepaintBoundary => true` in `RenderBox`) to isolate frequently-updated canvases from the surrounding widget tree. Measure before committing — it trades memory for fewer repaints.

### Clipping
- **Always** `canvas.save()` before clipping and `canvas.restore()` after. Never leave unbalanced save/restore pairs.
- Clip the full content area to prevent overflow:
  ```dart
  canvas
    ..save()
    ..clipRRect(rrect); // or clipRect / clipPath
  // … all drawing …
  canvas.restore();
  ```
- Prefer `clipRect` over `clipRRect` / `clipPath` when corners are not rounded — it is cheaper on the GPU.

### Paint Object Management
- **Reuse** `Paint` objects. Create them as fields or `static final` constants instead of allocating inside `paint()` on every frame.
- Configure `isAntiAlias`, `filterQuality`, and `style` once — only mutate `color` / `shader` per draw call.
- For pixel-art or grid-aligned rendering, disable anti-aliasing:
  ```dart
  final gridPaint = Paint()
    ..isAntiAlias = false
    ..filterQuality = FilterQuality.none
    ..style = PaintingStyle.fill;
  ```

### Avoid Drawing Loops
- **Do not** call `drawRect`, `drawCircle`, `drawImageRect`, etc. in a loop for large numbers of primitives.
- **Batch** operations instead:
  | Method                 | Use Case                                |
  |------------------------|-----------------------------------------|
  | `canvas.drawRawAtlas`  | Multiple sprites from one texture atlas |
  | `canvas.drawRawPoints` | Large point / particle sets             |
  | `canvas.drawVertices`  | Mesh-based rendering                    |
- When batching is not applicable (e.g. heterogeneous shapes), minimise loop iterations and keep the body lightweight.

### Picture Caching
- Cache static or infrequently-changing content with `PictureRecorder`:
  ```dart
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, rect);
  // … expensive drawing …
  final picture = recorder.endRecording();
  ```
- Reuse the recorded `Picture` via `canvas.drawPicture(picture)` until the content is invalidated.
- For fully static assets, convert to a raster image with `picture.toImage(w, h)` and draw via `canvas.drawImageRect`.
- **Invalidate** cached pictures/images only on actual data changes (size, zoom, content). Use a dirty flag (`_needsRepicture`) and guard regeneration.

### Composable Painters
For complex scenes, split rendering into focused painter classes:
```dart
abstract class ScenePainter {
  bool get needsPaint;
  void update(ui.Size size, double delta);
  void paint(ui.Size size, Canvas canvas);
}
```
- Each painter owns its own `_needsRelayout` / `_needsPaint` flags.
- The orchestrator checks `painters.any((p) => p.needsPaint)` — only then calls `markNeedsPaint()`.
- Paint in explicit layer order (background → content → overlays → debug).

### Coordinate Snapping
- Snap coordinates to physical pixels to avoid sub-pixel blur:
  ```dart
  double snapPx(double v, double dpr) => (v * dpr).roundToDouble() / dpr;
  ```
- Obtain DPR via `MediaQuery.devicePixelRatioOf(context)` once and pass it to the painter.

### Spatial Queries (QuadTree)
- For scenes with > ~100 interactive objects, use a `QuadTree` for hit-testing, collision detection, and viewport culling.
- Inflate the viewport rect slightly (`camera.bound.inflate(32)`) when querying to prevent pop-in artefacts.
- **Cheap-first** collision: check bounding-box overlap before detailed path intersection.

### Camera / Viewport Pattern
- Use a `Camera` class (`ChangeNotifier`) exposing `globalToLocal` / `localToGlobal` transforms.
- On every paint call: `camera.changeSize(size)`, then transform all global coords to local before drawing.
- Mark `@pragma('vm:prefer-inline')` on hot conversion methods.

### `shouldRepaint` / `shouldRebuildSemantics`
- Implement `shouldRepaint` conservatively: compare **only** fields that affect visual output.
- Use `identical` for reference-equal checks on lists / images; use `==` for primitives.
- If the painter uses `repaint` listenable, `shouldRepaint` can safely return `false` for most cases.

### TextPainter in Canvas
- Create `TextPainter`, call `layout(maxWidth:)`, then `paint(canvas, offset)`.
- **Do not** call `layout()` more than once per frame with the same constraints.
- Guard rendering with a bounds check before painting:
  ```dart
  if (y + tp.height <= contentRect.bottom) {
    tp.paint(canvas, Offset(x, y));
  }
  ```

### Image Rendering on Canvas
- Prefer `canvas.drawImageRect(image, src, dst, paint)` over `canvas.drawImage` — it handles scaling and is more explicit.
- When drawing circular avatars, `clipPath` + `drawImageRect` inside a `save/restore` block.
- Set `filterQuality: FilterQuality.medium` for scaled photos; use `FilterQuality.none` for pixel-art / unscaled textures.

### Debugging Canvas
- Build a toggleable debug overlay (activated via hotkey or flag) showing:
  - FPS / paint count
  - Camera viewport bounds
  - QuadTree node visualisation
  - Grid overlay for alignment
- Use `PaintingContext.addLayer(PerformanceOverlayLayer(...))` for built-in Flutter perf metrics.
- Guard all debug drawing behind `kDebugMode` or a runtime flag so it is stripped from release builds.

### General Rules
- **No `dynamic`** in painter code — all types explicit.
- **No `print()`** — use `dev.log()` behind `kDebugMode` guard.
- **No async work** inside `paint()` — all data must be pre-resolved and passed in.
- Keep `paint()` body under ~80 lines. Extract helpers (`_paintHeader`, `_paintAvatars`, `_paintGrid`, etc.).
- Measure with `flutter run --profile` and DevTools timeline before and after optimisations.

### SVG → Flutter LeafRenderObject Icons
Icons from SVG are implemented uniformly for predictability, simple diffs, and absence of hidden optimizations.

- **Widget Structure:** One public widget: LeafRenderObjectWidget + PreferredSizeWidget (parameters: size, Color? color, double opacity).
- **RenderObject State:** Stores only _targetSize, _scale, _color, _opacity. Update via setters with `markNeedsLayout` / `markNeedsPaint` when needed.
- **Layout:** computeDryLayout -> `constraints.constrain(_targetSize)`; in performLayout compute `_scale = min(size.width/24, size.height/24)`.
- **Painting Sequence:** Center (translate to middle), then scale, then build picture inside `paint` via `ui.PictureRecorder`; immediately obtain `picture` and `canvas.drawPicture(picture)`.
- **Path Definitions:** All paths static: `static final Path path_0`, `path_1`, ... no intermediate local paths.
- **Picture Naming:** Picture builder function by icon name: `UIIcon$Example -> _$examplePicture(Canvas canvas, Color color, double opacity)`.
- **Multiple Layers:** If multiple layers/opacities — draw sequentially inside the build function.
- **Parameters Only:** ONLY size, color, opacity supported. No alignment/fit/contentScale.
- **No Caching:** Do not cache picture / dynamic path calculations; static paths allowed, picture recreated every paint.
- **Prohibited:** imports inside snippet, comments, fixed viewBox, extra state fields, external optimizations.

### LeafRenderObject Icon Template
```dart
import 'dart:math' as math;
import 'dart:ui' as ui hide Size;

import 'package:flutter/material.dart';
import 'package:ui/src/theme/theme.dart';

/// {@template icon_example}
/// Example icon widget.
/// {@endtemplate}
class UIIcon$Example extends LeafRenderObjectWidget implements PreferredSizeWidget {
  /// {@macro icon_example}
  const UIIcon$Example({this.color, this.size = 24, this.opacity = 1.0, super.key});

  /// The size of the icon.
  final double size;

  /// The opacity of the icon.
  final double opacity;

  /// The color of the icon.
  final Color? color;

  @override
  Size get preferredSize => Size.square(size);

  @override
  RenderObject createRenderObject(BuildContext context) => _UIIcon$Example$RenderObject()
    .._isDark = Theme.of(context).brightness == Brightness.dark
    .._targetSize = Size.square(size)
    .._opacity = opacity;

  @override
  void updateRenderObject(BuildContext context, covariant _UIIcon$Example$RenderObject renderObject) {
    final newSize = Size.square(size);
    if (renderObject case _UIIcon$Example$RenderObject object when object._targetSize != newSize) {
      object
        .._targetSize = newSize
        ..markNeedsLayout();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (renderObject case _UIIcon$Example$RenderObject object when object._isDark != isDark) {
      object
        .._isDark = isDark
        ..markNeedsPaint();
    }
    if (renderObject case _UIIcon$Example$RenderObject object when object.color != color) {
      object
        .._color = color
        ..markNeedsPaint();
    }
    if (renderObject case _UIIcon$Example$RenderObject object when object._opacity != opacity) {
      object
        .._opacity = opacity
        ..markNeedsPaint();
    }
  }
}

class _UIIcon$Example$RenderObject extends RenderBox {
  Size _targetSize = Size.zero;
  Color _color = kAccentColor;
  double _opacity = 1.0;
  bool _isDark = false;
  double _scale = .0;

  @override
  bool get alwaysNeedsCompositing => false;

  @override
  bool get isRepaintBoundary => false;

  @override
  bool get sizedByParent => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(_targetSize);

  @override
  void performLayout() {
    final size = super.size = computeDryLayout(constraints);
    _scale = math.min(size.width / 24.0, size.height / 24.0);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_scale < .01) return;
    final canvas = context.canvas..save();
    final sideScaled = 24.0 * _scale;
    canvas
      ..translate(offset.dx + (size.width - sideScaled) / 2, offset.dy + (size.height - sideScaled) / 2)
      ..scale(_scale, _scale);
    final pic = _$examplePicture(_opacity);
    canvas
      ..drawPicture(pic)
      ..restore();
    pic.dispose();
  }

  static ui.Picture _$examplePicture(Color color, double opacity) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    canvas
      ..drawPath(path_1, paint..color = color.withValues(alpha: 1 * opacity))
      ..drawPath(path_0, paint..color = color.withValues(alpha: 0.5 * opacity));
    return recorder.endRecording();
  }

  static final Path path_1 = Path()
    ..moveTo(20.25, 7.35156)
    ..lineTo(17.5, 7.35156)
    ..cubicTo(17.5, 5.89287, 16.9205, 4.49393, 15.8891, 3.46248)
    ..cubicTo(14.8576, 2.43103, 13.4587, 1.85156, 12, 1.85156)
    ..cubicTo(10.5413, 1.85156, 9.14236, 2.43103, 8.11091, 3.46248)
    ..cubicTo(7.07946, 4.49393, 6.5, 5.89287, 6.5, 7.35156)
    ..lineTo(3.75, 7.35156)
    ..cubicTo(3.02065, 7.35156, 2.32118, 7.64129, 1.80546, 8.15702)
    ..cubicTo(1.28973, 8.67274, 1, 9.37222, 1, 10.1016)
    ..lineTo(1, 19.2682)
    ..cubicTo(1.00146, 20.4834, 1.48481, 21.6483, 2.34403, 22.5075)
    ..cubicTo(3.20326, 23.3668, 4.3682, 23.8501, 5.58333, 23.8516)
    ..lineTo(16.2955, 23.8516)
    ..cubicTo(15.6582, 23.4373, 15.1137, 22.8955, 14.6964, 22.2603)
    ..cubicTo(14.279, 21.6251, 13.9979, 20.9103, 13.8706, 20.1609)
    ..cubicTo(13.7434, 19.4116, 13.7728, 18.644, 13.9571, 17.9066)
    ..cubicTo(14.1414, 17.1693, 14.4765, 16.4781, 14.9413, 15.8767)
    ..cubicTo(15.4061, 15.2753, 15.9905, 14.7768, 16.6576, 14.4126)
    ..cubicTo(17.3247, 14.0485, 18.0601, 13.8265, 18.8173, 13.7608)
    ..cubicTo(19.5745, 13.695, 20.3372, 13.787, 21.0571, 14.0307)
    ..cubicTo(21.777, 14.2745, 22.4385, 14.6649, 23, 15.1771)
    ..lineTo(23, 10.1016)
    ..cubicTo(23, 9.37222, 22.7103, 8.67274, 22.1945, 8.15702)
    ..cubicTo(21.6788, 7.64129, 20.9793, 7.35156, 20.25, 7.35156)
    ..close()
    ..moveTo(8.33333, 7.35156)
    ..cubicTo(8.33333, 6.3791, 8.71964, 5.44647, 9.40728, 4.75884)
    ..cubicTo(10.0949, 4.0712, 11.0275, 3.6849, 12, 3.6849)
    ..cubicTo(12.9725, 3.6849, 13.9051, 4.0712, 14.5927, 4.75884)
    ..cubicTo(15.2804, 5.44647, 15.6667, 6.3791, 15.6667, 7.35156)
    ..lineTo(8.33333, 7.35156)
    ..close();

  static final Path path_0 = Path()
    ..moveTo(22.0827, 18.3516)
    ..lineTo(20.2493, 18.3516)
    ..lineTo(20.2493, 16.5182)
    ..cubicTo(20.2493, 16.2751, 20.1528, 16.042, 19.9809, 15.87)
    ..cubicTo(19.8089, 15.6981, 19.5758, 15.6016, 19.3327, 15.6016)
    ..cubicTo(19.0896, 15.6016, 18.8564, 15.6981, 18.6845, 15.87)
    ..cubicTo(18.5126, 16.042, 18.416, 16.2751, 18.416, 16.5182)
    ..lineTo(18.416, 18.3516)
    ..lineTo(16.5827, 18.3516)
    ..cubicTo(16.3396, 18.3516, 16.1064, 18.4481, 15.9345, 18.62)
    ..cubicTo(15.7626, 18.7919, 15.666, 19.0251, 15.666, 19.2682)
    ..cubicTo(15.666, 19.5113, 15.7626, 19.7445, 15.9345, 19.9164)
    ..cubicTo(16.1064, 20.0883, 16.3396, 20.1849, 16.5827, 20.1849)
    ..lineTo(18.416, 20.1849)
    ..lineTo(18.416, 22.0182)
    ..cubicTo(18.416, 22.2613, 18.5126, 22.4945, 18.6845, 22.6664)
    ..cubicTo(18.8564, 22.8383, 19.0896, 22.9349, 19.3327, 22.9349)
    ..cubicTo(19.5758, 22.9349, 19.8089, 22.8383, 19.9809, 22.6664)
    ..cubicTo(20.1528, 22.4945, 20.2493, 22.2613, 20.2493, 22.0182)
    ..lineTo(20.2493, 20.1849)
    ..lineTo(22.0827, 20.1849)
    ..cubicTo(22.3258, 20.1849, 22.5589, 20.0883, 22.7309, 19.9164)
    ..cubicTo(22.9028, 19.7445, 22.9993, 19.5113, 22.9993, 19.2682)
    ..cubicTo(22.9993, 19.0251, 22.9028, 18.7919, 22.7309, 18.62)
    ..cubicTo(22.5589, 18.4481, 22.3258, 18.3516, 22.0827, 18.3516)
    ..close();
}
```