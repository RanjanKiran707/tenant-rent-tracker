# 🏠 Tenant Tracker (Rent Book)

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Database](https://img.shields.io/badge/SQLite-Drift-blue?style=for-the-badge&logo=sqlite&logoColor=white)](https://drift.simonbinder.eu/)
[![Tests](https://img.shields.io/badge/Tests-280%20Passing-brightgreen?style=for-the-badge&logo=checkmarx&logoColor=white)](test/)
[![Localization](https://img.shields.io/badge/Languages-English%20%7C%20Kannada-orange?style=for-the-badge)](lib/l10n/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

A high-reliability, offline-first rental property management app built with Flutter and Drift (SQLite). Designed for landlords and property managers to effortlessly track tenant dues, payments, overdue balances, and payment history across custom property groups.

> **🚀 [Try the Live Web Demo](https://tenant-tracker.web.app)**  
> **📦 [Download Android Release APK (v2.1.0)](https://github.com/RanjanKiran707/tenant-rent-tracker/releases/tag/v2.1.0)**

---

## 🎬 Video Demo

https://github.com/user-attachments/assets/e23bc835-2caa-4c48-ae5b-e18634380105

*The Welcome guide, adding a group and a tenant, and recording a partial and full payment. Demo automation scripts are in [scripts/demo](scripts/demo/README.md).*

---

## ✨ Features

- **Tenant Ledger:** Each tenant tracks rent amount, due day (default 10th), and start month. Monthly billing records are generated on demand.
- **Group Organization:** Organize tenants into groups (e.g., "Block A", "Ground Floor"). The home dashboard displays per-group dues, tenant counts, and most urgent payment statuses.
- **8-State Monthly Ledger Tracking:** Real-world tracking statuses:
  - `Pending`, `Completed`, `Late Completed`, `Partial`, `Partial Overdue`, `Overdue`, `Backlog`, and `Backlog Cleared`.
  - Shortfalls are treated as separate debts rather than obscuring future months.
- **Granular Payment History:** Payments recorded individually with date stamps. Supports editing amount/date with automatic ledger re-calculation, and immediate undo.
- **Historical Rent Protection:** Change tenant rent rates effective from the next month without mutating historical payment ledgers.
- **Bilingual Support:** Full internationalization (English & Kannada).
- **Tenant Archiving:** Soft-delete tenants into a read-only historical archive.

---

## 🏛️ Engineering & Test Rigor (280 Automated Tests)

The business logic of `tenant-rent-tracker` is backed by **280 automated tests** ensuring financial accuracy and edge-case resilience:

- **29 Core Utility Tests:** [`test/core/month_utils_test.dart`](test/core/month_utils_test.dart) validates leap years, 28/29/30/31-day month boundaries, century leap calculations, and rollover dates.
- **49 Data & SQLite Tests:** Verifies Drift migrations, transactional payment consistency, and reactive database stream queries.
- **157 Domain Business Use Case Tests:** Exhaustive testing for overdue calculation, retroactive payment edits, partial balance carryovers, and state updates.
- **45 Feature & UI Tests:** End-to-end view model and widget validations.

---

## 🛠️ Tech Stack

- **Framework:** Flutter (Android & Web)
- **Local Database:** [`drift`](https://pub.dev/packages/drift) & `drift_flutter` (Reactive SQLite)
- **Localization:** `flutter_localizations`, `intl`, `l10n.yaml`
- **Architecture:** Layered Architecture (`lib/core`, `lib/data`, `lib/domain`, `lib/features`)
- **State Management:** ValueNotifier with functional dependency injection

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.x or later)
- Android SDK or connected device / emulator / modern browser

### Setup & Run
```bash
# Clone the repository
git clone https://github.com/RanjanKiran707/tenant-rent-tracker.git
cd tenant-rent-tracker

# Install dependencies
flutter pub get

# Generate Drift SQLite database code
dart run build_runner build

# Run application
flutter run

# Execute all 280 automated tests
flutter test
```

---

## 📚 Technical Documentation

- [Product Specifications](project_spec/specs.md)
- [Data Model & Schema](project_spec/data_model_tenant_tracker.md)
- [Entity-Relationship Diagram (ERD)](project_spec/erd_tenant_tracker.md)
- [Dependency Analysis](project_spec/analysis_of_dependencies.md)
- [Release Notes](RELEASE_NOTES.md) | [Changelog](CHANGELOG.md)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
