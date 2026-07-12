# Tawag-Tugon — Android Polish Guide

**Goal:** Make the Flutter app *feel* like a real native Android app without leaving Flutter
or expanding V1 scope. Patterns adapted from the sibling native app **GearSync**
(Kotlin/NDK) — concepts only; no Kotlin is imported.

> **Guardrail:** We stay on Flutter (single codebase → Android + iPhone, per Ayok's ask).
> "Native feel" here means *respecting Android platform conventions*, NOT rewriting native.
> Nothing in this doc adds a V1 feature — it's polish + one config refactor.

---

## 1. The two carry-overs from GearSync

1. **Config-driven, no-recompile-per-tenant.** GearSync's `VehicleConfig.kt` loads a typed
   object once from a JSON asset with safe defaults ("new vehicle = edit JSON, no
   recompile"). Tawag-Tugon's per-LGU branding should follow the same rule: **new LGU =
   new config/manifest, no code change.** See §4 for the `LguConfig` sketch.
2. **No hardcoded literals.** GearSync routes strings → `strings.xml`, colors → `colors.xml`.
   Flutter equivalent: colors/typography come from a single `ThemeData`; user-facing strings
   live in one place (l10n or a strings file). This is what makes re-skinning per LGU trivial.

---

## 2. Android-conventions checklist (the visible "native" wins)

Cheap, high-impact. Most are a few lines each.

- [ ] **Material 3 theme from a per-LGU seed color.**
      `ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: lgu.brandColor, ...),
      useMaterial3: true)`. One seed color per LGU yields a full, correct palette.
- [ ] **Adaptive launcher icon per LGU.** Ship an adaptive icon (foreground + background
      layers), not a stretched PNG. Use `flutter_launcher_icons` with
      `adaptive_icon_foreground`/`adaptive_icon_background`. This is the #1 "real app" signal
      on the home screen — and where Ayok's daughter's assets plug in.
- [ ] **Status bar + navigation bar theming.** Match system bars to the LGU brand via
      `SystemChrome.setSystemUIOverlayStyle(...)` (or `AppBar.systemOverlayStyle`). An
      unthemed white status bar instantly reads "web wrapper."
- [ ] **Material touch ripples.** Make every tappable row an `InkWell`/`InkResponse` inside a
      `Material` so taps show the Android ripple. Emergency-directory rows especially.
- [ ] **Correct back-button behavior.** Predictable system-back navigation; use `PopScope`
      to guard/confirm only where it matters. Don't trap the user.
- [ ] **Edge-to-edge + safe areas.** Wrap scaffold content in `SafeArea`; opt into
      edge-to-edge so content sits correctly under system bars on modern Android.
- [ ] **Dynamic type / large fonts.** Respect the OS text-scale (`MediaQuery.textScaler`) —
      important for an app used in emergencies by older users.
- [ ] **Splash screen.** Use the Android 12+ splash API (`flutter_native_splash`) so cold
      start looks intentional, branded per LGU.
- [ ] **App label per LGU.** `android:label` reflects the LGU's app name (e.g. "QC Alert"),
      not "tawag_tugon_app".
- [ ] **Haptics on key actions.** `HapticFeedback.selectionClick()` on a call tap — small
      but makes the app feel physical/native (GearSync uses distinct buzzes deliberately).

---

## 3. Permissions & native intents (keep install friction near zero)

GearSync declares **only** what it uses, with typed foreground-service types and a comment
per permission. Mirror that discipline — Tawag-Tugon's V1 needs almost nothing:

- **Dialer (`tel:`)** — launching the phone dialer needs **no permission** (`CALL_PHONE` is
  only for placing calls *without* the dialer; we do NOT want that). Keep it permissionless.
- **Viber / Messenger deep links** — `viber://` and `https://m.me/…` are just URL launches
  (`url_launcher`), no permission.
- **Package visibility (Android 11+).** To detect whether Viber/Messenger are installed
  (e.g. to hide a channel), add a scoped `<queries>` block in `AndroidManifest.xml`:
```xml
  <queries>
    <package android:name="com.viber.voip" />
    <package android:name="com.facebook.orca" />
    <intent><action android:name="android.intent.action.DIAL" /></intent>
  </queries>
```
- **Do NOT request** location, contacts, storage, notifications, etc. in V1. Every permission
  you skip is fewer scary dialogs and higher trust — exactly right for an emergency app.

**Launch pattern (Dart):** try the preferred protocol, fall back to `tel:` if the app isn't
installed, and never crash on a missing handler.

```dart
Future<void> launchContact(EmergencyContact c) async {
  final uri = switch (c.protocol) {
    'viber' => Uri.parse('viber://chat?number=${c.value}'),
    'https' => Uri.parse(c.value),           // e.g. https://m.me/<page>
    _       => Uri(scheme: 'tel', path: c.value),
  };
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    // graceful fallback to the dialer
    await launchUrl(Uri(scheme: 'tel', path: c.value));
  }
}
```

---

## 4. `LguConfig` — typed, config-driven branding (Dart sketch)

Modeled on GearSync's `VehicleConfig.load()`: **load once, typed, safe defaults, missing/
malformed → fall back, never throw into the UI.** Source it from a bundled default asset
(`assets/lgu_config.json`) for the demo build, or hydrate from the `/manifest` tenant payload.

```dart
import 'dart:convert';
import 'dart:ui' show Color;
import 'package:flutter/services.dart' show rootBundle;

/// Per-LGU branding + config. Loaded once at startup (asset) or from the
/// /manifest tenant payload. New LGU = new config, no recompile.
class LguConfig {
  final String tenantSlug;   // e.g. "quezon-city"
  final String appName;      // e.g. "QC Alert" (also drives the window title)
  final String logoAsset;    // path or URL to the LGU seal/logo
  final Color  brandColor;   // seed color for Material 3 ColorScheme.fromSeed
  final String? newsSourceUrl; // optional; null in V1 (manual admin entry)

  const LguConfig({
    required this.tenantSlug,
    required this.appName,
    required this.logoAsset,
    required this.brandColor,
    this.newsSourceUrl,
  });

  /// Safe defaults if the config is missing or a field is absent/malformed.
  static const LguConfig fallback = LguConfig(
    tenantSlug: 'demo',
    appName: 'Tawag-Tugon',
    logoAsset: 'assets/branding/default_logo.png',
    brandColor: Color(0xFFB00020), // emergency red default
  );

  factory LguConfig.fromJson(Map<String, dynamic> j) {
    // Parse "#RRGGBB" or "#AARRGGBB"; fall back to the default red on any error.
    Color parseColor(Object? v) {
      final s = (v as String?)?.replaceFirst('#', '') ?? '';
      final hex = s.length == 6 ? 'FF$s' : s;      // add opaque alpha if missing
      final n = int.tryParse(hex, radix: 16);
      return n == null ? fallback.brandColor : Color(n);
    }

    return LguConfig(
      tenantSlug:   (j['tenant_slug']   as String?) ?? fallback.tenantSlug,
      appName:      (j['app_name']      as String?) ?? fallback.appName,
      logoAsset:    (j['logo']          as String?) ?? fallback.logoAsset,
      brandColor:   parseColor(j['brand_color']),
      newsSourceUrl:(j['news_source_url'] as String?), // stays null in V1
    );
  }

  /// Load the bundled default LGU config for the demo build.
  /// (In production, prefer hydrating from the /manifest tenant object.)
  static Future<LguConfig> loadAsset(
      [String path = 'assets/lgu_config.json']) async {
    try {
      final raw = await rootBundle.loadString(path);
      return LguConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return LguConfig.fallback; // never block startup on config
    }
  }
}
```

**Wiring it into the theme** (this is what makes swapping LGU = re-skinned app, zero code):

```dart
final lgu = await LguConfig.loadAsset(); // or LguConfig.fromJson(manifest['tenant'])

runApp(MaterialApp(
  title: lgu.appName,
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: lgu.brandColor),
  ),
  home: HomeScreen(lgu: lgu),
));
```

Matching `assets/lgu_config.json` (what an LGU hands over — no code touched):

```json
{
  "tenant_slug": "quezon-city",
  "app_name": "QC Alert",
  "logo": "assets/branding/qc_seal.png",
  "brand_color": "#0B5FA5",
  "news_source_url": null
}
```

---

## 5. Out of scope (don't let this doc creep)
- No Kotlin/NDK, no platform channels for V1 — `url_launcher` + `HapticFeedback` cover the
  native touchpoints we need.
- GPS-based dynamic branding stays deferred; `LguConfig` is loaded per build/tenant (locked).
- No push notifications, no auto-scraper — `news_source_url` is a nullable placeholder only.

## 6. Suggested order of work
1. Introduce `LguConfig` + wire `ColorScheme.fromSeed` (unlocks per-LGU theming).
2. Convert directory/news rows to `InkWell` + add `SafeArea`/edge-to-edge + status-bar theme.
3. Adaptive launcher icon + native splash + per-LGU `app_name`.
4. `<queries>` block + the graceful `launchContact` fallback.
5. Haptics + text-scale respect pass.