# Testing Rules

This file contains test structure and test-writing rules.


## Test Entry Points
- App unit and widget tests: `test/unit_test.dart`, `test/widget_test.dart`
- Full app and packages suite: `make test-unit-all`
- Integration tests: `make test-integration`


## Testing Best Practices
- Follow Arrange-Act-Assert or Given-When-Then structure.
- Write unit tests for domain logic, repositories, and controller state transitions.
- Write widget tests for reusable UI behavior.
- Use integration tests for user flows across multiple layers.
- Prefer fakes and stubs over mocks.
- If mocks are necessary, keep them targeted and minimal.
- Use existing project fixtures from `MockService` for mock data.
- Use existing repository fakes or generated mocks when they exist; do not add ad-hoc fake repositories inside test files.
- Group controller and state tests by the public method, callback, or getter under test.
- Keep test data close to the case that uses it; do not collect unrelated private fixtures at the bottom of the file.
- Use small local variables inside a test when values are specific to that scenario.
- Avoid local helper builders such as `_controller`, `_state`, or `_time` when direct construction keeps the test explicit.
- Keep tests close to the feature structure they cover.
- Aim for high-value coverage, not just numeric coverage.
- Prefer the smallest publicly reachable scenario that proves a branch, callback, or invariant. Do not bend tests around private implementation details when a public call site already reaches the same logic.
- Treat coverage gaps as a routing problem first: identify whether the uncovered line belongs to public behavior, a fallback helper path, or an internal-only error branch before adding tests.
- Do not force coverage for wildcard `AssertionError()` branches or internal `error:` closures that are not reachable through the public contract; record that limit in the test file or review notes instead of adding synthetic tests that distort behavior.
- When a helper is only uncovered because of branch shape rather than meaningful behavior, prefer a tiny behavior-preserving simplification in production code over adding brittle tests that depend on private state choreography.
- If a test exercises a callback contract, assert the state visible inside the callback in addition to the final post-callback state.
- For collection-editing controllers, cover all distinct selection modes that the public API exposes: explicit editing index, fallback matching by entity id, and "no active selection" no-op paths.
- Prefer preserving previous successful payload assertions on failure over generic `isA<Failed>` checks when the controller contract restores idle state with old data.


## Controller And State Test Template
- For controller files, use `void main() { _$controllerTest(); _$stateTest(); }` when the feature exposes both a controller and a dedicated state type.
- If a controller has no standalone state type, keep `main()` and a single `_$controllerTest()` entrypoint instead of inventing an empty state block.
- Name the top-level groups after the concrete types under test, for example `FeatureController -` and `FeatureState -`.
- Keep lightweight controller invariants near the top of the controller group: controller `name`, initial state, and required seeded defaults when those values are part of the public contract.
- Inside the controller group, organize nested groups by the public API under test: constructor, public methods, callbacks, and public getters.
- When a public method exposes lifecycle callbacks, test the callback order and the state visible during each callback, not only the final state.
- When a method can append, replace, or preserve previous data, add explicit tests for those invariants instead of asserting only that "some data exists".
- On failure paths, prefer assertions that previous successful data stays intact when the controller contract preserves it.
- Inside the state group, organize nested groups by public state API: derived getters, boolean flags, and pattern-matching helpers such as `map`, `maybeMap`, and `mapOrNull`.
- Add equality, `hashCode`, or `toString` assertions only when that behavior is implemented intentionally on the state type and matters for downstream usage.
- Prefer `setUp()` to create the default controller with explicit dependencies and default stubs. Reassign the controller inside a test only when that scenario needs a materially different initial state.
- Keep fixtures close to the case that uses them. Avoid generic private builder helpers such as `_controller()`, `_state()`, or `_createController()` when direct construction keeps the scenario explicit.
- Small semantic helpers are acceptable when they encode a repeated seeded scenario rather than hide construction details, for example a `createSeededController(...)` or `createVisitNotification(...)` helper used by multiple tests in the same file.
- Prefer descriptive behavioral test names like `updates repeat frequency` or `returns true only for processing state` instead of generic `should ...` phrasing.
- Use the existing controller/state files under `calendar`, `client`, `cloud`, `notification`, and `settings` as style references when a new test file needs a project-local example.
- When a controller mixes repository-backed async flows and local mutable form logic, keep the async workflow tests and the local mutation tests in separate method groups instead of merging them into one broad scenario.
- Seed controller state inline in each materially different scenario. For visit-form tests, prefer building the exact `Visit`, `Bid`, and `DateTime` values needed by that case instead of hiding them behind generalized fixture factories.
- Add one test for each meaningful branch family, not one test per line: for example draft-only update, editing-index replacement, id-based replacement, empty/no-op branch, and failure-preservation branch.
- If the public contract exposes both lifecycle callbacks and side effects, first test callback order, then add a separate test for the persisted state mutation. This keeps callback assertions focused and easier to debug.


## Invariants To Cover
- Controller with async state machine:
	validate controller `name`, initial state, success path, failure path, callback order, and the state visible during callbacks.
- Controller with local mutable form state but no dedicated state type:
	validate constructor defaults, change tracking, idempotent listener behavior, and the final entity built from form fields.
- Form controller with editable collections:
	validate `editing` pointer semantics, add/edit/update/delete flows, and whether `changed` flips only for real mutations.
- List-like controller:
	validate append vs replace behavior, sorting, and that previous successful data is preserved when the contract keeps it on failure.
- Fetch-style list controller with lifecycle callbacks:
	validate callback order on success and that `processing` state is visible inside `onProcessing` and `onSucceeded`, while `idle` is restored before `onDone`.
- Card/detail controller:
	validate no-op paths such as unchanged comment or missing item id, and confirm that failed mutations do not silently mark the controller as changed.
- Dedicated state type:
	validate derived getters first, then boolean flags, then `map`, `maybeMap`, and `mapOrNull`; add equality or `toString` only when the implementation defines them deliberately.
- Coverage escalation:
	close state helper branches (`type`, `isProcessing`, `map`, `maybeMap`, `mapOrNull`) before spending time on controller internals; these branches are usually cheap, stable, and document the state contract.
- Private helper coverage:
	prefer reaching helpers through the public method that already owns the behavior. If the helper branch cannot be reached without manufacturing impossible controller state, simplify the helper instead of exposing it or testing private state directly.


## Feature Visit Examples
- `BlockingTimeListController` style: constructor invariants, callback order for create, data preservation on failure, and split state tests by `isProcessing`, `map`, `maybeMap`, `mapOrNull`.
- `VisitCardController` style: detail fetch, mutation success and no-op cases, failure preserving previous visit data, and state derived getters grouped separately from pattern matching helpers.
- `VisitFormBlockingTimeController` style: single `_$controllerTest()` entrypoint because there is no standalone state type; cover constructor defaults, first-change notification semantics, and entity creation from form fields.
- `VisitFormRecordingController` style: explicit inline seeded states instead of a generic `_createController()` helper; cover both controller workflows and recording-state derived getters, plus `editingBid` and `changed` invariants around bid mutations.
- `VisitFormRecordingController` coverage strategy: separate tests for draft bid mutations, committed bid replacement, fallback replacement by `bidID`, empty/no-op branches, and helper-driven time recalculation through public methods such as `addCurrentBidToBids`, `removeCurrentBidFromBids`, `updateBid`, and `deleteBid`.
- `VisitFormRecordingController` callback strategy: when a mutation exposes `onSucceeded`, assert both the callback-visible state and the persisted `visit/currentBid` state in separate tests to keep failures local.
- `VisitListController` style: cover callback order, state visible during callbacks, fetch/create/update confirmation flows, and preservation of prior `visits`, `visitsNew`, and `coverage` on failure when the contract restores idle with previous data.
- `VisitFormRepeatController` style: lightweight local controller without repository mocks; still keep the same entrypoint naming and group cases by public API.
- `VisitFormRepeatController` error strategy: for purely local guarded controllers, simulate recoverable errors through lightweight throwing test doubles for input values rather than by reaching into private methods or listener internals.


## Coverage Triage Workflow
- Start from the exact uncovered branch or method, not from the whole feature surface.
- Map the uncovered line back to one of three buckets: public contract branch, state helper branch, or internal-only implementation branch.
- Close cheap public/state branches first.
- Re-run focused coverage on the touched test file after each small patch.
- If the remaining uncovered lines are internal-only and the public contract is already proven, stop expanding tests unless a small production simplification can remove the artificial gap without changing behavior.

```dart
void main() {
	_$controllerTest();
	_$stateTest();
}

void _$controllerTest() => group('ExampleController -', () {
	late ExampleController controller;

	setUp(() {
		controller = ExampleController(...);
	});

	tearDown(() {
		controller.dispose();
	});

	group('fetch() -', () {
		test('loads data into state', () async {
			// arrange
			// act
			// assert
		});
	});
});

void _$stateTest() => group('ExampleState -', () {
	group('isProcessing -', () {
		test('returns true only for processing state', () {
			// assert
		});
	});

	group('map() -', () {
		test('routes to the matching state branch', () {
			// assert
		});
	});
});
```

```dart
void main() {
	_$controllerTest();
}

void _$controllerTest() => group('ExampleFormController -', () {
	late ExampleFormController controller;

	group('constructor -', () {
		test('keeps default unchanged state', () {
			controller = ExampleFormController();
			expect(controller.changed, isFalse);
		});
	});

	group('change tracking -', () {
		test('notifies once on the first mutation', () {
			controller = ExampleFormController();
			var notifications = 0;
			controller
				..addListener(() => notifications++)
				..changeFoo('value')
				..changeBar('other');

			expect(controller.changed, isTrue);
			expect(notifications, 1);
		});
	});
});
```


## Widget Test Harness
- Use `WidgetTestUtil.createWidgetUnderTest(...)` as the default wrapper for widget tests.
- Use `WidgetTestUtil.appContext(...)` when the widget needs project `Dependencies`, `SettingsScope`, or `AuthenticationScope`.
- Use `WidgetTestUtil.getContextUnderTest(...)` or `WidgetTestUtil.getLocalizationsAndContextUnderTests(...)` for context-only or localization-only assertions.
- Do not hand-roll `MaterialApp`, localization delegates, UI theme, settings scope, or authentication scope in each widget test.
- Keep local harness helpers small and focused on the behavior under test; they should wrap `WidgetTestUtil`, not replace it.
- Prefer lightweight test pages/widgets over real feature screens when testing infrastructure such as navigation, unless the behavior depends on the real screen.
- When testing nested navigators, place the nested navigator in normal page content rather than app bar/action slots to avoid testing toolbar `Hero` behavior by accident.