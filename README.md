# project_flutter_getx_basic

Flutter + GetX client for the Spring Boot backend
[`project-spring-boot-user-image-sse`](../project-spring-boot-user-image-sse).

Covers the whole backend: JWT login and register, user CRUD with paginated
infinite scroll, profile image upload, and a live SSE stream that updates the
list when anyone changes a user.

## Run

Start the backend first (it must be on port 8910):

```bash
cd "../project-spring-boot-user-image-sse" && mvn spring-boot:run
```

Then the app:

```bash
flutter pub get && flutter run
```

Sign in with the seeded account — the login form is pre-filled with it:
`admin@example.com` / `Admin@123`.

### Pointing the app at the backend

`localhost` means a different machine on every target, so `ApiConstant.baseUrl`
resolves it per platform:

| Running on | Address used | Why |
|---|---|---|
| Android emulator | `http://10.0.2.2:8910` | `localhost` is the emulator itself; `10.0.2.2` is the host |
| iOS simulator | `http://localhost:8910` | shares the Mac's network |
| Real device | must be set by hand | neither of the above can reach your Mac |

For a real phone, pass your machine's LAN IP:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8910
```

Both platforms block plain HTTP by default, so this project ships the two
exceptions needed for local development — `android/app/src/main/res/xml/network_security_config.xml`
allows cleartext to `10.0.2.2` and `localhost` only, and `NSAllowsLocalNetworking`
does the same on iOS. Neither weakens anything for a real HTTPS backend.

## Language and theme

The app starts in **Khmer** and falls back to English for any missing key:

```dart
translations: AppTranslation(),
locale: const Locale('km', 'KH'),
fallbackLocale: const Locale('en', 'US'),
```

**The key is the English sentence**, not a code:

```dart
Text('Delete user'.tr)
Text('@name deleted'.trParams(<String, String>{'name': user.displayName}))
```

Two reasons that beats `'delete_user'.tr`: a screen can be read without opening
the translations file, and a key missing from *both* maps falls through to the
key itself — which is already correct English rather than `delete_user`.

All of them live in one file, [`util/languages.dart`](lib/util/languages.dart),
with `en_US` and `km_KH` side by side.

Switch language at runtime from anywhere:

```dart
Get.updateLocale(const Locale('en', 'US'));
```

To follow the phone's language instead of forcing Khmer, replace `locale:` with
`Get.deviceLocale`.

`flutter_localizations` is wired up as well, which is what translates Flutter's
*own* widgets — the text-selection menu, date pickers, tooltips. Without those
delegates a non-English locale leaves those in English.

> The Khmer strings were written for this project and have **not** been checked
> by a native speaker. Have someone review them before this goes in front of
> real users.

The brand colour is `#00AAA0`, defined once in
[`core/value/app_color.dart`](lib/core/value/app_color.dart) as `AppColor.primary`,
with `primaryDark` (`#00776F`) and `primaryLight` (`#E6F7F6`) derived from it.
Nothing else writes a raw `Color(0x…)`, so changing the brand is one edit.

## Structure

```
lib/
  binding/       who gets created for which route
  constant/      API paths and app-wide values
  controller/    state and actions — no widgets
  core/
    util/        api client, token storage, errors, logging
    value/       colours, text styles, dimensions, theme
  data/
    model/       JSON in, typed objects out
    service/     one class per backend area
  route/         route names + the GetPage table
  screen/        what the user sees
  util/          validators, formatters, snackbars and dialogs
  widget/        reusable pieces of UI
```

**`core/util` vs `util`** — `core/util` is plumbing the app cannot run without
(HTTP, storage, errors). `util` is convenience for the UI layer (validation,
date formatting, snackbars). If it imports `flutter/material.dart`, it belongs
in `util`.

**`constant` vs `core/value`** — `constant` holds behaviour (endpoints, page
size, timeouts). `core/value` holds design tokens (colour, spacing, type).

### How a screen gets its data

```
GetPage(binding: UserBinding())     the route declares what it needs
   ↓
UserBinding.dependencies()          lazyPut(UserController)
   ↓
UserController.onInit()             calls the service
   ↓
UserService.getPage(filter)         builds the query
   ↓
ApiClient.get()                     attaches the Bearer token
   ↓
PageResponse.fromJson()             unwraps the backend envelope
   ↓
users.assignAll(...)                an .obs list
   ↓
Obx(() => ListView(...))            only this widget rebuilds
```

Screens extend `GetView<T>`, which supplies a `controller` getter — that is why
every screen here is a `StatelessWidget` with no `setState` anywhere.

## The four things worth reading

**Pagination** — `UserController` keeps `_page` / `_totalPages` and appends
each page to one `RxList`. A `ScrollController` listener calls `loadMore()`
within 200px of the bottom, guarded so a fast scroll cannot fire two requests
for the same page. Search runs through a GetX `debounce` worker: without it
every keystroke would fire a request and the answers could arrive out of order.

**Image upload** — `image_picker` compresses to 80% quality and 1200px before
sending, because a modern phone photo is several MB and the backend returns 413
over 5 MB. In edit mode the file uploads immediately; in create mode it has to
wait until after `POST /api/users` returns, because the endpoint is
`/api/users/{id}/image` and there is no id until then.

**SSE** — Flutter has no `EventSource`, so `SseService` asks Dio for a raw byte
stream, decodes it to lines, and folds lines back into frames on the blank line
that terminates each one. The server's `: ping` heartbeat is skipped. Because
`EventSource` cannot send headers, the token goes in `?access_token=` — the
backend accepts it there for this route only. A dropped stream reconnects after
5 seconds, the same thing a browser does on its own.

**Error handling** — `ApiClient` sets `validateStatus: (_) => true` so error
bodies reach the code instead of being thrown by Dio first. That lets it read
the backend's `detail` field and rethrow one `ApiException` carrying the
server's own wording, which is what the snackbars show. A 401 clears the stored
token on the way through.

## Tests

```bash
flutter test
```

Ten unit tests over the parts that break silently when the backend's JSON
changes: envelope parsing, SSE frame decoding, and the validators that mirror
the server's `UserValidator`.
