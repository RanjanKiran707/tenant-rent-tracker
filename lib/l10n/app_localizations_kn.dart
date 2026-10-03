// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'ಬಾಡಿಗೆ ಲೆಕ್ಕ';

  @override
  String get langToggle => 'English';

  @override
  String get helpTooltip => 'ಸಹಾಯ';

  @override
  String get ok => 'ಸರಿ';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get navHome => 'ಮುಖಪುಟ';

  @override
  String get navSettings => 'ಸೆಟ್ಟಿಂಗ್ಸ್';

  @override
  String thisMonth(Object month) {
    return 'ಈ ತಿಂಗಳು – $month';
  }

  @override
  String get collected => 'ಬಂದ ಹಣ';

  @override
  String get toCollect => 'ಇನ್ನೂ ಬರಬೇಕು';

  @override
  String tenantsCount(Object count) {
    return 'ಬಾಡಿಗೆದಾರರು ($count)';
  }

  @override
  String get sortNote => 'ಗಮನ ಬೇಕಾದವರು ಮೇಲೆ ಇದ್ದಾರೆ.';

  @override
  String get noTenants =>
      'ಇನ್ನೂ ಯಾರೂ ಇಲ್ಲ. ಮೊದಲ ಬಾಡಿಗೆದಾರರನ್ನು ಸೇರಿಸಲು ದೊಡ್ಡ ನೀಲಿ ಬಟನ್ ಒತ್ತಿ.';

  @override
  String get addTenantBtn => '+ ಬಾಡಿಗೆದಾರರನ್ನು ಸೇರಿಸಿ';

  @override
  String rentPerMonth(Object amount) {
    return 'ತಿಂಗಳಿಗೆ ₹$amount';
  }

  @override
  String oldDues(Object amount) {
    return 'ಹಳೆಯ ಬಾಕಿ: ₹$amount';
  }

  @override
  String get addTitle => 'ಬಾಡಿಗೆದಾರರನ್ನು ಸೇರಿಸಿ';

  @override
  String get fName => 'ಬಾಡಿಗೆದಾರರ ಹೆಸರು';

  @override
  String get fNameHint => 'ವ್ಯಕ್ತಿಯ ಹೆಸರು ಬರೆಯಿರಿ.';

  @override
  String get fRent => 'ತಿಂಗಳ ಬಾಡಿಗೆ (₹)';

  @override
  String get fRentHint => 'ಅಂಕೆಗಳನ್ನು ಮಾತ್ರ ಬರೆಯಿರಿ, ಉದಾ: 8000.';

  @override
  String get fDue => 'ತಿಂಗಳ ಯಾವ ದಿನದೊಳಗೆ ಹಣ ಕೊಡಬೇಕು?';

  @override
  String get fDueHint => 'ಈ ದಿನದೊಳಗೆ ಹಣ ಬರದಿದ್ದರೆ \'ತಡ\' ಎಂದು ತೋರಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get fStart => 'ಪ್ರಾರಂಭದ ತಿಂಗಳು';

  @override
  String get fStartHint => 'ಯಾವ ತಿಂಗಳಿಂದ ಲೆಕ್ಕ ಇಡಬೇಕು.';

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get cancel => 'ರದ್ದು ಮಾಡಿ';

  @override
  String get undo => 'ಹಿಂದಕ್ಕೆ';

  @override
  String tenantAdded(Object name) {
    return '$name ಸೇರಿಸಲಾಗಿದೆ';
  }

  @override
  String get errName => 'ದಯವಿಟ್ಟು ಹೆಸರು ಬರೆಯಿರಿ.';

  @override
  String get errRent => 'ದಯವಿಟ್ಟು ಬಾಡಿಗೆ ಮೊತ್ತ ಬರೆಯಿರಿ (0 ಕ್ಕಿಂತ ಹೆಚ್ಚು).';

  @override
  String get errDueDay => 'ದಯವಿಟ್ಟು 1 ರಿಂದ 31 ರ ನಡುವೆ ಒಂದು ದಿನ ಆರಿಸಿ.';

  @override
  String get errStartMonth => 'ದಯವಿಟ್ಟು ಸರಿಯಾದ ಪ್ರಾರಂಭದ ತಿಂಗಳು ಆರಿಸಿ.';

  @override
  String get errStartFuture => 'ಪ್ರಾರಂಭದ ತಿಂಗಳು ಮುಂದಿನ ತಿಂಗಳಾಗಿರಬಾರದು.';

  @override
  String get errAmount => 'ದಯವಿಟ್ಟು 0 ಕ್ಕಿಂತ ಹೆಚ್ಚು ಮೊತ್ತ ಬರೆಯಿರಿ.';

  @override
  String get errDate => 'ದಯವಿಟ್ಟು ಸರಿಯಾದ ದಿನಾಂಕ ಆರಿಸಿ.';

  @override
  String get errDateFuture => 'ದಿನಾಂಕ ಮುಂದಿನ ದಿನವಾಗಿರಬಾರದು.';

  @override
  String get errTenantNotFound => 'ಈ ಬಾಡಿಗೆದಾರರು ಸಿಗಲಿಲ್ಲ.';

  @override
  String get errTenantDeleted => 'ಈ ಬಾಡಿಗೆದಾರರನ್ನು ತೆಗೆಯಲಾಗಿದೆ.';

  @override
  String get errGroupName => 'ದಯವಿಟ್ಟು ಗುಂಪಿನ ಹೆಸರು ಬರೆಯಿರಿ.';

  @override
  String get errGroupNameTaken => 'ಈ ಹೆಸರಿನ ಗುಂಪು ಈಗಾಗಲೇ ಇದೆ.';

  @override
  String get errGroupNotFound => 'ಈ ಗುಂಪು ಸಿಗಲಿಲ್ಲ.';

  @override
  String get errGroupDeleted => 'ಈ ಗುಂಪನ್ನು ತೆಗೆಯಲಾಗಿದೆ.';

  @override
  String get errGroupLocked =>
      '\'ವರ್ಗೀಕರಿಸದವರು\' ಗುಂಪನ್ನು ಬದಲಿಸಲು ಅಥವಾ ತೆಗೆಯಲು ಆಗುವುದಿಲ್ಲ.';

  @override
  String get errGroupNotEmpty =>
      'ಈ ಗುಂಪಿನಲ್ಲಿ ಇನ್ನೂ ಬಾಡಿಗೆದಾರರು ಇದ್ದಾರೆ. ಮೊದಲು ಅವರನ್ನು ಬೇರೆ ಗುಂಪಿಗೆ ಸರಿಸಿ.';

  @override
  String get errLanguage => 'ಈ ಭಾಷೆ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get errGeneric => 'ಏನೋ ತಪ್ಪಾಯಿತು. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String received(Object paid, Object total) {
    return '₹$total ರಲ್ಲಿ ₹$paid ಬಂದಿದೆ';
  }

  @override
  String balance(Object amount) {
    return 'ಬಾಕಿ: ₹$amount';
  }

  @override
  String dueDate(Object date) {
    return '$date ರೊಳಗೆ ಕೊಡಬೇಕು';
  }

  @override
  String get btnPayOld => 'ಹಳೆಯ ಬಾಕಿ ಬಂದ ಹಣ ಬರೆಯಿರಿ';

  @override
  String get btnPayMonth => 'ಈ ತಿಂಗಳಿಗೆ ಹಣ ಬರೆಯಿರಿ';

  @override
  String get payMonthHint => 'ಹಳೆಯ ಬಾಕಿ ಕೊಡಲು ಪಟ್ಟಿಯಿಂದ ಹಳೆಯ ತಿಂಗಳನ್ನು ಆರಿಸಿ.';

  @override
  String get btnPay => 'ಬಂದ ಹಣ ಬರೆಯಿರಿ';

  @override
  String get btnRent => 'ಬಾಡಿಗೆ ಬದಲಿಸಿ';

  @override
  String get btnDelete => 'ಈ ಬಾಡಿಗೆದಾರರನ್ನು ತೆಗೆಯಿರಿ';

  @override
  String get btnEditName => 'ಹೆಸರು ಬದಲಿಸಿ';

  @override
  String get editNameTitle => 'ಬಾಡಿಗೆದಾರರ ಹೆಸರು ಬದಲಿಸಿ';

  @override
  String nameSaved(Object name) {
    return 'ಹೆಸರನ್ನು $name ಎಂದು ಬದಲಿಸಲಾಗಿದೆ';
  }

  @override
  String get history => 'ಇತಿಹಾಸ';

  @override
  String get noHistory => 'ಇತಿಹಾಸ ಇನ್ನೂ ಇಲ್ಲ.';

  @override
  String get noPendingDue => 'ಯಾವುದೇ ಬಾಕಿ ಇಲ್ಲ';

  @override
  String pendingRentNote(Object month, Object amount) {
    return '$month ತಿಂಗಳಿನಿಂದ ಬಾಡಿಗೆ ₹$amount ಆಗುತ್ತದೆ.';
  }

  @override
  String extraNote(Object amount) {
    return 'ಹೆಚ್ಚುವರಿ ₹$amount ಬಂದಿದೆ (ಬರೆದಿಡಲಾಗಿದೆ ಅಷ್ಟೇ).';
  }

  @override
  String get payTitle => 'ಬಂದ ಹಣ';

  @override
  String get payAmount => 'ಎಷ್ಟು ಹಣ ಬಂದಿದೆ? (₹)';

  @override
  String payFull(Object amount) {
    return 'ಪೂರ್ಣ ಬಾಕಿ ತುಂಬಿ (₹$amount)';
  }

  @override
  String get payDate => 'ಯಾವ ದಿನಾಂಕದಂದು?';

  @override
  String get payMonth => 'ಯಾವ ತಿಂಗಳಿಗೆ?';

  @override
  String payAfter(Object amount) {
    return 'ಇದರ ನಂತರ ಬಾಕಿ ₹$amount ಇರುತ್ತದೆ.';
  }

  @override
  String get payAfterDone => 'ಇದರ ನಂತರ ಈ ತಿಂಗಳ ಬಾಡಿಗೆ ಪೂರ್ಣವಾಗಿ ಬಂದಿರುತ್ತದೆ';

  @override
  String payExtra(Object amount) {
    return '₹$amount ಹೆಚ್ಚುವರಿ ಎಂದು ಬರೆದಿಡಲಾಗುತ್ತದೆ. ಮುಂದಿನ ತಿಂಗಳಿಗೆ ಸೇರಿಸುವುದಿಲ್ಲ.';
  }

  @override
  String paymentSaved(Object amount) {
    return '₹$amount ಉಳಿಸಲಾಗಿದೆ';
  }

  @override
  String get rentTitle => 'ಬಾಡಿಗೆ ಬದಲಿಸಿ';

  @override
  String rentCurrent(Object amount) {
    return 'ಈಗಿನ ಬಾಡಿಗೆ: ₹$amount';
  }

  @override
  String get rentNew => 'ಹೊಸ ತಿಂಗಳ ಬಾಡಿಗೆ (₹)';

  @override
  String rentNotice(Object from, Object current, Object amount) {
    return 'ಇದು $from ತಿಂಗಳಿನಿಂದ ಅನ್ವಯವಾಗುತ್ತದೆ. $current ತಿಂಗಳ ಬಾಡಿಗೆ ₹$amount ಆಗಿಯೇ ಇರುತ್ತದೆ.';
  }

  @override
  String rentUp(Object amount) {
    return 'ಬಾಡಿಗೆ ₹$amount ಹೆಚ್ಚಾಗುತ್ತದೆ';
  }

  @override
  String rentDown(Object amount) {
    return 'ಬಾಡಿಗೆ ₹$amount ಕಡಿಮೆಯಾಗುತ್ತದೆ';
  }

  @override
  String get rentSame => 'ಇದು ಈಗಿನ ಬಾಡಿಗೆಯಷ್ಟೇ ಇದೆ.';

  @override
  String rentSaved(Object month) {
    return '$month ನಿಂದ ಬಾಡಿಗೆ ಬದಲಾಗುತ್ತದೆ';
  }

  @override
  String delTitle(Object name) {
    return '$name ಅವರನ್ನು ತೆಗೆಯಬೇಕೇ?';
  }

  @override
  String delBody(Object name) {
    return '$name ಅವರನ್ನು ಆರ್ಕೈವ್‌ಗೆ ಸರಿಸಲಾಗುತ್ತದೆ. ಏನೂ ಅಳಿಸಲ್ಪಡುವುದಿಲ್ಲ. ಎಲ್ಲಾ ಲೆಕ್ಕ ಸುರಕ್ಷಿತವಾಗಿ ಇರುತ್ತದೆ.';
  }

  @override
  String delOwed(Object amount) {
    return 'ಗಮನಿಸಿ: ₹$amount ಇನ್ನೂ ಬಾಕಿ ಇದೆ.';
  }

  @override
  String get delYes => 'ಹೌದು, ತೆಗೆಯಿರಿ';

  @override
  String get delNo => 'ಇಲ್ಲ, ಇರಲಿ';

  @override
  String removed(Object name) {
    return '$name ಅವರನ್ನು ತೆಗೆಯಲಾಗಿದೆ';
  }

  @override
  String get uncategorized => 'ವರ್ಗೀಕರಿಸದವರು';

  @override
  String groupsCount(Object count) {
    return 'ಗುಂಪುಗಳು ($count)';
  }

  @override
  String get noGroups =>
      'ಇನ್ನೂ ಗುಂಪುಗಳಿಲ್ಲ. ಗುಂಪು ಸೇರಿಸಿ, ನಂತರ ಅದನ್ನು ತೆರೆದು ಬಾಡಿಗೆದಾರರನ್ನು ಸೇರಿಸಿ.';

  @override
  String groupTenantsCount(Object count) {
    return '$count ಬಾಡಿಗೆದಾರರು';
  }

  @override
  String get groupOneTenant => '1 ಬಾಡಿಗೆದಾರರು';

  @override
  String get groupNoTenants => 'ಇನ್ನೂ ಯಾರೂ ಇಲ್ಲ';

  @override
  String groupToReceive(Object amount) {
    return 'ಬರಬೇಕಾದದ್ದು: ₹$amount';
  }

  @override
  String get noTenantsInGroup => 'ಈ ಗುಂಪಿನಲ್ಲಿ ಇನ್ನೂ ಬಾಡಿಗೆದಾರರು ಇಲ್ಲ.';

  @override
  String get defaultGroupNote => 'ಗುಂಪು ಇಲ್ಲದ ಬಾಡಿಗೆದಾರರು ಇಲ್ಲಿ ಇರುತ್ತಾರೆ.';

  @override
  String get addGroupBtn => '+ ಗುಂಪು ಸೇರಿಸಿ';

  @override
  String get addGroupTitle => 'ಗುಂಪು ಸೇರಿಸಿ';

  @override
  String get fGroupName => 'ಗುಂಪಿನ ಹೆಸರು';

  @override
  String get fGroupNameHint => 'ಉದಾ: ಬ್ಲಾಕ್ ಎ ಅಥವಾ ನೆಲ ಮಹಡಿ.';

  @override
  String groupAdded(Object name) {
    return '$name ಗುಂಪು ಸೇರಿಸಲಾಗಿದೆ';
  }

  @override
  String get renameGroupTitle => 'ಗುಂಪಿನ ಹೆಸರು ಬದಲಿಸಿ';

  @override
  String get btnRenameGroup => 'ಗುಂಪಿನ ಹೆಸರು ಬದಲಿಸಿ';

  @override
  String groupRenamed(Object name) {
    return 'ಗುಂಪಿನ ಹೆಸರನ್ನು $name ಎಂದು ಬದಲಿಸಲಾಗಿದೆ';
  }

  @override
  String get btnDeleteGroup => 'ಈ ಗುಂಪನ್ನು ತೆಗೆಯಿರಿ';

  @override
  String delGroupTitle(Object name) {
    return '$name ಗುಂಪನ್ನು ತೆಗೆಯಬೇಕೇ?';
  }

  @override
  String get delGroupBody => 'ಈ ಗುಂಪಿನಲ್ಲಿ ಯಾರೂ ಇಲ್ಲ. ಗುಂಪನ್ನು ತೆಗೆಯಲಾಗುತ್ತದೆ.';

  @override
  String get delGroupNotEmpty =>
      'ಈ ಗುಂಪಿನಲ್ಲಿ ಇನ್ನೂ ಬಾಡಿಗೆದಾರರು ಇದ್ದಾರೆ. ಮೊದಲು ಅವರನ್ನು ಬೇರೆ ಗುಂಪಿಗೆ ಸರಿಸಿ, ನಂತರ ಗುಂಪನ್ನು ತೆಗೆಯಿರಿ.';

  @override
  String get delGroupYes => 'ಹೌದು, ತೆಗೆಯಿರಿ';

  @override
  String get delGroupNo => 'ಇಲ್ಲ, ಇರಲಿ';

  @override
  String groupDeleted(Object name) {
    return '$name ಗುಂಪನ್ನು ತೆಗೆಯಲಾಗಿದೆ';
  }

  @override
  String get fGroup => 'ಗುಂಪು';

  @override
  String get fGroupHint => 'ಈ ಬಾಡಿಗೆದಾರರು ಯಾವ ಗುಂಪಿನಲ್ಲಿ ಇರಬೇಕು ಎಂದು ಆರಿಸಿ.';

  @override
  String inGroup(Object name) {
    return 'ಗುಂಪು: $name';
  }

  @override
  String get btnMoveGroup => 'ಬೇರೆ ಗುಂಪಿಗೆ ಸರಿಸಿ';

  @override
  String moveTitle(Object name) {
    return '$name ಅವರನ್ನು ಸರಿಸಿ';
  }

  @override
  String get moveBody => 'ಈ ಬಾಡಿಗೆದಾರರಿಗೆ ಗುಂಪು ಆರಿಸಿ.';

  @override
  String movedTo(Object name, Object group) {
    return '$name ಅವರನ್ನು $group ಗುಂಪಿಗೆ ಸರಿಸಲಾಗಿದೆ';
  }

  @override
  String get helpGroup =>
      'ಈ ಗುಂಪಿನ ಬಾಡಿಗೆದಾರರು ಇಲ್ಲಿ ಇದ್ದಾರೆ. ವಿವರಕ್ಕಾಗಿ ಹೆಸರನ್ನು ಒತ್ತಿ. ಇಲ್ಲಿಂದಲೇ ಗುಂಪಿನ ಹೆಸರು ಬದಲಿಸಬಹುದು ಅಥವಾ ಗುಂಪನ್ನು ತೆಗೆಯಬಹುದು.';

  @override
  String get helpAddGroup =>
      'ಗುಂಪಿಗೆ ಒಂದು ಹೆಸರು ಬರೆದು \'ಉಳಿಸಿ\' ಒತ್ತಿ. ಹೆಸರನ್ನು ನಂತರ ಬದಲಿಸಬಹುದು.';

  @override
  String get helpRenameGroup =>
      'ಹೊಸ ಹೆಸರು ಬರೆದು \'ಉಳಿಸಿ\' ಒತ್ತಿ. ಬಾಡಿಗೆದಾರರು ಅದೇ ಗುಂಪಿನಲ್ಲಿ ಇರುತ್ತಾರೆ.';

  @override
  String get setTitle => 'ಸೆಟ್ಟಿಂಗ್ಸ್';

  @override
  String get setLang => 'ಭಾಷೆ';

  @override
  String get setTips => 'ಸಲಹೆಗಳನ್ನು ತೋರಿಸಿ';

  @override
  String get setWelcome => 'ಸ್ವಾಗತ ಮಾರ್ಗದರ್ಶನ ಮತ್ತೆ ತೋರಿಸಿ';

  @override
  String get setAbout => 'ಬಗ್ಗೆ';

  @override
  String get version => 'ಆವೃತ್ತಿ 1.0';

  @override
  String get archTitle => 'ಆರ್ಕೈವ್';

  @override
  String get archNote =>
      'ತೆಗೆದ ಬಾಡಿಗೆದಾರರು ಇಲ್ಲಿ ಇರುತ್ತಾರೆ. ನೋಡಬಹುದು, ಏನನ್ನೂ ಬದಲಿಸಲು ಆಗುವುದಿಲ್ಲ.';

  @override
  String archRemovedOn(Object month) {
    return '$month ರಲ್ಲಿ ತೆಗೆಯಲಾಗಿದೆ';
  }

  @override
  String get archEmpty => 'ಆರ್ಕೈವ್ ಖಾಲಿ ಇದೆ.';

  @override
  String get w1T => 'ಸ್ವಾಗತ!';

  @override
  String get w1B =>
      'ಯಾರು ಬಾಡಿಗೆ ಕೊಟ್ಟಿದ್ದಾರೆ, ಯಾರು ಕೊಟ್ಟಿಲ್ಲ ಎಂದು ನೆನಪಿಡಲು ಈ ಆಪ್ ಸಹಾಯ ಮಾಡುತ್ತದೆ.';

  @override
  String get w2T => 'ಬಾಡಿಗೆದಾರರನ್ನು ಸೇರಿಸಿ';

  @override
  String get w2B => 'ಹೆಸರು ಮತ್ತು ತಿಂಗಳ ಬಾಡಿಗೆ ಬರೆಯಿರಿ. ಅಷ್ಟೇ.';

  @override
  String get w3T => 'ಬಂದ ಹಣ ಬರೆಯಿರಿ';

  @override
  String get w3B =>
      'ಬಾಡಿಗೆದಾರರು ಹಣ ಕೊಟ್ಟಾಗ ಅವರ ಹೆಸರನ್ನು ಒತ್ತಿ ಮೊತ್ತ ಬರೆಯಿರಿ. ಉಳಿದದ್ದನ್ನು ಆಪ್ ಬಣ್ಣ ಮತ್ತು ಪದಗಳಲ್ಲಿ ತೋರಿಸುತ್ತದೆ.';

  @override
  String get next => 'ಮುಂದೆ';

  @override
  String get skip => 'ಬಿಟ್ಟುಬಿಡಿ';

  @override
  String get start => 'ಶುರು ಮಾಡೋಣ';

  @override
  String get helpHome =>
      'ಗುಂಪನ್ನು ಒತ್ತಿದರೆ ಅದರ ಬಾಡಿಗೆದಾರರು ಕಾಣುತ್ತಾರೆ. ಗುಂಪಿನ ಮೇಲಿನ ಬಣ್ಣದ ಲೇಬಲ್ ಅತಿ ತುರ್ತಿನ ಬಾಡಿಗೆದಾರರನ್ನು ತೋರಿಸುತ್ತದೆ. ಬಂದ ಹಣ ಬರೆಯಲು ಬಾಡಿಗೆದಾರರನ್ನು ತೆರೆಯಿರಿ.';

  @override
  String get helpAdd =>
      'ಮೂರು ಬಾಕ್ಸ್‌ಗಳನ್ನು ತುಂಬಿ \'ಉಳಿಸಿ\' ಒತ್ತಿ. ಬಾಡಿಗೆಯನ್ನು ನಂತರ ಬದಲಿಸಬಹುದು.';

  @override
  String get helpDetail =>
      'ಇಲ್ಲಿ ಈ ಬಾಡಿಗೆದಾರರ ಪ್ರತಿ ತಿಂಗಳ ವಿವರ ಇದೆ. ಹಣ ಬಂದಾಗ ನೀಲಿ ಬಟನ್ ಒತ್ತಿ.';

  @override
  String get helpPay =>
      'ಎಷ್ಟು ಹಣ ಬಂದಿದೆ ಎಂದು ಬರೆದು \'ಉಳಿಸಿ\' ಒತ್ತಿ. ತಪ್ಪಾದರೆ ತಕ್ಷಣ \'ಹಿಂದಕ್ಕೆ\' ಒತ್ತಿ.';

  @override
  String get helpRent =>
      'ಹೊಸ ಬಾಡಿಗೆ ಮುಂದಿನ ತಿಂಗಳಿಂದ ಶುರುವಾಗುತ್ತದೆ. ಈ ತಿಂಗಳ ಬಾಡಿಗೆ ಬದಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get helpSettings =>
      'ಇಲ್ಲಿ ಭಾಷೆ ಬದಲಿಸಬಹುದು. English ಅಥವಾ ಕನ್ನಡ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get helpArchive =>
      'ತೆಗೆದ ಬಾಡಿಗೆದಾರರು ನಿಮ್ಮ ದಾಖಲೆಗಾಗಿ ಇಲ್ಲಿ ಇರುತ್ತಾರೆ. ನೋಡಬಹುದು ಅಷ್ಟೇ.';

  @override
  String get legendTitle => 'ಲೇಬಲ್‌ಗಳ ಅರ್ಥವೇನು?';

  @override
  String get stPending => 'ಕಾಯುತ್ತಿದೆ';

  @override
  String get stCompleted => 'ಸಮಯಕ್ಕೆ ಪೂರ್ಣ';

  @override
  String get stLateCompleted => 'ತಡವಾಗಿ ಪೂರ್ಣ';

  @override
  String get stPartial => 'ಸ್ವಲ್ಪ ಬಂದಿದೆ';

  @override
  String get stPartialOverdue => 'ಸ್ವಲ್ಪ ಬಂದಿದೆ, ತಡ';

  @override
  String get stOverdue => 'ತಡವಾಗಿದೆ';

  @override
  String get stBacklog => 'ಹಳೆಯ ಬಾಕಿ';

  @override
  String get stBacklogCleared => 'ಹಳೆಯ ಬಾಕಿ ಬಂದಿದೆ';

  @override
  String get sdPending => 'ಇನ್ನೂ ಹಣ ಬಂದಿಲ್ಲ, ಆದರೆ ಇನ್ನೂ ಸಮಯ ಇದೆ.';

  @override
  String get sdCompleted => 'ಕೊನೆಯ ದಿನದೊಳಗೆ ಪೂರ್ತಿ ಹಣ ಬಂದಿದೆ.';

  @override
  String get sdLateCompleted =>
      'ಕೊನೆಯ ದಿನದ ನಂತರ, ಆದರೆ ತಿಂಗಳೊಳಗೆ ಪೂರ್ತಿ ಹಣ ಬಂದಿದೆ.';

  @override
  String get sdPartial => 'ಸ್ವಲ್ಪ ಹಣ ಬಂದಿದೆ. ಕೊನೆಯ ದಿನ ಇನ್ನೂ ಬಂದಿಲ್ಲ.';

  @override
  String get sdPartialOverdue => 'ಸ್ವಲ್ಪ ಹಣ ಮಾತ್ರ ಬಂದಿದೆ, ಕೊನೆಯ ದಿನ ಮುಗಿದಿದೆ.';

  @override
  String get sdOverdue => 'ಒಂದು ರೂಪಾಯಿಯೂ ಬಂದಿಲ್ಲ, ಕೊನೆಯ ದಿನ ಮುಗಿದಿದೆ.';

  @override
  String get sdBacklog => 'ತಿಂಗಳು ಮುಗಿದರೂ ಪೂರ್ತಿ ಬಾಡಿಗೆ ಬಂದಿಲ್ಲ.';

  @override
  String get sdBacklogCleared => 'ತಿಂಗಳು ಮುಗಿದ ನಂತರ ಪೂರ್ತಿ ಬಾಡಿಗೆ ಬಂದಿದೆ.';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'ಜನವರಿ',
      '2': 'ಫೆಬ್ರವರಿ',
      '3': 'ಮಾರ್ಚ್',
      '4': 'ಏಪ್ರಿಲ್',
      '5': 'ಮೇ',
      '6': 'ಜೂನ್',
      '7': 'ಜುಲೈ',
      '8': 'ಆಗಸ್ಟ್',
      '9': 'ಸೆಪ್ಟೆಂಬರ್',
      '10': 'ಅಕ್ಟೋಬರ್',
      '11': 'ನವೆಂಬರ್',
      '12': 'ಡಿಸೆಂಬರ್',
      'other': '',
    });
    return '$_temp0';
  }
}
