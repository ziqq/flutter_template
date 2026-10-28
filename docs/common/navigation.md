# Navigation

The application uses `squid` directly from pub.dev. `NavigationController` owns the stack and `NavigationView`
renders it through Flutter's declarative `Navigator.pages` API. `context.ext.navigator` provides context actions with
preference-aware haptics; it forwards changes to Squid and owns no stack or notifier.

## Ownership

- `Dependencies.navigator` owns the root `NavigationController`, initialized with `HomePage`.
- `App` renders that controller with a `NavigationView` and the existing Flutter observers.
- `AuthenticationScope` renders a separate guest flow while the user is unauthenticated. Its private widget owns a
  controller initialized with the sign-in page and disposes it when the guest flow unmounts. Sign-up stays in this
  local stack; signing in removes it, and signing out creates a fresh sign-in stack.
- Other nested flows own and dispose their own controller. A view does not dispose an externally owned controller.
  Root controller cleanup belongs to application teardown after the widget tree unmounts.

Use `context.ext.navigator` for `navigate`, `push`, `replace`, `replaceWithAnimation`, `reset`, and `pop`.
These actions trigger heavy haptic feedback when enabled in settings; callers do not add a separate haptic call.
They use the nearest view, falling back to the application controller when no view is above the context.
`pop` and `replaceWithAnimation` accept `rootNavigator: true` to target the application controller explicitly.
Use `NavigationView.of(context)` for direct Squid operations.
Dialogs, menus, and other imperative Flutter surfaces may continue to use Flutter's `Navigator`.

```dart
context.ext.navigator.push(const DeveloperInfoPage());
context.ext.navigator.replace(const DeveloperPage());
context.ext.navigator.replaceWithAnimation(const DeveloperPage());
context.ext.navigator.pop(rootNavigator: true);
```

## Pages and presentation

Application-owned pages remain in `lib/src/common/router/`:

- `AppPage` extends `MaterialPage<void>` and implements Squid's `NavigationRoute`. Its non-null key, name, arguments,
  `build`, and `page` methods preserve the application's existing page identity and presentation.
- `AppPage$Fade`, `AppPage$SlideFromBottom`, and `AppPage$Sheet` retain their existing transition and overlay contracts.
- `app_pages.dart` contains home, sign-up, and developer destinations. Keep internal flow pages inside their feature.
- `AppNavigatorObserver` retains existing push-only analytics and page-view names.
- `IRouteParser<P>`, `RouteParseResult<P>`, and `RouteParseFailure` remain independent typed parsing contracts.

Import `common/router/router.dart` for application page and parser contracts, and `package:squid/squid.dart` for
controller and view APIs. Controllers and repositories must not discover navigation through a global registry.

## Stack and back behavior

A controller requires a nonempty initial stack. Change the copy supplied to `change`, or use `push`, `replaceTop`,
`pop`, and `stack` directly. Treat the exposed stack as read-only. Squid owns duplicate-key handling, guard validation,
revalidation, observers, queued changes, and back dispatch; the application does not maintain a second stack.

`NavigationView` dispatches system back to the deepest visible nested view before its parent. A root with one page
passes unhandled back to Flutter/platform behavior. Imperative dialogs and `PopScope` use the view's normal back
handling. `replace` forwards to Squid's `replaceTop`. `replaceWithAnimation` pops the current page, waits 350 ms by
default, then pushes its replacement. A single-page stack is replaced immediately; a disposed controller or detached
navigator discards the delayed push. `reset([])` leaves the stack unchanged.
Real predictive-back and iOS gesture behavior still require platform verification.

## Parsing and platform boundaries

`AppRouteParser.parse('/developer')` returns `DeveloperPage`; other strings return `unsupportedRoute`.
Parsing never changes the stack. Home, sign-up, and developer-info remain reachable through typed pages.

This integration does not add incoming deep-link dispatch, browser URL synchronization, browser history, or
process-death stack restoration. Page `path` metadata and parsing alone do not implement those features.
