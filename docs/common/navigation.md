# Navigation

The router is ported from Tetradka's shared router and lives in `lib/src/common/router/`.
It uses Flutter's declarative `Navigator.pages` API. No separate core package is required.

## Ownership

Import `package:flutter_template_name/src/common/router/router.dart` for reusable mechanics:

- `AppNavigator`, `AppNavigatorState`, and `AppNavigationState` manage page stacks.
- `AppPage`, `AppPage$Fade`, and `AppPage$SlideFromBottom` provide extensible presentations.
- `IRouteParser<P>`, `RouteParseResult<P>`, and `RouteParseFailure` define typed parsing contracts.
- `TransitionsBuilder` provides fade, rotation, and bottom-slide transitions.

The reusable layer does not import screens, dependencies, analytics, or `package:ui`.
Application adapters stay separate:

- `app_pages.dart` defines the template's home, sign-up, developer, and developer-info pages.
- `app_route_parser.dart` owns accepted route strings and app-facing result aliases.
- `app_page_sheet.dart` adapts `UISheetRoute` without changing the template's sheet content.
- `app_navigator_observer.dart` preserves existing page-view names and push-only analytics behavior.

Feature-owned pages can extend a shared presentation with a `final`, `base`, or `sealed` class.
Keep internal flow pages in their feature rather than adding them to the app-wide page table.

## Stacks and guards

Use `AppNavigator.controlled(controller: ...)` when a `ValueNotifier<AppNavigationState>` owns the stack.
Use `AppNavigator(pages: ...)` for a stack owned by the widget state.
Both require at least one initial page. Dispose external controllers in their owner.

Guards run for controller updates, programmatic changes, dependency changes, and the optional `revalidate` signal.
Guarded empty stacks are rejected. Duplicate page keys retain only their last occurrence.
Treat `state` as read-only; mutate the copy supplied to `change` instead.
Replacing the controller or revalidation signal detaches the old listener.

From a descendant context, use `AppNavigator.push`, `change`, `reset`, `removeFrom`, or `replaceWithAnimation`.
The existing app facade is `context.ext.navigator.push`, `replace`, `reset`, `replaceWithAnimation`, and `pop`.
`reset` on `AppNavigator` restores pages supplied by its current widget; the facade's `reset(pages)` accepts a new stack.
`removeFrom` removes the matched page and everything above it, but never the root.
A delayed replacement is discarded when the navigator is disposed.

## Back and nested flows

Nested flows use their own `AppNavigator` and controller. Lookup defaults to the nearest app navigator;
pass `rootNavigator: true` only to explicitly target the root stack.
Local dialogs and selections can continue to use Flutter's `Navigator`.

System back uses `WidgetsBindingObserver.didPopRoute`. A single-page stack returns `false`, allowing the next observer
or platform to handle back. A custom `onBackButtonPressed` handler can return an updated stack and a handled flag.
For nested flows, define which navigator owns system back: a parent can keep its stack and return `handled: false`
while the child has internal pages, then close the host after the child reaches its root.
Nearest-context lookup does not automatically change the order of platform back observers.

Material pages use Flutter's stock platform transitions. Overlay pages preserve `opaque`, `barrierColor`, and
`fullscreenDialog` while retaining Material or Cupertino transitions, including Cupertino secondary animation.
Fade and slide pages expose their duration and fullscreen-dialog setting.

## Route parsing and platform limits

`AppRouteParser.parse('/developer')` returns `DeveloperPage`. Other strings return `unsupportedRoute`.
The existing table is deliberately unchanged; home, sign-up, and developer-info remain reachable through typed pages.
Use `result.pageOrNull` or pattern matching to handle success. The shared failure kinds also allow feature parsers
to report malformed parameters or required preloaded data. Parsing never changes the stack by itself.

The base `AppPage` no longer depends on an application parser. Use `AppRouteParser.parse(route)` instead of the old
`AppPage.fromRoute` helper. Imports of concrete pages and analytics observers must now be explicit.

This port does not add browser URL synchronization, browser history, incoming deep-link dispatch, or stack restoration.
Page `path` metadata and a parser alone do not implement those integrations.

## Validation

`test/src/widget_test/src/common/router/` covers shared behavior and the template's route table.
These tests are included in `make test-unit-all`; they can also run directly with `flutter test` on VM and Chrome.
