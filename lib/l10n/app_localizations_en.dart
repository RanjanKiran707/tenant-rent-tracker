// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rent Book';

  @override
  String get langToggle => 'ಕನ್ನಡ';

  @override
  String get helpTooltip => 'Help';

  @override
  String get ok => 'OK';

  @override
  String get retry => 'Try again';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String thisMonth(Object month) {
    return 'This month – $month';
  }

  @override
  String get collected => 'Money received';

  @override
  String get toCollect => 'Still to receive';

  @override
  String tenantsCount(Object count) {
    return 'Tenants ($count)';
  }

  @override
  String get sortNote => 'People who need attention are at the top.';

  @override
  String get noTenants =>
      'No tenants yet. Tap the big blue button to add your first tenant.';

  @override
  String get addTenantBtn => '+ Add a tenant';

  @override
  String rentPerMonth(Object amount) {
    return '₹$amount per month';
  }

  @override
  String oldDues(Object amount) {
    return 'Old dues: ₹$amount';
  }

  @override
  String get addTitle => 'Add a tenant';

  @override
  String get fName => 'Tenant\'s name';

  @override
  String get fNameHint => 'Type the person\'s name.';

  @override
  String get fRent => 'Rent per month (₹)';

  @override
  String get fRentHint => 'Numbers only, for example 8000.';

  @override
  String get fDue => 'Pay by which day of the month?';

  @override
  String get fDueHint =>
      'If rent is not paid by this day, it is shown as late.';

  @override
  String get fStart => 'Starting month';

  @override
  String get fStartHint => 'The first month you want to keep a record for.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get undo => 'Undo';

  @override
  String tenantAdded(Object name) {
    return '$name added';
  }

  @override
  String get errName => 'Please type a name.';

  @override
  String get errRent => 'Please type the rent amount (a number more than 0).';

  @override
  String get errDueDay => 'Please choose a day from 1 to 31.';

  @override
  String get errStartMonth => 'Please choose a valid starting month.';

  @override
  String get errStartFuture => 'The starting month cannot be in the future.';

  @override
  String get errAmount => 'Please type an amount more than 0.';

  @override
  String get errDate => 'Please choose a valid date.';

  @override
  String get errDateFuture => 'The date cannot be in the future.';

  @override
  String get errTenantNotFound => 'This tenant could not be found.';

  @override
  String get errTenantDeleted => 'This tenant has been removed.';

  @override
  String get errLanguage => 'This language is not available.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String received(Object paid, Object total) {
    return 'Received ₹$paid of ₹$total';
  }

  @override
  String balance(Object amount) {
    return 'Balance: ₹$amount';
  }

  @override
  String dueDate(Object date) {
    return 'Pay by $date';
  }

  @override
  String get btnPayOld => 'Record old dues received';

  @override
  String get btnPayMonth => 'Record money for this month';

  @override
  String get payMonthHint =>
      'To pay old dues, choose an older month from the list.';

  @override
  String get btnPay => 'Money received';

  @override
  String get btnRent => 'Change rent';

  @override
  String get btnDelete => 'Remove this tenant';

  @override
  String get history => 'Earlier months';

  @override
  String get noHistory => 'No earlier months yet.';

  @override
  String pendingRentNote(Object month, Object amount) {
    return 'From $month, rent will be ₹$amount.';
  }

  @override
  String extraNote(Object amount) {
    return 'Extra ₹$amount received (noted only).';
  }

  @override
  String get payTitle => 'Money received';

  @override
  String get payAmount => 'How much did you receive? (₹)';

  @override
  String payFull(Object amount) {
    return 'Fill the full balance (₹$amount)';
  }

  @override
  String get payDate => 'On which date?';

  @override
  String get payMonth => 'For which month?';

  @override
  String payAfter(Object amount) {
    return 'After this, the balance will be ₹$amount.';
  }

  @override
  String get payAfterDone => 'After this, the month is fully paid';

  @override
  String payExtra(Object amount) {
    return '₹$amount extra will be noted. It is not added to next month.';
  }

  @override
  String paymentSaved(Object amount) {
    return '₹$amount saved';
  }

  @override
  String get rentTitle => 'Change rent';

  @override
  String rentCurrent(Object amount) {
    return 'Current rent: ₹$amount';
  }

  @override
  String get rentNew => 'New rent per month (₹)';

  @override
  String rentNotice(Object from, Object current, Object amount) {
    return 'This applies from $from. $current stays at ₹$amount.';
  }

  @override
  String rentUp(Object amount) {
    return 'Rent goes up by ₹$amount';
  }

  @override
  String rentDown(Object amount) {
    return 'Rent goes down by ₹$amount';
  }

  @override
  String get rentSame => 'This is the same as the current rent.';

  @override
  String rentSaved(Object month) {
    return 'Rent will change from $month';
  }

  @override
  String delTitle(Object name) {
    return 'Remove $name?';
  }

  @override
  String delBody(Object name) {
    return '$name will be moved to the archive. Nothing is erased. All records are kept safely.';
  }

  @override
  String delOwed(Object amount) {
    return 'Please note: ₹$amount is still unpaid.';
  }

  @override
  String get delYes => 'Yes, remove';

  @override
  String get delNo => 'No, keep';

  @override
  String removed(Object name) {
    return '$name removed';
  }

  @override
  String get setTitle => 'Settings';

  @override
  String get setLang => 'Language';

  @override
  String get setTips => 'Show tips';

  @override
  String get setWelcome => 'Show the welcome guide again';

  @override
  String get setAbout => 'About';

  @override
  String get version => 'Version 1.0';

  @override
  String get archTitle => 'Archive';

  @override
  String get archNote =>
      'Removed tenants are kept here. You can only look, you cannot change anything.';

  @override
  String archRemovedOn(Object month) {
    return 'Removed in $month';
  }

  @override
  String get archEmpty => 'The archive is empty.';

  @override
  String get w1T => 'Welcome!';

  @override
  String get w1B =>
      'This app helps you remember who has paid rent and who has not.';

  @override
  String get w2T => 'Add your tenants';

  @override
  String get w2B => 'Type the name and the monthly rent. That is all.';

  @override
  String get w3T => 'Write down money received';

  @override
  String get w3B =>
      'When a tenant pays, tap their name and type the amount. The app shows the rest with colours and words.';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get start => 'Let\'s start';

  @override
  String get helpHome =>
      'Tap a tenant\'s name to see details or to write down money received. The coloured tags show who has paid.';

  @override
  String get helpAdd =>
      'Fill the three boxes and press Save. You can change the rent later.';

  @override
  String get helpDetail =>
      'Here you see every month for this tenant. Press the blue button when money is received.';

  @override
  String get helpPay =>
      'Type how much money you received and press Save. If you made a mistake, press Undo right after.';

  @override
  String get helpRent =>
      'The new rent starts from next month. This month\'s rent does not change.';

  @override
  String get helpSettings =>
      'Change the language here. Choose English or ಕನ್ನಡ.';

  @override
  String get helpArchive =>
      'Removed tenants are kept here for your records. You can only look.';

  @override
  String get legendTitle => 'What do the tags mean?';

  @override
  String get stPending => 'Pending';

  @override
  String get stCompleted => 'Paid on time';

  @override
  String get stLateCompleted => 'Paid late';

  @override
  String get stPartial => 'Part paid';

  @override
  String get stPartialOverdue => 'Part paid, late';

  @override
  String get stOverdue => 'Overdue';

  @override
  String get stBacklog => 'Old due';

  @override
  String get stBacklogCleared => 'Old due paid';

  @override
  String get sdPending => 'Nothing paid yet, but there is still time.';

  @override
  String get sdCompleted => 'Fully paid on or before the last day.';

  @override
  String get sdLateCompleted =>
      'Fully paid after the last day, but within the month.';

  @override
  String get sdPartial => 'Some money received. The last day has not come yet.';

  @override
  String get sdPartialOverdue =>
      'Only some money received and the last day has passed.';

  @override
  String get sdOverdue => 'Nothing received and the last day has passed.';

  @override
  String get sdBacklog => 'The month ended and the full rent was not received.';

  @override
  String get sdBacklogCleared =>
      'The full rent was received after the month had ended.';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'Jan',
      '2': 'Feb',
      '3': 'Mar',
      '4': 'Apr',
      '5': 'May',
      '6': 'Jun',
      '7': 'Jul',
      '8': 'Aug',
      '9': 'Sep',
      '10': 'Oct',
      '11': 'Nov',
      '12': 'Dec',
      'other': '',
    });
    return '$_temp0';
  }
}
