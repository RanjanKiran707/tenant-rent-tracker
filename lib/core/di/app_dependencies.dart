import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenant_tracker/core/utils/clock.dart';
import 'package:tenant_tracker/data/database/app_database.dart';
import 'package:tenant_tracker/data/payment/payment_repository.dart';
import 'package:tenant_tracker/data/rent_history/rent_history_repository.dart';
import 'package:tenant_tracker/data/rent_record/rent_record_repository.dart';
import 'package:tenant_tracker/data/settings/settings_repository.dart';
import 'package:tenant_tracker/data/tenant/tenant_repository.dart';
import 'package:tenant_tracker/domain/use_cases/business/add_tenant/add_tenant_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/change_rent/change_rent_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/delete_tenant/delete_tenant_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/ensure_rent_records/ensure_rent_records_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/record_payment/record_payment_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/rename_tenant/rename_tenant_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/business/settings/settings_usecases.dart';
import 'package:tenant_tracker/domain/use_cases/business/undo_payment/undo_payment_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_add_tenant_form/load_add_tenant_form_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_payment_options/load_payment_options_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/load_rent_change_info/load_rent_change_info_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_archived_tenants/watch_archived_tenants_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_home/watch_home_usecase.dart';
import 'package:tenant_tracker/domain/use_cases/ui/watch_tenant_detail/watch_tenant_detail_usecase.dart';

/// Everything global is built once, at startup, in one place.
/// Nothing else creates repositories or use cases. Views and ViewModels get
/// use cases only; the repositories stay inside [init].
class AppDependencies {
  // Set once in main() before runApp. Tests can replace it.
  static late AppDependencies instance;

  // Business use cases: they write and validate.
  final AddTenantUsecase addTenant;
  final EnsureRentRecordsUsecase ensureRentRecords;
  final RecordPaymentUsecase recordPayment;
  final UndoPaymentUsecase undoPayment;
  final ChangeRentUsecase changeRent;
  final DeleteTenantUsecase deleteTenant;
  final RenameTenantUsecase renameTenant;
  final LoadSettingsUsecase loadSettings;
  final SetLanguageUsecase setLanguage;
  final SetShowTipsUsecase setShowTips;
  final MarkWelcomeSeenUsecase markWelcomeSeen;
  final SetSimulatedDateUsecase setSimulatedDate;

  /// The app's clock. Developer tools change its date; screens listen to it to
  /// reload.
  final SimulatedClock clock;

  // UI use cases: they only read, for presentation.
  final WatchHomeUsecase watchHome;
  final WatchTenantDetailUsecase watchTenantDetail;
  final WatchArchivedTenantsUsecase watchArchivedTenants;
  final LoadPaymentOptionsUsecase loadPaymentOptions;
  final LoadRentChangeInfoUsecase loadRentChangeInfo;
  final LoadAddTenantFormUsecase loadAddTenantForm;

  AppDependencies._({
    required this.addTenant,
    required this.ensureRentRecords,
    required this.recordPayment,
    required this.undoPayment,
    required this.changeRent,
    required this.deleteTenant,
    required this.renameTenant,
    required this.loadSettings,
    required this.setLanguage,
    required this.setShowTips,
    required this.markWelcomeSeen,
    required this.setSimulatedDate,
    required this.clock,
    required this.watchHome,
    required this.watchTenantDetail,
    required this.watchArchivedTenants,
    required this.loadPaymentOptions,
    required this.loadRentChangeInfo,
    required this.loadAddTenantForm,
  });

  static Future<void> init() async {
    instance = create(
      db: AppDatabase(),
      prefs: await SharedPreferences.getInstance(),
      clock: const SystemClock(),
    );
  }

  /// Builds everything from a database, preferences and a clock. [init] uses
  /// the real ones; tests pass an in-memory database and a fake clock.
  static AppDependencies create({
    required AppDatabase db,
    required SharedPreferences prefs,
    required Clock clock,
  }) {
    // The app's clock: [clock], unless a developer-simulated date is saved.
    // The saved date is ignored outside debug builds.
    final settings = SettingsRepository(prefs);
    final appClock = SimulatedClock(
      clock,
      simulatedDate: kDebugMode ? settings.simulatedDate : null,
    );

    // 1. Data layer (the only place that knows the real implementations).
    final tenants = TenantRepository(db);
    final history = RentHistoryRepository(db);
    final records = RentRecordRepository(db);
    final payments = PaymentRepository(db);

    // 2. Domain layer.
    final ensureRentRecords = EnsureRentRecordsUsecase(
      tenants,
      history,
      records,
      appClock,
    );

    return AppDependencies._(
      addTenant: AddTenantUsecase(tenants, ensureRentRecords, appClock),
      ensureRentRecords: ensureRentRecords,
      recordPayment: RecordPaymentUsecase(payments, appClock),
      undoPayment: UndoPaymentUsecase(payments),
      changeRent: ChangeRentUsecase(tenants, history, appClock),
      deleteTenant: DeleteTenantUsecase(tenants, appClock),
      renameTenant: RenameTenantUsecase(tenants),
      loadSettings: LoadSettingsUsecase(settings),
      setLanguage: SetLanguageUsecase(settings),
      setShowTips: SetShowTipsUsecase(settings),
      markWelcomeSeen: MarkWelcomeSeenUsecase(settings),
      setSimulatedDate: SetSimulatedDateUsecase(settings, appClock),
      clock: appClock,
      watchHome: WatchHomeUsecase(tenants, records, payments, appClock),
      watchTenantDetail: WatchTenantDetailUsecase(
        tenants,
        records,
        payments,
        history,
        appClock,
      ),
      watchArchivedTenants: WatchArchivedTenantsUsecase(tenants, records),
      loadPaymentOptions: LoadPaymentOptionsUsecase(
        tenants,
        records,
        payments,
        appClock,
      ),
      loadRentChangeInfo: LoadRentChangeInfoUsecase(tenants, history, appClock),
      loadAddTenantForm: LoadAddTenantFormUsecase(appClock),
    );
  }
}
