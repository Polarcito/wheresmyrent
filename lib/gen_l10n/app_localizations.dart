import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @login_createPin.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get login_createPin;

  /// No description provided for @login_enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get login_enterPin;

  /// No description provided for @login_confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get login_confirmPin;

  /// No description provided for @login_savePin.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get login_savePin;

  /// No description provided for @login_pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get login_pinMismatch;

  /// No description provided for @login_invalidPin.
  ///
  /// In en, this message translates to:
  /// **'Invalid PIN'**
  String get login_invalidPin;

  /// No description provided for @login_unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get login_unlock;

  /// No description provided for @login_validation.
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 digits long'**
  String get login_validation;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Where’s My Rent?'**
  String get title;

  /// No description provided for @home_Logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get home_Logout;

  /// No description provided for @home_noProperties.
  ///
  /// In en, this message translates to:
  /// **'No properties have been added yet.'**
  String get home_noProperties;

  /// No description provided for @home_AddProperty.
  ///
  /// In en, this message translates to:
  /// **'Add property'**
  String get home_AddProperty;

  /// No description provided for @home_delete_property_title.
  ///
  /// In en, this message translates to:
  /// **'Delete property.'**
  String get home_delete_property_title;

  /// No description provided for @home_delete_property_body.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {level}? This action is permanent.'**
  String home_delete_property_body(String level);

  /// No description provided for @button_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get button_cancel;

  /// No description provided for @button_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get button_delete;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @language_spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get language_spanish;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @tooltip_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tooltip_settings;

  /// No description provided for @rentStatus_paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get rentStatus_paid;

  /// No description provided for @rentStatus_partial.
  ///
  /// In en, this message translates to:
  /// **'Partial payment'**
  String get rentStatus_partial;

  /// No description provided for @rentStatus_unpaid.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get rentStatus_unpaid;

  /// No description provided for @rentStatus_unknown.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get rentStatus_unknown;

  /// No description provided for @addProperty_title.
  ///
  /// In en, this message translates to:
  /// **'Add Property'**
  String get addProperty_title;

  /// No description provided for @addProperty_step1_name.
  ///
  /// In en, this message translates to:
  /// **'Property name'**
  String get addProperty_step1_name;

  /// No description provided for @addProperty_step1_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addProperty_step1_address;

  /// No description provided for @addProperty_step1_rent.
  ///
  /// In en, this message translates to:
  /// **'Monthly rent'**
  String get addProperty_step1_rent;

  /// No description provided for @addProperty_step1_dueDay.
  ///
  /// In en, this message translates to:
  /// **'Due day'**
  String get addProperty_step1_dueDay;

  /// No description provided for @addProperty_step1_startDate.
  ///
  /// In en, this message translates to:
  /// **'Contract start date:'**
  String get addProperty_step1_startDate;

  /// No description provided for @addProperty_step1_startDateNotSelected.
  ///
  /// In en, this message translates to:
  /// **'No date selected'**
  String get addProperty_step1_startDateNotSelected;

  /// No description provided for @addProperty_step1_selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get addProperty_step1_selectDate;

  /// No description provided for @addProperty_step2_tenantName.
  ///
  /// In en, this message translates to:
  /// **'Tenant\'s name'**
  String get addProperty_step2_tenantName;

  /// No description provided for @addProperty_step2_tenantEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get addProperty_step2_tenantEmail;

  /// No description provided for @addProperty_step2_tenantPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get addProperty_step2_tenantPhone;

  /// No description provided for @addProperty_step3_contractFile.
  ///
  /// In en, this message translates to:
  /// **'Contract file (optional)'**
  String get addProperty_step3_contractFile;

  /// No description provided for @addProperty_step3_fileSelected.
  ///
  /// In en, this message translates to:
  /// **'📄 File selected'**
  String get addProperty_step3_fileSelected;

  /// No description provided for @addProperty_step3_selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get addProperty_step3_selectFile;

  /// No description provided for @addProperty_step3_initialPhotos.
  ///
  /// In en, this message translates to:
  /// **'Initial property photos (optional)'**
  String get addProperty_step3_initialPhotos;

  /// No description provided for @addProperty_step3_selectPhotos.
  ///
  /// In en, this message translates to:
  /// **'Select photos'**
  String get addProperty_step3_selectPhotos;

  /// No description provided for @addProperty_button_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get addProperty_button_back;

  /// No description provided for @addProperty_button_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get addProperty_button_next;

  /// No description provided for @addProperty_button_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addProperty_button_save;

  /// No description provided for @addProperty_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get addProperty_required;

  /// No description provided for @addProperty_required_field.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get addProperty_required_field;

  /// No description provided for @addProperty_invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get addProperty_invalidNumber;

  /// No description provided for @addProperty_invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number.'**
  String get addProperty_invalidPhone;

  /// No description provided for @addProperty_selectDueDay.
  ///
  /// In en, this message translates to:
  /// **'Select a due day'**
  String get addProperty_selectDueDay;

  /// No description provided for @addProperty_invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get addProperty_invalidEmail;

  /// No description provided for @addProperty_saved.
  ///
  /// In en, this message translates to:
  /// **'Property saved'**
  String get addProperty_saved;

  /// No description provided for @addProperty_updated.
  ///
  /// In en, this message translates to:
  /// **'Property updated'**
  String get addProperty_updated;

  /// No description provided for @summary_paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get summary_paid;

  /// No description provided for @summary_missing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get summary_missing;

  /// No description provided for @summary_excess.
  ///
  /// In en, this message translates to:
  /// **'Excess'**
  String get summary_excess;

  /// No description provided for @summary_maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get summary_maintenance;

  /// No description provided for @summary_expectedRent.
  ///
  /// In en, this message translates to:
  /// **'Expected rent amount:'**
  String get summary_expectedRent;

  /// No description provided for @summary_totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total paid:'**
  String get summary_totalPaid;

  /// No description provided for @summary_amountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount due:'**
  String get summary_amountDue;

  /// No description provided for @summary_overpayment.
  ///
  /// In en, this message translates to:
  /// **'Overpayment:'**
  String get summary_overpayment;

  /// No description provided for @summary_maintenanceCosts.
  ///
  /// In en, this message translates to:
  /// **'Maintenance costs:'**
  String get summary_maintenanceCosts;

  /// No description provided for @summary_finalBalance.
  ///
  /// In en, this message translates to:
  /// **'Final balance:'**
  String get summary_finalBalance;

  /// No description provided for @summary_addPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get summary_addPayment;

  /// No description provided for @summary_addMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get summary_addMaintenance;

  /// No description provided for @summary_editExpectedRent.
  ///
  /// In en, this message translates to:
  /// **'Edit expected amount'**
  String get summary_editExpectedRent;

  /// No description provided for @payments_noPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded'**
  String get payments_noPayments;

  /// No description provided for @payments_addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add payment'**
  String get payments_addPayment;

  /// No description provided for @maintenance_noEntries.
  ///
  /// In en, this message translates to:
  /// **'No maintenance records'**
  String get maintenance_noEntries;

  /// No description provided for @maintenance_addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add maintenance'**
  String get maintenance_addEntry;

  /// No description provided for @payment_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit payment'**
  String get payment_edit;

  /// No description provided for @payment_add.
  ///
  /// In en, this message translates to:
  /// **'Add payment'**
  String get payment_add;

  /// No description provided for @payment_amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get payment_amountLabel;

  /// No description provided for @payment_noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get payment_noteLabel;

  /// No description provided for @payment_dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get payment_dateLabel;

  /// No description provided for @payment_galleryButton.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get payment_galleryButton;

  /// No description provided for @payment_cameraButton.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get payment_cameraButton;

  /// No description provided for @payment_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save payment'**
  String get payment_saveButton;

  /// No description provided for @maintenance_add.
  ///
  /// In en, this message translates to:
  /// **'Add maintenance'**
  String get maintenance_add;

  /// No description provided for @maintenance_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit maintenance'**
  String get maintenance_edit;

  /// No description provided for @maintenance_descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get maintenance_descriptionLabel;

  /// No description provided for @maintenance_amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (+ income, – expense)'**
  String get maintenance_amountLabel;

  /// No description provided for @maintenance_dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get maintenance_dateLabel;

  /// No description provided for @maintenance_galleryButton.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get maintenance_galleryButton;

  /// No description provided for @maintenance_cameraButton.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get maintenance_cameraButton;

  /// No description provided for @maintenance_saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save maintenance'**
  String get maintenance_saveButton;

  /// No description provided for @payment_deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete payment?'**
  String get payment_deleteTitle;

  /// No description provided for @payment_deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get payment_deleteMessage;

  /// No description provided for @payment_cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get payment_cancelButton;

  /// No description provided for @payment_confirmDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get payment_confirmDeleteButton;

  /// No description provided for @maintenance_deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete maintenance record?'**
  String get maintenance_deleteTitle;

  /// No description provided for @maintenance_deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get maintenance_deleteMessage;

  /// No description provided for @maintenance_cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get maintenance_cancelButton;

  /// No description provided for @maintenance_confirmDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get maintenance_confirmDeleteButton;

  /// No description provided for @editRentDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Edit expected rent'**
  String get editRentDialog_title;

  /// No description provided for @editRentDialog_label.
  ///
  /// In en, this message translates to:
  /// **'New amount'**
  String get editRentDialog_label;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @tab_summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get tab_summary;

  /// No description provided for @tab_payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get tab_payments;

  /// No description provided for @tab_maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get tab_maintenance;

  /// No description provided for @notification_title.
  ///
  /// In en, this message translates to:
  /// **'Unpaid rent'**
  String get notification_title;

  /// No description provided for @notification_body.
  ///
  /// In en, this message translates to:
  /// **'The property \"{property}\" hasn\'t been fully paid yet.'**
  String notification_body(Object property);

  /// No description provided for @notification_channel_name.
  ///
  /// In en, this message translates to:
  /// **'Rent reminder'**
  String get notification_channel_name;

  /// No description provided for @notification_channel_description.
  ///
  /// In en, this message translates to:
  /// **'Notifies when a rent is overdue and unpaid'**
  String get notification_channel_description;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @settings_showCurrency_title.
  ///
  /// In en, this message translates to:
  /// **'Show currency'**
  String get settings_showCurrency_title;

  /// No description provided for @settings_showCurrency_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Display amounts with a currency symbol and format'**
  String get settings_showCurrency_subtitle;

  /// No description provided for @settings_currencyType_label.
  ///
  /// In en, this message translates to:
  /// **'Currency type'**
  String get settings_currencyType_label;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @settings_currencyType_custom_label.
  ///
  /// In en, this message translates to:
  /// **'Custom currency code'**
  String get settings_currencyType_custom_label;

  /// No description provided for @settings_currencyType_custom_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a 3-letter code (e.g., USD)'**
  String get settings_currencyType_custom_hint;

  /// No description provided for @settings_currencyType_error_invalid.
  ///
  /// In en, this message translates to:
  /// **'Use exactly 3 letters (A–Z)'**
  String get settings_currencyType_error_invalid;

  /// No description provided for @propertyDetails_tooltip.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get propertyDetails_tooltip;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit property'**
  String get common_edit;

  /// No description provided for @year_label.
  ///
  /// In en, this message translates to:
  /// **'Year:'**
  String get year_label;

  /// No description provided for @propertyDetails_title.
  ///
  /// In en, this message translates to:
  /// **'Property information'**
  String get propertyDetails_title;

  /// No description provided for @propertyDetails_tenantName.
  ///
  /// In en, this message translates to:
  /// **'Tenant: {name}'**
  String propertyDetails_tenantName(Object name);

  /// No description provided for @propertyDetails_tenantEmail.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String propertyDetails_tenantEmail(Object email);

  /// No description provided for @propertyDetails_tenantPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String propertyDetails_tenantPhone(Object phone);

  /// No description provided for @propertyDetails_address.
  ///
  /// In en, this message translates to:
  /// **'Address: {address}'**
  String propertyDetails_address(Object address);

  /// No description provided for @propertyDetails_monthlyRent.
  ///
  /// In en, this message translates to:
  /// **'Monthly rent: {amount}'**
  String propertyDetails_monthlyRent(Object amount);

  /// No description provided for @propertyDetails_dueDay.
  ///
  /// In en, this message translates to:
  /// **'Due day: {day}'**
  String propertyDetails_dueDay(Object day);

  /// No description provided for @propertyDetails_startDate.
  ///
  /// In en, this message translates to:
  /// **'Contract start: {date}'**
  String propertyDetails_startDate(Object date);

  /// No description provided for @propertyDetails_endDate.
  ///
  /// In en, this message translates to:
  /// **'Contract end: {date}'**
  String propertyDetails_endDate(Object date);

  /// No description provided for @propertyDetails_viewContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get propertyDetails_viewContract;

  /// No description provided for @propertyDetails_viewPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get propertyDetails_viewPhotos;

  /// No description provided for @updateRent_title.
  ///
  /// In en, this message translates to:
  /// **'Apply new rent?'**
  String get updateRent_title;

  /// No description provided for @updateRent_body.
  ///
  /// In en, this message translates to:
  /// **'You changed the rent from {oldRent} to {newRent}.\n\nDo you want to apply this new value to future months that are not due yet?'**
  String updateRent_body(Object newRent, Object oldRent);

  /// No description provided for @updateRent_appliedSnack.
  ///
  /// In en, this message translates to:
  /// **'New rent applied to future months.'**
  String get updateRent_appliedSnack;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
