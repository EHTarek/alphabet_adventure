# Google Play Store Listing — Alphabet Adventure 3D

Draft copy for the Play Console **Main store listing** page.

**Field limits (Play Console, current):** App name **30**, Short description **80**, Full description **4000** — all including spaces. The 80-character field is the *short description*, not the app name; the name field will not accept more than 30. All copy below fits those limits.

---

## 1. App name (30 char limit)

**Primary:**

```
Alphabet Adventure 3D
```

*(21 / 30 characters)*

**Keyword-extended variants**, all still within 30, if you want more search coverage in the name itself:

| Option | Chars |
|---|---:|
| `Alphabet Adventure: ABC Kids` | 28 |
| `Alphabet Adventure 3D: ABC` | 26 |
| `Alphabet Adventure 3D Kids` | 26 |

> Play policy: no "Free", "Best", "#1", emoji, or ALL CAPS in the app name.

---

## 2. Short description (80 char limit)

**Primary:**

```
Fun ABC phonics games for kids 4-8. Learn letters, sounds and words offline.
```

*(76 / 80 characters)*

**Alternatives:**

```
Learn letters, phonics sounds and first words through playful ABC adventures.
```
*(77 / 80)*

```
ABC learning game for ages 4-8. Phonics, first words, no ads, works offline.
```
*(76 / 80)*

---

## 3. Full description (4000 char limit)

```
Alphabet Adventure 3D turns early literacy practice into a playful journey through six colourful worlds. Children aged 4 to 8 meet a letter, hear its name and its sound, explore the world around it, tap objects that start with that letter, and earn stars for every attempt they make.

There are no timers, no scores to lose and no failure screens. A wrong tap simply invites another try, and Pip the Parrot is always there to explain what to do next.

WHAT YOUR CHILD LEARNS
• All 26 letters of the English alphabet, in uppercase and lowercase
• One clear, age-appropriate phonics sound for every letter
• 78 first vocabulary words, at least three for every letter, from apple and ball to xylophone and zebra
• Letter recognition, sound-to-letter matching and early spelling

FIVE WAYS TO PLAY
• Letter Hunt - spot the target letter among friendly distractions
• Object Hunt - explore a scene and find the things that start with the letter
• Sound Match - listen to a sound and choose the letter that makes it
• Word Builder - drag letters into place to spell a first word
• Review Challenge - short mixed recall that revisits earlier letters so learning sticks

SIX WORLDS TO EXPLORE
Journey from the Enchanted Forest to the Sunny Farm, the Rainbow Playground, the Cozy Home, the Deep Ocean and finally Outer Space. Each world covers the whole alphabet at a higher level of challenge, and each one unlocks with the stars your child has already earned, so difficulty grows at your child's pace.

BUILT FOR CHILDREN WHO CANNOT READ YET
Every instruction is spoken aloud. Buttons are large and forgiving. Motion, colour and voice carry the meaning, so a child can play a whole lesson without an adult reading anything on screen. Lessons are short by design and fit comfortably into three to eight minutes.

STARS, STICKERS AND BADGES
Finishing a lesson always earns at least one star. Stars unlock new worlds, and collectable stickers and badges celebrate milestones such as a first lesson, a practice streak and a perfect challenge. Progress is never taken away.

FOR PARENTS AND TEACHERS
A parent area, protected by a simple adult gate, shows a clear summary of how practice is going: which letters are new, developing or mastered, total stars earned, stickers collected and recent activity. Everything stays on the device.

You can also adjust the experience from the settings screen:
• Separate volume controls for narration, sound effects and background music, plus a single mute switch
• Subtitles for spoken prompts
• Reduced animations for children who prefer a calmer screen
• High contrast mode
• Multiple child profiles, each with its own nickname, avatar and progress
• Reset progress at any time

PRIVACY AND SAFETY FIRST
• No ads, ever
• No in-app purchases
• No account, no sign-up, no email address required
• No internet connection needed - the whole app works offline
• No personal data leaves the device; progress is stored locally
• No chat, no social features, no external links for children

Alphabet Adventure 3D is designed for the way young children actually learn: see it, hear it, touch it, and try again as many times as it takes. Start with A and see where the adventure goes.
```

*(3,203 / 4,000 characters)*

---

## 4. Supporting listing fields

| Field | Suggested value |
|---|---|
| App category | Education (consider Educational under Games if you want game placement) |
| Tags | Education, Learning, Family, Casual |
| Target age group | Ages 5 and under, 6-8 |
| Content rating | Everyone / PEGI 3 |
| Contains ads | No |
| In-app purchases | No |
| Designed for Families | Yes - eligible; requires the family policy questionnaire |
| Data safety | No data collected, no data shared, all processing on-device |
| Contact email | (required - use a monitored support address) |
| Privacy policy URL | (required for Designed for Families - must be publicly hosted) |

### Data safety answers
"No data collected" is accurate. Analytics events (lesson started, lesson completed, challenge completed)
are logged in-memory only in
[`analytics_service.dart`](../lib/data/services/analytics_service.dart) and never transmitted; there are
no ads, no IAP, no accounts, and no HTTP calls anywhere in `lib/`. Fredoka is a local font bundled in
`assets/fonts/`, so the app makes no font request either - verified by running the release build with the
device in airplane mode and app data cleared.

Re-check this answer if you ever add a remote analytics SDK or a package that phones home.

---

## 5. App name applied in the build

"Alphabet Adventure 3D" is now set everywhere the name is user-visible:

| Location | Value |
|---|---|
| [`AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml) `android:label` | `Alphabet Adventure 3D` |
| [`Info.plist`](../ios/Runner/Info.plist) `CFBundleDisplayName` | `Alphabet Adventure 3D` |
| [`app.dart`](../lib/app.dart) `MaterialApp.title` | `Alphabet Adventure 3D` |
| [`pubspec.yaml`](../pubspec.yaml) `description` | `Alphabet Adventure 3D — ...` |
| [`splash_screen.dart`](../lib/ui/features/splash/views/splash_screen.dart) wordmark | `ALPHABET` / `ADVENTURE` + `3D` badge |

`CFBundleName` in Info.plist stays `alphabet_adventure` — it is the internal bundle short name, not shown
to users, and the Dart package name in `pubspec.yaml` is unchanged since renaming it would touch every import.

---

## 6. Graphic assets

All generated and sitting in [`store/play/`](../store/play/). Every file already meets Play's format
rules: 24-bit PNG, no alpha channel.

| Asset | File | Size |
|---|---|---|
| Store icon | `store/play/icon_512.png` | 512x512 |
| Feature graphic (banner) | `store/play/feature_graphic_1024x500.png` | 1024x500 |
| Phone screenshots (8) | `store/play/screenshots/phone/01-08*.png` | 1080x2400 |
| Extra screenshots (2) | `store/play/screenshots/extras/` | 1080x2400 |

The icon and banner are generated by [`tool/generate_store_assets.py`](../tool/generate_store_assets.py)
(`python3 tool/generate_store_assets.py`). The icon is a flattened downscale of the shipped launcher icon,
so the store listing and the launcher stay identical. The banner reuses the launcher's Pip artwork and the
splash-screen wordmark treatment; all of its text is auto-fitted to the layout, so editing a string will
not push it off the canvas.

### Screenshots

Captured from the real app running on a Pixel 8a emulator (1080x2400), in this upload order:

| # | Screen | Shows |
|---|---|---|
| 1 | World map | Six worlds, star-gated progression, letter A completed with 3 stars |
| 2 | Letter intro | Uppercase/lowercase, phonics sound, three example words |
| 3 | Object Hunt | Find the object beginning with A |
| 4 | Sound Match | Listen and choose the letter |
| 5 | Word Builder | Spelling APPLE from letter tiles |
| 6 | Letter Hunt | Lowercase recognition with the "4 in a row" streak badge |
| 7 | Lesson Complete | 3 stars, mastery level up, sticker unlocked |
| 8 | Parent Dashboard | A-Z mastery heatmap, stars, stickers, review recommendation |

Play accepts a maximum of 8 phone screenshots, so the settings screen, the parental gate and the Word
Match mode are held in `extras/` as swap-ins.

---

## 7. Release build and signing

Configured and verified. `flutter build appbundle --release` produces a Play-uploadable
`build/app/outputs/bundle/release/app-release.aab`.

| Setting | Value |
|---|---|
| Application ID | `com.apexdmit.alphabetadventure` (permanent once uploaded) |
| Namespace | `com.apexdmit.alphabetadventure` |
| versionCode / versionName | `1` / `1.0.0`, from `pubspec.yaml` `version: 1.0.0+1` |
| Upload keystore | `android/upload-keystore.jks` (PKCS12, RSA 2048, valid to Jan 2054) |
| Key alias | `upload` |
| Credentials | `android/key.properties` |
| Certificate SHA-256 | `51:7F:82:21:86:0D:F5:BE:FA:C9:F2:75:E0:FD:68:CB:D8:DD:31:FD:1F:58:6D:F4:43:40:B0:15:18:9F:0C:2A` |

[`build.gradle.kts`](../android/app/build.gradle.kts) reads `key.properties` and signs release builds with
that key. Both the keystore and `key.properties` are gitignored by
[`android/.gitignore`](../android/.gitignore) and were never committed. If `key.properties` is missing —
a fresh clone, or CI without the secret — release builds fall back to the debug key and log a warning
rather than failing, so `flutter run --release` keeps working.

Release builds also run R8 (`isMinifyEnabled` / `isShrinkResources`) with
[`proguard-rules.pro`](../android/app/proguard-rules.pro) keeping the Flutter embedding and plugin
classes, which are referenced reflectively.

> **Back up the keystore and its password now, somewhere outside this repo.** Losing them means you can
> never publish an update to this app under this listing — Play has no recovery path. Enrolling in Play
> App Signing at first upload protects the *app* signing key, but this upload key is still yours to keep.

### Build commands

```sh
flutter build appbundle --release   # app-release.aab — what you upload to Play
flutter build apk --release         # app-release.apk — for sideload testing
```

---

## 8. Remaining blockers before you can publish

1. **Privacy policy** must be live at a public URL before the Designed for Families review.
2. **Bundle size** is 55 MB, almost entirely the bundled audio (160 mp3 files) and images. Well under
   Play's limits, but worth trimming if you care about install size.

---

## 9. Defects found while capturing the screenshots - all fixed

Four problems surfaced while playing through the app for screenshots. All are fixed, and the screenshots
in `store/play/` show the fixed build.

### 9.1 Apple Inc.'s logo was used for the word "Apple" - fixed

[`interactive_object.dart`](../lib/ui/core/widgets/interactive_object.dart) mapped `'apple'` to
`Icons.apple_rounded`, Apple's corporate logo rather than a piece of fruit. It appeared in the letter A
intro, Object Hunt, Word Match and Word Builder.

### 9.2 Most words fell back to one identical placeholder icon - fixed

The same hand-written map ended at `_ => Icons.category_rounded`, a generic triangle-square-circle glyph
that any unmapped word inherited - banana, water, yogurt and many more. In Word Match this broke the
exercise outright: the prompt "Which picture shows Banana?" offered "Banana" and "Water" rendering the
*identical* placeholder, unanswerable for a child who cannot read. The map also gave cat, dog, bear, lion,
elephant and kangaroo one shared paw icon, and drew "bear" as a rabbit.

**Both fixed by the same change.** All 78 `WordData` entries already carry a distinct emoji, so
`_buildObjectVisual` now renders `word.emoji` instead of a Material icon, falling back to the word's
initial only if an entry ever lacks one. Every word now reads as itself, no trademark is used, and the
~80-line icon map is gone. Word Match now shows an ant, a fox and a house for its three options.

The 78 files in [`assets/images/objects/`](../assets/images/objects/) remain unused and are still
identical procedural placeholders - worth deleting or replacing with real artwork at some point, but
nothing depends on them.

### 9.3 The app fetched fonts over the network - fixed

`google_fonts` was a dependency with no bundled fonts and no runtime-fetch override, so the app downloaded
Fredoka from `fonts.gstatic.com` on first run. That contradicted the offline claims in the full
description and made "No data collected" unsafe as a Data safety answer.

Fixed by dropping the `google_fonts` package entirely and shipping Fredoka as a plain Flutter font. The
four static weights the app uses (Regular 400, Medium 500, SemiBold 600, Bold 700) live in
`assets/fonts/` and are declared under `fonts:` in [`pubspec.yaml`](../pubspec.yaml) as the family
`Fredoka`. [`app_fonts.dart`](../lib/ui/core/app_fonts.dart) provides `AppFonts.fredoka()` and
`AppFonts.fredokaTextTheme()`, replacing the 104 `GoogleFonts.*` call sites. Fredoka is OFL-licensed;
`OFL.txt` ships beside the fonts and is registered with `LicenseRegistry` so it appears on the app's
licence page.

There is now no network-capable font code in the app at all, rather than a fetch that is merely disabled
at runtime. Verified: with app data cleared and the device in airplane mode, the release build launches
with Fredoka rendering correctly. The offline copy in the full description is accurate.

### 9.4 Two copy bugs visible in the screenshots - fixed

- [`letter_intro_view.dart`](../lib/ui/features/game/views/letter_intro_view.dart) wrapped
  `phonicsSound` in slashes that the data already contained, so the bubble read `It says //ae//!`. It now
  reads `It says /ae/!`.
- [`parent_dashboard_screen.dart`](../lib/ui/features/parent/views/parent_dashboard_screen.dart)
  hardcoded the plural ("Letters A will benefit..."). It now agrees with the count.

`flutter analyze` is clean and all 11 tests pass after these changes.
