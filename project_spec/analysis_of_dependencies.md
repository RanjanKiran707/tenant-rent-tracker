# Tenant Tracker – Dependency Analysis

Maintenance check for the packages chosen in the architecture and specs.

**fpdart was dropped** after this check (it was the only package rated Watch: last release 2025-10-29, one maintainer, 9 open issues, 1,140 likes, 265K downloads a month). The architecture now uses its own sealed `Result<T>` class (`core/errors/result.dart`), so it is not analysed below.

- **Data pulled:** 2026-10-01. Numbers are a snapshot and will drift.
- **Sources:** pub.dev API (`/api/packages/<name>` and `/score`) and the GitHub API (`gh api`) for each package's repository.
- **Open issues** counts issues only, not pull requests. GitHub's own "open issues" figure includes PRs, so it is higher.
- **Ratings** are my judgement from these numbers, not an official score.

## Summary

| Package | Version | Last release | Likes | Pub points | Downloads (30d) | Open issues | Stars | Publisher | Rating |
|---|---|---|---|---|---|---|---|---|---|
| drift | 2.35.1 | 2026-09-30 | 2,478 | 160/160 | 1.37M | 202 (whole repo) | 3,283 | simonbinder.eu | Healthy |
| drift_flutter | 0.3.1 | 2026-07-11 | 70 | 160/160 | 462K | shared with drift | shared | simonbinder.eu | Healthy |
| drift_dev (dev) | 2.35.1 | 2026-09-30 | 72 | 110/160 | 1.08M | shared with drift | shared | simonbinder.eu | Healthy |
| shared_preferences | 2.5.5 | 2026-03-25 | 10,576 | 160/160 | 6.91M | 17 (in flutter/flutter) | 5,317 (flutter/packages) | flutter.dev | Healthy |
| intl | 0.20.3 | 2026-06-25 | 6,108 | 160/160 | 11.08M | 114 (label `package:intl`) | 83 (dart-lang/i18n) | dart.dev | Healthy |
| uuid | 4.6.0 | 2026-07-15 | 2,734 | 160/160 | 14.75M | 0 | 463 | yuli.dev | Healthy |
| build_runner (dev) | 2.16.1 | 2026-09-02 | 2,369 | 160/160 | 6.62M | 1 (label `package:build_runner`) | 868 (dart-lang/build) | tools.dart.dev | Healthy |
| flutter_localizations | SDK | with Flutter | n/a | n/a | n/a | n/a | n/a | Flutter SDK | Healthy (not a pub package) |

## Per-package notes

### drift (+ drift_flutter, drift_dev)
- **Used for:** the SQLite database and reactive `watchX()` streams.
- **Maintenance:** very active. drift 2.35.1 and drift_dev 2.35.1 were both released the day before this pull. Releases 2.35.0 (2026-09-09) and 2.35.1 (2026-09-30) show a steady cadence. About 25 issues were closed since 2026-07-01.
- **Issues:** 202 open on the shared repo, 15 labelled `bug`. This is a large tracker for a large feature set (several platforms, web, migrations), not a sign of neglect. Most will not touch a simple local Android/iOS database.
- **Risks:**
  - One maintainer (Simon Binder) runs the whole family. Bus factor is 1, but the track record is long.
  - `drift` and `drift_dev` must be on the same version. Keep them matched in `pubspec.yaml`.
  - drift_dev scores 110/160 on pub points, lower than the others. The score is a pub.dev tooling check, not a quality signal for us. I did not look at which checks it misses.
  - drift_flutter is at `0.x`, so its API may still change. It is a thin helper for opening the database, so a change is cheap to absorb.


### shared_preferences
- **Used for:** settings (language, show tips, seen welcome).
- **Maintenance:** official `flutter.dev` package. 10,576 likes, 6.9M downloads. Last release 2.5.5 on 2026-03-25.
- **Issues:** 17 open with the `p: shared_preferences` label in `flutter/flutter` (Flutter plugin issues are tracked there, not in `flutter/packages`).
- **Risks:** low. Do not store the rent data here (the model already keeps it in drift).

### intl
- **Used for:** date, number and currency formatting; gen-l10n output depends on it.
- **Maintenance:** official `dart.dev` package. 11.08M downloads. 0.20.3 released 2026-06-25.
- **Issues:** 114 open with the `package:intl` label in `dart-lang/i18n`. It is a big tracker because of locale data requests; the package itself is stable.
- **Risks:** `flutter_localizations` pins a specific `intl` range per Flutter version, so let `flutter pub add intl` and `flutter pub get` resolve the version instead of forcing one. The `0.x` version number is long-standing and does not signal instability.

### uuid
- **Used for:** primary keys for all tables.
- **Maintenance:** 4.6.0 released 2026-07-15. Repo last pushed 2026-08-19. 14.75M downloads (the highest in the list), 2,734 likes.
- **Issues:** 0 open.
- **Risks:** low. Single maintainer, but the package is small and stable. Use `v4()` (random) for local IDs.

### build_runner (dev)
- **Used for:** running drift code generation.
- **Maintenance:** official `tools.dart.dev` package. 2.16.1 released 2026-09-02. Repo pushed the day of this pull.
- **Issues:** 1 open with the `package:build_runner` label. 43 open issues in `dart-lang/build` mention build_runner in the text.
- **Risks:** build time on larger projects, and analyzer-version conflicts between `build_runner`, `drift_dev` and the Flutter SDK. Resolve these by upgrading together and running `flutter pub upgrade --major-versions` in one step, then regenerating.

### flutter_localizations
- **Used for:** Material localization for the English and Kannada UI.
- **Maintenance:** part of the Flutter SDK, versioned with Flutter. Nothing to evaluate separately.

## Cross-cutting risks

1. **drift family version match.** `drift`, `drift_dev` (and `drift_flutter`) release together. Mismatches cause build errors.
2. **Analyzer conflicts.** `build_runner`, `drift_dev` and the Flutter SDK share the Dart analyzer. Upgrade them together.
3. **Generated code.** drift output (`*.g.dart`) should be generated in CI or committed consistently. Pick one before the first commit.

## Verdict

- The set is healthy. All seven pub.dev packages had a release in 2026, and none is rated Watch or Risk.
- fpdart was removed in favour of a sealed `Result` class (see the note at the top).
- No package needs replacing today.

## Not verified

- drift_dev's 50 missing pub points: the cause was not checked.
- Open issue counts for drift_flutter and drift_dev are the whole-repo count, since they share the repo with drift. I did not split them by package label.
- Whether the Flutter version you will use pins `intl` to 0.20.3. Check with `flutter pub get` after creating the project.
