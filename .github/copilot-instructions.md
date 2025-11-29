# Copilot / AI Agent Instructions — Enrutador

This file helps AI coding agents become productive in this Flutter app quickly. Focus on actionable, discoverable patterns and examples from the repository.

**Project Purpose**: mobile (and desktop/web) route/contact manager built with Flutter, using `flutter_map` for maps, local sqlite (`sqflite`) for persistent data, and `Provider` for app state.

**Big-picture architecture**
- `lib/main.dart`: app entry — registers `MainProvider` in `ChangeNotifierProvider`.
- `lib/views/`: UI screens and dialogs. Views read from `MainProvider` and controllers.
- `lib/utilities/`: shared helpers (e.g., `main_provider.dart`, `map_fun.dart`, `preferences.dart`, `uri_fun.dart`).
- `lib/controllers/`: data access layer. Each controller wraps a sqlite table and exposes create/update/get methods (e.g., `contacto_controller.dart`, `referencias_controller.dart`).
- `lib/models/`: DB and domain models (e.g., `contacto_model.dart`, `referencia_model.dart`).

**Important conventions & patterns**
- State: single `MainProvider` (implements `TickerProvider`) is the central ChangeNotifier. Most views use `Provider.of<MainProvider>(context)` or `Consumer<MainProvider>`.
- DB controllers: follow pattern `XController` with:
  - `database()` → opens `app_<name>.db` (sqflite `openDatabase`)
  - `createTables(sql.Database)` → creates table `nombreDB` (string at top of file)
  - CRUD helpers named `insert`, `update`, `getItems`, `getItemId`, etc.
  - Query helpers return typed model lists: `Future<List<Model>>`.
- Preferences: `lib/utilities/preferences.dart` exposes static getters/setters around `SharedPreferences` (used widely for app filters and flags).
- Maps: `flutter_map` + `flutter_map_animations` + `flutter_map_location_marker`.
  - Map-specific helpers live in `lib/utilities/map_fun.dart` (see `marcadores(...)` to build markers).
  - Map state (AnimatedMapController) is kept on `MainProvider.animaMap`.

**Database migration helper**
- `lib/controllers/sql_generator.dart` contains helpers to add columns or rename columns at runtime (`existColumna`, `renombrar`). Use these for non-destructive migrations.

**File / naming conventions**
- Controllers: `lib/controllers/<entity>_controller.dart` and global `nombreDB` string at top.
- Models: `lib/models/<entity>_model.dart` with `toJson()` / `fromJson()` helpers.
- Utilities: small helpers used across views live in `lib/utilities/*`.

**Build / run / debug (practical commands)**
- Get deps: `flutter pub get`
- Run on default device: `flutter run`
- Run on Windows (PowerShell):
  ```powershell
  flutter pub get
  flutter run -d windows
  ```
- Build android release: `flutter build apk --release`
- iOS: standard `flutter build ios` (codesign required on macOS).
- Debugging: use `flutter run --verbose` and Flutter DevTools. For maps, emulate GPS or use `location` plugin mocks.

**Common agent tasks with examples**
- Add a new DB-backed entity:
  1. Add model in `lib/models/` with `toJson()`/`fromJson()`.
  2. Add `XController` in `lib/controllers/` following `ContactoController` pattern: define `nombreDB`, `createTables`, `database()`, CRUD methods.
  3. If you need to add a column later, use `SqlGenerator.existColumna` to ALTER TABLE safely.
- Add a map marker:
  - Use `MapFun.marcadores(provider, contacto)` (see `lib/utilities/map_fun.dart`) or create an `AnimatedMarker` and add to `MainProvider.marker`.
- Read/write preferences: use `Preferences.<key>` static getters/setters.

**Key files to inspect for patterns**
- `lib/utilities/main_provider.dart` — app state, animated map controller, marker list
- `lib/controllers/contacto_controller.dart` — example CRUD and filtering using `Preferences`
- `lib/controllers/referencias_controller.dart` — example of relationship table used to draw polylines
- `lib/utilities/map_fun.dart` — marker generation and map helpers
- `lib/utilities/preferences.dart` — global app settings usage

**Gotchas discovered in the code (helpful to know)**
- `MainProvider.set animaMap(AnimatedMapController valor)` currently assigns `animaMap = valor;` which will recurse — treat carefully when modifying provider setters.
- Views commonly wrap async DB calls with `FutureBuilder` — for map polylines prefer returning a `PolylineLayer` from the builder (don't pass a Widget as a List of polylines).
- Many UI sizes use `Sizer` (e.g., `19.sp`, `1.w`): keep `sizer` initialization in `main.dart` when editing UI.

If anything here is unclear or you want me to include examples for a specific developer task (adding a model, creating a page, or a DB migration), tell me which task and I will expand this file accordingly.
