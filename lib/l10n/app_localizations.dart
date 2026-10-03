import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kn'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Rent Book'**
  String get appTitle;

  /// No description provided for @langToggle.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ'**
  String get langToggle;

  /// No description provided for @helpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTooltip;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month – {month}'**
  String thisMonth(Object month);

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Money received'**
  String get collected;

  /// No description provided for @toCollect.
  ///
  /// In en, this message translates to:
  /// **'Still to receive'**
  String get toCollect;

  /// No description provided for @tenantsCount.
  ///
  /// In en, this message translates to:
  /// **'Tenants ({count})'**
  String tenantsCount(Object count);

  /// No description provided for @sortNote.
  ///
  /// In en, this message translates to:
  /// **'People who need attention are at the top.'**
  String get sortNote;

  /// No description provided for @noTenants.
  ///
  /// In en, this message translates to:
  /// **'No tenants yet. Tap the big blue button to add your first tenant.'**
  String get noTenants;

  /// No description provided for @addTenantBtn.
  ///
  /// In en, this message translates to:
  /// **'+ Add a tenant'**
  String get addTenantBtn;

  /// No description provided for @rentPerMonth.
  ///
  /// In en, this message translates to:
  /// **'₹{amount} per month'**
  String rentPerMonth(Object amount);

  /// No description provided for @oldDues.
  ///
  /// In en, this message translates to:
  /// **'Old dues: ₹{amount}'**
  String oldDues(Object amount);

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a tenant'**
  String get addTitle;

  /// No description provided for @fName.
  ///
  /// In en, this message translates to:
  /// **'Tenant\'s name'**
  String get fName;

  /// No description provided for @fNameHint.
  ///
  /// In en, this message translates to:
  /// **'Type the person\'s name.'**
  String get fNameHint;

  /// No description provided for @fRent.
  ///
  /// In en, this message translates to:
  /// **'Rent per month (₹)'**
  String get fRent;

  /// No description provided for @fRentHint.
  ///
  /// In en, this message translates to:
  /// **'Numbers only, for example 8000.'**
  String get fRentHint;

  /// No description provided for @fDue.
  ///
  /// In en, this message translates to:
  /// **'Pay by which day of the month?'**
  String get fDue;

  /// No description provided for @fDueHint.
  ///
  /// In en, this message translates to:
  /// **'If rent is not paid by this day, it is shown as late.'**
  String get fDueHint;

  /// No description provided for @fStart.
  ///
  /// In en, this message translates to:
  /// **'Starting month'**
  String get fStart;

  /// No description provided for @fStartHint.
  ///
  /// In en, this message translates to:
  /// **'The first month you want to keep a record for.'**
  String get fStartHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @tenantAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String tenantAdded(Object name);

  /// No description provided for @errName.
  ///
  /// In en, this message translates to:
  /// **'Please type a name.'**
  String get errName;

  /// No description provided for @errRent.
  ///
  /// In en, this message translates to:
  /// **'Please type the rent amount (a number more than 0).'**
  String get errRent;

  /// No description provided for @errDueDay.
  ///
  /// In en, this message translates to:
  /// **'Please choose a day from 1 to 31.'**
  String get errDueDay;

  /// No description provided for @errStartMonth.
  ///
  /// In en, this message translates to:
  /// **'Please choose a valid starting month.'**
  String get errStartMonth;

  /// No description provided for @errStartFuture.
  ///
  /// In en, this message translates to:
  /// **'The starting month cannot be in the future.'**
  String get errStartFuture;

  /// No description provided for @errAmount.
  ///
  /// In en, this message translates to:
  /// **'Please type an amount more than 0.'**
  String get errAmount;

  /// No description provided for @errDate.
  ///
  /// In en, this message translates to:
  /// **'Please choose a valid date.'**
  String get errDate;

  /// No description provided for @errDateFuture.
  ///
  /// In en, this message translates to:
  /// **'The date cannot be in the future.'**
  String get errDateFuture;

  /// No description provided for @errTenantNotFound.
  ///
  /// In en, this message translates to:
  /// **'This tenant could not be found.'**
  String get errTenantNotFound;

  /// No description provided for @errTenantDeleted.
  ///
  /// In en, this message translates to:
  /// **'This tenant has been removed.'**
  String get errTenantDeleted;

  /// No description provided for @errGroupName.
  ///
  /// In en, this message translates to:
  /// **'Please type a group name.'**
  String get errGroupName;

  /// No description provided for @errGroupNameTaken.
  ///
  /// In en, this message translates to:
  /// **'A group with this name already exists.'**
  String get errGroupNameTaken;

  /// No description provided for @errGroupNotFound.
  ///
  /// In en, this message translates to:
  /// **'This group could not be found.'**
  String get errGroupNotFound;

  /// No description provided for @errGroupDeleted.
  ///
  /// In en, this message translates to:
  /// **'This group has been deleted.'**
  String get errGroupDeleted;

  /// No description provided for @errGroupLocked.
  ///
  /// In en, this message translates to:
  /// **'The Uncategorized group cannot be changed or deleted.'**
  String get errGroupLocked;

  /// No description provided for @errGroupNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'This group still has tenants. Move them to another group first.'**
  String get errGroupNotEmpty;

  /// No description provided for @errLanguage.
  ///
  /// In en, this message translates to:
  /// **'This language is not available.'**
  String get errLanguage;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received ₹{paid} of ₹{total}'**
  String received(Object paid, Object total);

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance: ₹{amount}'**
  String balance(Object amount);

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Pay by {date}'**
  String dueDate(Object date);

  /// No description provided for @btnPayOld.
  ///
  /// In en, this message translates to:
  /// **'Record old dues received'**
  String get btnPayOld;

  /// No description provided for @btnPayMonth.
  ///
  /// In en, this message translates to:
  /// **'Record money for this month'**
  String get btnPayMonth;

  /// No description provided for @payMonthHint.
  ///
  /// In en, this message translates to:
  /// **'To pay old dues, choose an older month from the list.'**
  String get payMonthHint;

  /// No description provided for @btnPay.
  ///
  /// In en, this message translates to:
  /// **'Money received'**
  String get btnPay;

  /// No description provided for @btnRent.
  ///
  /// In en, this message translates to:
  /// **'Change rent'**
  String get btnRent;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove this tenant'**
  String get btnDelete;

  /// No description provided for @btnEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get btnEditName;

  /// No description provided for @editNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit tenant\'s name'**
  String get editNameTitle;

  /// No description provided for @nameSaved.
  ///
  /// In en, this message translates to:
  /// **'Name changed to {name}'**
  String nameSaved(Object name);

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'Nothing in history yet.'**
  String get noHistory;

  /// No description provided for @noPendingDue.
  ///
  /// In en, this message translates to:
  /// **'No pending due'**
  String get noPendingDue;

  /// No description provided for @pendingRentNote.
  ///
  /// In en, this message translates to:
  /// **'From {month}, rent will be ₹{amount}.'**
  String pendingRentNote(Object month, Object amount);

  /// No description provided for @extraNote.
  ///
  /// In en, this message translates to:
  /// **'Extra ₹{amount} received (noted only).'**
  String extraNote(Object amount);

  /// No description provided for @payTitle.
  ///
  /// In en, this message translates to:
  /// **'Money received'**
  String get payTitle;

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'How much did you receive? (₹)'**
  String get payAmount;

  /// No description provided for @payFull.
  ///
  /// In en, this message translates to:
  /// **'Fill the full balance (₹{amount})'**
  String payFull(Object amount);

  /// No description provided for @payDate.
  ///
  /// In en, this message translates to:
  /// **'On which date?'**
  String get payDate;

  /// No description provided for @payMonth.
  ///
  /// In en, this message translates to:
  /// **'For which month?'**
  String get payMonth;

  /// No description provided for @payAfter.
  ///
  /// In en, this message translates to:
  /// **'After this, the balance will be ₹{amount}.'**
  String payAfter(Object amount);

  /// No description provided for @payAfterDone.
  ///
  /// In en, this message translates to:
  /// **'After this, the month is fully paid'**
  String get payAfterDone;

  /// No description provided for @payExtra.
  ///
  /// In en, this message translates to:
  /// **'₹{amount} extra will be noted. It is not added to next month.'**
  String payExtra(Object amount);

  /// No description provided for @paymentSaved.
  ///
  /// In en, this message translates to:
  /// **'₹{amount} saved'**
  String paymentSaved(Object amount);

  /// No description provided for @rentTitle.
  ///
  /// In en, this message translates to:
  /// **'Change rent'**
  String get rentTitle;

  /// No description provided for @rentCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current rent: ₹{amount}'**
  String rentCurrent(Object amount);

  /// No description provided for @rentNew.
  ///
  /// In en, this message translates to:
  /// **'New rent per month (₹)'**
  String get rentNew;

  /// No description provided for @rentNotice.
  ///
  /// In en, this message translates to:
  /// **'This applies from {from}. {current} stays at ₹{amount}.'**
  String rentNotice(Object from, Object current, Object amount);

  /// No description provided for @rentUp.
  ///
  /// In en, this message translates to:
  /// **'Rent goes up by ₹{amount}'**
  String rentUp(Object amount);

  /// No description provided for @rentDown.
  ///
  /// In en, this message translates to:
  /// **'Rent goes down by ₹{amount}'**
  String rentDown(Object amount);

  /// No description provided for @rentSame.
  ///
  /// In en, this message translates to:
  /// **'This is the same as the current rent.'**
  String get rentSame;

  /// No description provided for @rentSaved.
  ///
  /// In en, this message translates to:
  /// **'Rent will change from {month}'**
  String rentSaved(Object month);

  /// No description provided for @delTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String delTitle(Object name);

  /// No description provided for @delBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be moved to the archive. Nothing is erased. All records are kept safely.'**
  String delBody(Object name);

  /// No description provided for @delOwed.
  ///
  /// In en, this message translates to:
  /// **'Please note: ₹{amount} is still unpaid.'**
  String delOwed(Object amount);

  /// No description provided for @delYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, remove'**
  String get delYes;

  /// No description provided for @delNo.
  ///
  /// In en, this message translates to:
  /// **'No, keep'**
  String get delNo;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String removed(Object name);

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @groupsCount.
  ///
  /// In en, this message translates to:
  /// **'Groups ({count})'**
  String groupsCount(Object count);

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups yet. Add a group, then open it to add your tenants.'**
  String get noGroups;

  /// No description provided for @groupTenantsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tenants'**
  String groupTenantsCount(Object count);

  /// No description provided for @groupOneTenant.
  ///
  /// In en, this message translates to:
  /// **'1 tenant'**
  String get groupOneTenant;

  /// No description provided for @groupNoTenants.
  ///
  /// In en, this message translates to:
  /// **'No tenants yet'**
  String get groupNoTenants;

  /// No description provided for @groupToReceive.
  ///
  /// In en, this message translates to:
  /// **'To receive: ₹{amount}'**
  String groupToReceive(Object amount);

  /// No description provided for @noTenantsInGroup.
  ///
  /// In en, this message translates to:
  /// **'No tenants in this group yet.'**
  String get noTenantsInGroup;

  /// No description provided for @defaultGroupNote.
  ///
  /// In en, this message translates to:
  /// **'Tenants without a group are kept here.'**
  String get defaultGroupNote;

  /// No description provided for @addGroupBtn.
  ///
  /// In en, this message translates to:
  /// **'+ Add a group'**
  String get addGroupBtn;

  /// No description provided for @addGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a group'**
  String get addGroupTitle;

  /// No description provided for @fGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get fGroupName;

  /// No description provided for @fGroupNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Block A or Ground floor.'**
  String get fGroupNameHint;

  /// No description provided for @groupAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} group added'**
  String groupAdded(Object name);

  /// No description provided for @renameGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename group'**
  String get renameGroupTitle;

  /// No description provided for @btnRenameGroup.
  ///
  /// In en, this message translates to:
  /// **'Rename group'**
  String get btnRenameGroup;

  /// No description provided for @groupRenamed.
  ///
  /// In en, this message translates to:
  /// **'Group renamed to {name}'**
  String groupRenamed(Object name);

  /// No description provided for @btnDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete this group'**
  String get btnDeleteGroup;

  /// No description provided for @delGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String delGroupTitle(Object name);

  /// No description provided for @delGroupBody.
  ///
  /// In en, this message translates to:
  /// **'This group has no tenants. It will be removed.'**
  String get delGroupBody;

  /// No description provided for @delGroupNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'This group still has tenants. Move them to another group first, then delete it.'**
  String get delGroupNotEmpty;

  /// No description provided for @delGroupYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete'**
  String get delGroupYes;

  /// No description provided for @delGroupNo.
  ///
  /// In en, this message translates to:
  /// **'No, keep'**
  String get delGroupNo;

  /// No description provided for @groupDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} group deleted'**
  String groupDeleted(Object name);

  /// No description provided for @fGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get fGroup;

  /// No description provided for @fGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Choose where this tenant should be listed.'**
  String get fGroupHint;

  /// No description provided for @inGroup.
  ///
  /// In en, this message translates to:
  /// **'Group: {name}'**
  String inGroup(Object name);

  /// No description provided for @btnMoveGroup.
  ///
  /// In en, this message translates to:
  /// **'Move to another group'**
  String get btnMoveGroup;

  /// No description provided for @moveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move {name}'**
  String moveTitle(Object name);

  /// No description provided for @moveBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the group for this tenant.'**
  String get moveBody;

  /// No description provided for @movedTo.
  ///
  /// In en, this message translates to:
  /// **'{name} moved to {group}'**
  String movedTo(Object name, Object group);

  /// No description provided for @helpGroup.
  ///
  /// In en, this message translates to:
  /// **'These are the tenants in this group. Tap a name for details. You can also rename or delete the group here.'**
  String get helpGroup;

  /// No description provided for @helpAddGroup.
  ///
  /// In en, this message translates to:
  /// **'Type a name for the group and press Save. You can change the name later.'**
  String get helpAddGroup;

  /// No description provided for @helpRenameGroup.
  ///
  /// In en, this message translates to:
  /// **'Type the new name and press Save. Tenants stay in the group.'**
  String get helpRenameGroup;

  /// No description provided for @setTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setTitle;

  /// No description provided for @setLang.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get setLang;

  /// No description provided for @setTips.
  ///
  /// In en, this message translates to:
  /// **'Show tips'**
  String get setTips;

  /// No description provided for @setWelcome.
  ///
  /// In en, this message translates to:
  /// **'Show the welcome guide again'**
  String get setWelcome;

  /// No description provided for @setAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get setAbout;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0'**
  String get version;

  /// No description provided for @archTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archTitle;

  /// No description provided for @archNote.
  ///
  /// In en, this message translates to:
  /// **'Removed tenants are kept here. You can only look, you cannot change anything.'**
  String get archNote;

  /// No description provided for @archRemovedOn.
  ///
  /// In en, this message translates to:
  /// **'Removed in {month}'**
  String archRemovedOn(Object month);

  /// No description provided for @archEmpty.
  ///
  /// In en, this message translates to:
  /// **'The archive is empty.'**
  String get archEmpty;

  /// No description provided for @w1T.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get w1T;

  /// No description provided for @w1B.
  ///
  /// In en, this message translates to:
  /// **'This app helps you remember who has paid rent and who has not.'**
  String get w1B;

  /// No description provided for @w2T.
  ///
  /// In en, this message translates to:
  /// **'Add your tenants'**
  String get w2T;

  /// No description provided for @w2B.
  ///
  /// In en, this message translates to:
  /// **'Type the name and the monthly rent. That is all.'**
  String get w2B;

  /// No description provided for @w3T.
  ///
  /// In en, this message translates to:
  /// **'Write down money received'**
  String get w3T;

  /// No description provided for @w3B.
  ///
  /// In en, this message translates to:
  /// **'When a tenant pays, tap their name and type the amount. The app shows the rest with colours and words.'**
  String get w3B;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start'**
  String get start;

  /// No description provided for @helpHome.
  ///
  /// In en, this message translates to:
  /// **'Tap a group to see its tenants. The coloured tag on a group shows its most urgent tenant. Open a tenant to write down money received.'**
  String get helpHome;

  /// No description provided for @helpAdd.
  ///
  /// In en, this message translates to:
  /// **'Fill the three boxes and press Save. You can change the rent later.'**
  String get helpAdd;

  /// No description provided for @helpDetail.
  ///
  /// In en, this message translates to:
  /// **'Here you see every month for this tenant. Press the blue button when money is received.'**
  String get helpDetail;

  /// No description provided for @helpPay.
  ///
  /// In en, this message translates to:
  /// **'Type how much money you received and press Save. If you made a mistake, press Undo right after.'**
  String get helpPay;

  /// No description provided for @helpRent.
  ///
  /// In en, this message translates to:
  /// **'The new rent starts from next month. This month\'s rent does not change.'**
  String get helpRent;

  /// No description provided for @helpSettings.
  ///
  /// In en, this message translates to:
  /// **'Change the language here. Choose English or ಕನ್ನಡ.'**
  String get helpSettings;

  /// No description provided for @helpArchive.
  ///
  /// In en, this message translates to:
  /// **'Removed tenants are kept here for your records. You can only look.'**
  String get helpArchive;

  /// No description provided for @legendTitle.
  ///
  /// In en, this message translates to:
  /// **'What do the tags mean?'**
  String get legendTitle;

  /// No description provided for @stPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get stPending;

  /// No description provided for @stCompleted.
  ///
  /// In en, this message translates to:
  /// **'Paid on time'**
  String get stCompleted;

  /// No description provided for @stLateCompleted.
  ///
  /// In en, this message translates to:
  /// **'Paid late'**
  String get stLateCompleted;

  /// No description provided for @stPartial.
  ///
  /// In en, this message translates to:
  /// **'Part paid'**
  String get stPartial;

  /// No description provided for @stPartialOverdue.
  ///
  /// In en, this message translates to:
  /// **'Part paid, late'**
  String get stPartialOverdue;

  /// No description provided for @stOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get stOverdue;

  /// No description provided for @stBacklog.
  ///
  /// In en, this message translates to:
  /// **'Old due'**
  String get stBacklog;

  /// No description provided for @stBacklogCleared.
  ///
  /// In en, this message translates to:
  /// **'Old due paid'**
  String get stBacklogCleared;

  /// No description provided for @sdPending.
  ///
  /// In en, this message translates to:
  /// **'Nothing paid yet, but there is still time.'**
  String get sdPending;

  /// No description provided for @sdCompleted.
  ///
  /// In en, this message translates to:
  /// **'Fully paid on or before the last day.'**
  String get sdCompleted;

  /// No description provided for @sdLateCompleted.
  ///
  /// In en, this message translates to:
  /// **'Fully paid after the last day, but within the month.'**
  String get sdLateCompleted;

  /// No description provided for @sdPartial.
  ///
  /// In en, this message translates to:
  /// **'Some money received. The last day has not come yet.'**
  String get sdPartial;

  /// No description provided for @sdPartialOverdue.
  ///
  /// In en, this message translates to:
  /// **'Only some money received and the last day has passed.'**
  String get sdPartialOverdue;

  /// No description provided for @sdOverdue.
  ///
  /// In en, this message translates to:
  /// **'Nothing received and the last day has passed.'**
  String get sdOverdue;

  /// No description provided for @sdBacklog.
  ///
  /// In en, this message translates to:
  /// **'The month ended and the full rent was not received.'**
  String get sdBacklog;

  /// No description provided for @sdBacklogCleared.
  ///
  /// In en, this message translates to:
  /// **'The full rent was received after the month had ended.'**
  String get sdBacklogCleared;

  /// No description provided for @monthName.
  ///
  /// In en, this message translates to:
  /// **'{month, select, 1{Jan} 2{Feb} 3{Mar} 4{Apr} 5{May} 6{Jun} 7{Jul} 8{Aug} 9{Sep} 10{Oct} 11{Nov} 12{Dec} other{}}'**
  String monthName(String month);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
