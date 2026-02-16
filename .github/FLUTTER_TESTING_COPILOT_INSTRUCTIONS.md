# Flutter Testing — AI Copilot Instructions

> **Purpose**: This document captures every testing decision, convention, and pattern used in this project. An AI assistant implementing or modifying tests **MUST** follow these instructions.

---

## Table of Contents

1. [Philosophy & Principles](#1-philosophy--principles)
2. [Library Dependencies](#2-library-dependencies)
3. [Test Directory Structure](#3-test-directory-structure)
4. [Fixtures & Fake Data (`lib/testing/`)](#4-fixtures--fake-data-libtesting)
5. [Fake Repositories (`lib/features/**/infrastructure/`)](#5-fake-repositories-libfeaturesinfrastructure)
6. [The Test Harness (`test/helpers/`)](#6-the-test-harness-testhelpers)
7. [Testing Levels & Patterns](#7-testing-levels--patterns)
8. [Flow Tests — The Primary Test Type](#8-flow-tests--the-primary-test-type)
9. [Async Handling & Pump Patterns](#9-async-handling--pump-patterns)
10. [Mocking with Mocktail](#10-mocking-with-mocktail)
11. [Common Pitfalls & Solutions](#11-common-pitfalls--solutions)
12. [Naming Conventions](#12-naming-conventions)
13. [Running Tests](#13-running-tests)
14. [Checklist — Before Submitting a New Test](#14-checklist--before-submitting-a-new-test)

---

## 1. Philosophy & Principles

### Fakes Over Mocks (Vladimir Khorikov's "Dual-Track")

We prefer **Fakes** (functional, in-memory implementations of repository interfaces) over **Mocks** for integration/flow tests. Mocks (`when().thenReturn()`) are reserved for isolated unit tests where you need to verify individual service method calls.

| Concept | When to Use | Example |
|---------|-------------|---------|
| **Fakes** | Flow tests, integration tests — test real behavior chains | `FakeMenuRepository`, `FakeAuthRepository` |
| **Mocks** | Unit tests — verify a single service delegates to its repository | `MockMenuRepository extends Mock implements MenuRepository` |

### Constructor-Based Dependency Injection

Every widget and service that needs a dependency **MUST** accept it through its constructor. **Never** access Firebase or singletons directly inside `build()` or `initState()`.

```dart
// ✅ GOOD — injectable, testable
class LoginPage extends StatefulWidget {
  final AuthService authService;
  const LoginPage({required this.authService});
}

// ❌ BAD — untestable, triggers [core/no-app] in tests
class LoginPage extends StatefulWidget {
  final AuthService _authService = AuthService(); // calls FirebaseAuth.instance
}
```

### Lazy Getters for Firebase Access

If a service **must** reference a Firebase instance, use a **getter** instead of a **field**:

```dart
// ✅ GOOD — only throws when actually accessed
class MyService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
}

// ❌ BAD — throws at construction time in tests
class MyService {
  final _auth = FirebaseAuth.instance;
}
```

### Isolation — Never Pump `MyApp()`

Widget and flow tests **MUST NOT** call `tester.pumpWidget(const MyApp())`. This triggers AuthGate → Firebase → crash. Always pump widgets in isolation via the **TestHarness** or a simple `MaterialApp` wrapper.

---

## 2. Library Dependencies

### `pubspec.yaml` — `dev_dependencies`

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.4
  flutter_lints: ^5.0.0
```

### Dependency Choices — Rationale

| Library | Why This |
|---------|----------|
| `mocktail` | Dart-first, no code generation, clean `when(() => ...)` syntax. Chosen over `mockito` which requires `@GenerateMocks` + build_runner. |
| `flutter_test` | Standard Flutter test runner. |
| `integration_test` | For device/emulator-based Level 3 tests. |
| `flutter_riverpod` | State management — all providers are overridable in tests via `ProviderScope.overrides`. |
| `rxdart` | `BehaviorSubject` used in Fake repositories to seed streams with initial state. |
| `equatable` | Domain entities extend `Equatable` for value-based equality in assertions. |

> **We do NOT use**: `mockito`, `build_runner`, `firebase_auth_mocks`, `fake_cloud_firestore`, `golden_toolkit`, or any code-generation test libraries.

---

## 3. Test Directory Structure

```
test/
├── helpers/                     # Shared test infrastructure
│   ├── test_setup.dart          # Provider overrides (mock-based, for unit tests)
│   ├── test_app.dart            # TestHarness + buildTestApp (fake-based, for flow tests)
│   └── pump_helpers.dart        # pumpAndFlush() helper for async timer issues
│
├── flows/                       # ⭐ PRIMARY: End-to-end user journey tests (fake-based)
│   ├── auth_gate_test.dart      # Auth routing: unauthenticated → LoginPage, authenticated → HomePage
│   ├── login_flow_test.dart     # Login button → success/error → HomePage/error UI
│   ├── logout_flow_test.dart    # Profile → Logout → confirmation → LoginPage → re-login
│   ├── navigation_test.dart     # Tab switching: Categories ↔ Profile
│   ├── categories_flow_test.dart # Category CRUD: list, add, toggle, reorder, navigate
│   └── category_details_flow_test.dart # Product CRUD: add, edit, delete, reorder
│
├── app/                         # SECONDARY: Isolated unit & widget tests (mock-based)
│   ├── routing/
│   │   └── app_router_test.dart # Pure unit tests for route → widget mapping
│   ├── services/
│   │   ├── home_page_facade_test.dart          # Facade stream composition tests
│   │   ├── profile_page_facade_test.dart       # Facade tests
│   │   └── restaurant_context_service_test.dart # Context resolution tests
│   └── pages/
│       ├── login-page/
│       │   └── login_page_test.dart             # Smoke: renders title, button, icon
│       └── home_page/widgets/
│           ├── category_reorder_page_test.dart   # Widget test with mock service
│           └── edit_product_dialog_test.dart      # Dialog tests with validation
│
├── features/                    # Domain/infrastructure unit tests
│   ├── domain/
│   │   └── entities_test.dart   # Entity equality, copyWith, edge cases
│   ├── auth_gate_test.dart      # Legacy auth gate test
│   └── menu/
│       ├── application/services/
│       │   └── menu_service_test.dart          # Service → Repository delegation
│       └── infrastructure/dtos/
│           ├── category_dto_test.dart          # DTO JSON parsing
│           └── product_dto_test.dart           # DTO JSON parsing
│
├── smoke/                       # Minimal rendering verification
│   ├── login_page_smoke_test.dart
│   └── screen_rendering_draft.dart
│
├── flutter_tests_readme.md      # Quick reference for developers
├── empty_test.dart              # Verifies test runner works
└── simple_test.dart             # Baseline assertion test
```

### Directory Placement Rules

| Test Type | Directory | Uses Fakes/Mocks | Uses TestHarness |
|-----------|-----------|-----------------|-----------------|
| **Flow tests** (user journeys) | `test/flows/` | Fakes | Yes |
| **Service/Facade unit tests** | `test/app/services/` | Mocks (mocktail) | No |
| **Widget tests** (isolated components) | `test/app/pages/<feature>/` | Mocks (mocktail) | No |
| **Domain entity tests** | `test/features/domain/` | Neither | No |
| **DTO parsing tests** | `test/features/<feature>/infrastructure/dtos/` | Neither | No |
| **Smoke tests** | `test/smoke/` | Fakes | Sometimes |
| **Router unit tests** | `test/app/routing/` | Mock BuildContext | No |

---

## 4. Fixtures & Fake Data (`lib/testing/`)

Fixtures live in `lib/testing/` (NOT in `test/`) so they can be shared with both tests and the `main_fake.dart` debug entry point.

```
lib/testing/
├── auth_fixtures.dart              # AuthFixtures.testUser (const AuthUser)
├── menu_fixtures.dart              # MenuFixtures.fake, .forknife, .nfc17, etc.
├── restaurant_users_fixtures.dart  # RestaurantUsersFixtures.fake_foorcun, etc.
├── restaurants_fixtures.dart       # RestaurantsFixtures with menu key mappings
├── shared_config_fixtures.dart     # SharedConfigFixtures
└── adisyon-project-default-rtdb-export.json  # Raw Firebase RTDB snapshot for reference
```

### Fixture Design Rules

1. **Named constants/statics** — Fixtures are `static const` or `static final` values on classes (e.g., `AuthFixtures.testUser`).
2. **Match real data structure** — Fixture data mirrors the Firebase RTDB JSON format. Menu fixtures use `MenuDto.fromJson()` → `.toDomain()` pipeline.
3. **Consistent identity chain** — Fixtures form a connected chain:
   ```
   AuthFixtures.testUser (email: foorcun@gmail.com)
     → RestaurantUsersFixtures.fake_foorcun (relatedRestaurantsIds: [-OlKaa_kkasdfsadfcrF])
       → RestaurantsFixtures (menuKey: key_fake)
         → MenuFixtures.fake (2 categories: "Fake Burgers", "Fake Drinks")
   ```
4. **New fixtures** must maintain this chain. If you add a new test user, add a corresponding restaurant user, restaurant, and menu.

---

## 5. Fake Repositories (`lib/features/**/infrastructure/`)

Each domain feature has a `fake_*_repository.dart` file **inside** `lib/` (co-located with the real repository):

```
lib/features/
├── auth-feature/infrastructure/
│   └── fake_auth_repository.implementation.dart   # FakeAuthRepository
├── menu/infrastructure/repositories/
│   └── fake_menu_repository.dart                  # FakeMenuRepository
├── restaurant/infrastructure/repositories/
│   └── fake_restaurant_repository.dart            # FakeRestaurantRepository
├── restaurant-user-feature/infrastructure/repositories/
│   └── fake_restaurant_user_repository.dart        # FakeRestaurantUserRepository
└── shared-config-feature/infrastructure/repositories/
    └── fake_shared_config_repository.dart          # FakeSharedConfigRepository
```

### Fake Repository Design Rules

1. **Implements the domain interface** — `class FakeMenuRepository implements MenuRepository`.
2. **Uses BehaviorSubject** — Stream-based methods use `BehaviorSubject<T>.seeded(initial)` from `rxdart` so listeners immediately get the latest state.
3. **Static cache with `reset()`** — Fakes use `static final Map<String, ...>` caches. Each test must call `FakeXxxRepository.reset()` in `setUp()` to prevent state leakage.
4. **Reads from Fixtures** — Initial data is loaded from `lib/testing/*_fixtures.dart`.
5. **Mutates in-memory state** — Write operations (add, update, delete) mutate the cache and push new values to the BehaviorSubject.
6. **No `Future.delayed`** — Fakes skip artificial delays. The `TestableAuthRepository` (in `test/helpers/test_app.dart`) overrides `FakeAuthRepository.signInWithGoogle()` to remove the `Future.delayed` that would cause `FakeAsync` timer issues.

---

## 6. The Test Harness (`test/helpers/`)

### `test_app.dart` — `TestHarness` + `buildTestApp()`

This is the core infrastructure for **flow tests**. It wires the full dependency chain using fakes.

```dart
// Usage in every flow test:
late TestHarness harness;

setUp(() {
  FakeMenuRepository.reset();  // Prevent state leakage
  harness = TestHarness.create();
});

testWidgets('...', (tester) async {
  await tester.pumpWidget(harness.buildApp());
  await pumpAndFlush(tester);
  // ... test body
});
```

**Dependency chain built by `TestHarness.create()`:**
```
TestableAuthRepository (extends FakeAuthRepository)
  └→ RestaurantContextService
       ├→ RestaurantUserService(FakeRestaurantUserRepository)
       └→ RestaurantService(FakeRestaurantRepository)
  └→ MenuService(FakeMenuRepository)
  └→ ProfilePageFacade(contextService)
  └→ SharedConfigService(FakeSharedConfigRepository)
```

**`buildTestApp()` provides these Riverpod overrides:**
- `authRepositoryProvider` → `FakeAuthRepository`
- `restaurantContextServiceProvider` → Real service wired with fakes
- `menuServiceProvider` → Real service wired with `FakeMenuRepository`
- `profilePageFacadeProvider` → Real facade wired with fakes
- `sharedConfigServiceProvider` → Real service wired with `FakeSharedConfigRepository`
- `orderingEnabledProvider` → `Stream.value(false)`
- `currentUserProvider`, `relatedRestaurantsProvider`, `activeRestaurantIdProvider`, `activeMenuKeyProvider` → Forwarded from `RestaurantContextService` streams

### `test_app.dart` — `TestableAuthRepository`

Extends `FakeAuthRepository` with test-configurable behavior:

```dart
class TestableAuthRepository extends FakeAuthRepository {
  Exception? signInError;          // Set to make signIn throw
  Future<AuthUser> Function()? onSignIn;  // Set for custom sign-in logic

  @override
  Future<AuthUser> signInWithGoogle() async {
    if (signInError != null) throw signInError!;
    if (onSignIn != null) return onSignIn!();
    emitUser(AuthFixtures.testUser);
    return AuthFixtures.testUser;
  }
}
```

### `pump_helpers.dart` — `pumpAndFlush()`

Flushes the 5-second timeout from `RestaurantContextService.init()`:

```dart
Future<void> pumpAndFlush(WidgetTester tester) async {
  await tester.pump();                               // Initial frame
  await tester.pump(const Duration(seconds: 6));     // Flush the 5s timeout
  await tester.pump();                               // Settle remaining frames
}
```

**Always use `pumpAndFlush(tester)` instead of `pumpAndSettle()` in flow tests.** `pumpAndSettle` will hang indefinitely waiting for the timer.

### `test_setup.dart` — `TestSetup.authOverrides()` (for unit tests)

Used in mock-based unit tests. Provides `ProviderScope` overrides with mocked services (not fakes). Registers `mocktail` fallback values.

---

## 7. Testing Levels & Patterns

### Level 1: Foundation (Unit Tests)

- **What**: Business logic, service delegation, DTO parsing, entity behavior
- **Pattern**: `test()` with `MockXxx` via `mocktail`
- **Structure**: `// arrange → // act → // assert`

```dart
test('should watch menu from repository', () {
  // arrange
  when(() => mockMenuRepository.watchMenu(any<String>()))
      .thenAnswer((_) => Stream.value(tMenu));
  // act
  final result = menuService.watchMenu(tMenuKey);
  // assert
  expect(result, emits(tMenu));
  verify(() => mockMenuRepository.watchMenu(tMenuKey)).called(1);
});
```

### Level 2: Component (Widget Tests)

- **What**: Individual widgets rendered in isolation with `MaterialApp` wrapper
- **Pattern**: `testWidgets()` with mock services injected via constructor

```dart
testWidgets('Calls updateCategoriesOrder with correct menuKey', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: CategoryReorderPage(
      categories: testCategories,
      menuService: mockMenuService,
      menuKey: testMenuKey,
    ),
  ));
  // ... tap, verify
});
```

### Level 3: Flow Tests ⭐ (Integration Widget Tests)

- **What**: Multi-step user journeys through the real widget tree using fakes
- **Pattern**: `testWidgets()` with `TestHarness`
- **Location**: `test/flows/`

This is the **primary test type** in this project.

---

## 8. Flow Tests — The Primary Test Type

### Anatomy of a Flow Test File

```dart
import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

void main() {
  late TestHarness harness;

  setUp(() {
    FakeMenuRepository.reset();  // Reset ALL fake repositories with static state
    harness = TestHarness.create();
  });

  // Helper: authenticate + navigate to the page under test
  Future<void> loginAndNavigate(WidgetTester tester) async {
    await tester.pumpWidget(harness.buildApp(
      currentUserStream: Stream.value(fakeRestaurantUser),
    ));

    await tester.runAsync(() async {
      harness.fakeAuth.emitUser(fakeAuthUser);
      await Future.delayed(const Duration(milliseconds: 500));
    });

    await pumpAndFlush(tester);
    expect(find.byType(HomePage), findsOneWidget);
  }

  group('Feature Name - UI States', () {
    testWidgets('Shows expected data', (tester) async {
      await loginAndNavigate(tester);
      expect(find.text('Expected Text'), findsOneWidget);
    });
  });

  group('Feature Name - CRUD Operations', () {
    testWidgets('Add item and verify it appears', (tester) async {
      await loginAndNavigate(tester);
      // ... interact, verify
    });
  });
}
```

### Key Flow Test Patterns

**1. Authentication pattern (for tests needing an authenticated user):**
```dart
// Option A: Pre-authenticate before pump (simpler)
harness.fakeAuth.emitUser(fakeAuthUser);
await tester.pumpWidget(harness.buildApp());
await pumpAndFlush(tester);

// Option B: Authenticate after pump with runAsync (for testing auth transitions)
await tester.pumpWidget(harness.buildApp(
  currentUserStream: Stream.value(fakeRestaurantUser),
));
await tester.runAsync(() async {
  harness.fakeAuth.emitUser(fakeAuthUser);
  await Future.delayed(const Duration(milliseconds: 500));
});
await pumpAndFlush(tester);
```

**2. PopupMenu interaction pattern:**
```dart
Future<void> tapPopupMenuItem(WidgetTester tester, String value) async {
  await tester.tap(find.byType(PopupMenuButton<String>));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500)); // Animation

  final itemFinder = find.byWidgetPredicate(
    (widget) => widget is PopupMenuItem<String> && widget.value == value,
  );
  expect(itemFinder, findsOneWidget);
  await tester.tap(itemFinder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500)); // Close animation
  await tester.pump();
}
```

**3. Error configuration pattern:**
```dart
harness.fakeAuth.signInError = Exception('Network error: No internet connection');
```

**4. Custom sign-in behavior pattern:**
```dart
harness.fakeAuth.onSignIn = () async {
  harness.fakeAuth.emitUser(fakeAuthUser);
  return fakeAuthUser;
};
```

**5. NetworkImage error suppression (when testing pages with network images):**
```dart
void suppressNetworkImageErrors() {
  final binding = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    if (message.contains('HTTP request failed') ||
        message.contains('NetworkImageLoadException')) {
      return;
    }
    binding?.call(details);
  };
  addTearDown(() => FlutterError.onError = binding);
}

// Must be called at the TOP of testWidgets callback, NOT in setUp()
testWidgets('...', (tester) async {
  suppressNetworkImageErrors();
  // ... test body
});
```

---

## 9. Async Handling & Pump Patterns

### The Problem

`RestaurantContextService.init()` has a 5-second timeout. `BehaviorSubject` stream subscriptions are nested. `FakeAsync` (the default for `testWidgets`) doesn't allow real async operations.

### The Solution

| Situation | Use |
|-----------|-----|
| After any state change (login, CRUD, navigation) | `await pumpAndFlush(tester);` |
| To run real async code inside FakeAsync | `await tester.runAsync(() async { ... })` |
| Popup/dialog animations | `await tester.pump(); await tester.pump(Duration(milliseconds: 500));` |
| Waiting for the **final** UI state | `await tester.pumpAndSettle();` |
| Catching transient states (loading spinners) | `await tester.pump();` (single frame, NO duration) |

### Rules

1. **Never use `pumpAndSettle()` in flow tests** — it will hang on the RestaurantContextService timer.
2. **Always `pumpAndFlush()` after login, CRUD, or navigation**.
3. **Use `runAsync`** when you need BehaviorSubject streams to propagate through multiple layers.
4. **Popup animations need explicit pump durations** — Material popup open/close is 300ms; we pump 500ms for safety.

---

## 10. Mocking with Mocktail

### Setup Pattern (Unit Tests)

```dart
import 'package:mocktail/mocktail.dart';

class MockMenuRepository extends Mock implements MenuRepository {}
class FakeCategory extends Fake implements Category {}

void main() {
  setUpAll(() {
    // Register fallback values for typed matchers (any<T>())
    registerFallbackValue(FakeCategory());
    registerFallbackValue(FakeProduct());
    registerFallbackValue(FakeMenu());
    registerFallbackValue(<Category>[]);
    registerFallbackValue(<Product>[]);
  });

  late MockMenuRepository mockMenuRepository;
  late MenuService menuService;

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    menuService = MenuService(mockMenuRepository);
  });

  // tests...
}
```

### Mocktail Rules

1. **Always register fallback values in `setUpAll()`** for types used with `any<T>()`.
2. Use `Fake` (not `Mock`) for fallback values: `class FakeCategory extends Fake implements Category {}`.
3. **Prefer `when(() => ...)` over `when(mock.method)`** — mocktail uses a lambda syntax.
4. For streams: `when(() => mock.watch()).thenAnswer((_) => Stream.value(data))`.
5. For futures: `when(() => mock.save(any())).thenAnswer((_) => Future.value())`.

---

## 11. Common Pitfalls & Solutions

### `[core/no-app] No Firebase App '[DEFAULT]' has been created`
**Cause**: A widget accesses `FirebaseAuth.instance` or `FirebaseDatabase.instance` directly.
**Fix**: Use constructor injection + TestHarness with fake repositories.

### `No matching calls (actually, no calls at all)`
**Cause**: The component's no-op optimization skips the call (e.g., no-change save).
**Fix**: Set test data so initial state differs from expected final state (e.g., `displayOrder: 100` instead of `1`).

### `Timer is still pending` / `pumpAndSettle never completes`
**Cause**: `FakeAsync` encounters a real `Future.delayed` that can't be flushed.
**Fix**: Use `pumpAndFlush(tester)` instead of `pumpAndSettle()`. Ensure `TestableAuthRepository` has no `Future.delayed`.

### `Found 0 widgets with text "..."` (Terminology Mismatch)
**Cause**: UI string was renamed but test expectations weren't updated.
**Fix**: Search `test/` for the old string. Use `find.byKey()` for frequently changing labels.

### `Found 0 widgets with text "..."` (Async Timing)
**Cause**: Using `pumpAndSettle()` skips over transient states (loading spinner).
**Fix**: Use `await tester.pump()` (single frame) to catch the intermediate state.

### State leakage between tests
**Cause**: Fake repositories use `static` caches.
**Fix**: Always call `FakeXxxRepository.reset()` in `setUp()`.

---

## 12. Naming Conventions

### Test Files
- Flow tests: `test/flows/<feature>_flow_test.dart` (e.g., `login_flow_test.dart`)
- Widget tests: `test/app/pages/<feature>/widgets/<widget>_test.dart`
- Service tests: `test/app/services/<service>_test.dart`
- DTO tests: `test/features/<feature>/infrastructure/dtos/<dto>_test.dart`
- Entity tests: `test/features/domain/entities_test.dart`

### Test Groups and Names
```dart
group('Feature Name - UI States', () { ... });
group('Feature Name - CRUD Operations', () { ... });
group('Feature Name - Error Handling', () { ... });

testWidgets('Shows category list with data from fake repository', ...);
testWidgets('Add a new category and verify it appears in the list', ...);
testWidgets('Toggle category active/inactive', ...);
```

### Test Documentation — Doc Comments
Every flow test file should have a top-level doc comment documenting:
1. What the file verifies
2. The data chain from auth → fixture data

```dart
/// Categories Flow Tests
///
/// Verifies:
/// - Category list renders with data from FakeMenuRepository
/// - Add category dialog + creation
/// - Toggle category active/inactive
///
/// Data chain:
/// fakeAuth.emitUser(testUser) → email: foorcun@gmail.com
///   → FakeRestaurantUserRepository → fake_foorcun
///   → FakeRestaurantRepository → restaurant (menuKey: key_fake)
///   → FakeMenuRepository → MenuFixtures.fake
```

---

## 13. Running Tests

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/flows/login_flow_test.dart

# Run all flow tests
flutter test test/flows/

# Run all unit tests
flutter test test/app/services/

# Run with coverage
flutter test --coverage

# Run a specific test by name
flutter test --name "Shows LoginPage when user is not authenticated"
```

---

## 14. Checklist — Before Submitting a New Test

- [ ] Test file is in the correct directory (`flows/`, `app/services/`, etc.)
- [ ] `setUp()` calls `FakeXxxRepository.reset()` if using fakes with static state
- [ ] `setUp()` creates a fresh `TestHarness.create()` for flow tests
- [ ] Uses `pumpAndFlush(tester)` instead of `pumpAndSettle()` in flow tests
- [ ] Fallback values registered in `setUpAll()` for any `any<T>()` matchers
- [ ] Doc comment at top of file describing what is tested and the data chain
- [ ] Test groups follow `'Feature - Scenario'` naming
- [ ] No direct Firebase access (`FirebaseAuth.instance`, `FirebaseDatabase.instance`)
- [ ] `suppressNetworkImageErrors()` called if test renders network images
- [ ] Imports use **package imports** (`package:menumia_flutter_partner_app/...`), not relative paths, for `lib/` files
- [ ] Test helpers imported with **relative paths** (`../helpers/test_app.dart`) for `test/` files
- [ ] New fixtures maintain the identity chain (auth → restaurant user → restaurant → menu)

---

## Appendix: Import Convention

| Source | Import Style |
|--------|-------------|
| Files in `lib/` (production code) | `import 'package:menumia_flutter_partner_app/...';` |
| Files in `test/` (test helpers) | `import '../helpers/test_app.dart';` (relative) |
| Third-party packages | `import 'package:mocktail/mocktail.dart';` |
| Flutter SDK | `import 'package:flutter/material.dart';` |

This ensures import stability during directory restructuring and is the **project-wide standard**.
