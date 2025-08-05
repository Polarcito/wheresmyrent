// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login_createPin => 'Create PIN';

  @override
  String get login_enterPin => 'Enter PIN';

  @override
  String get login_confirmPin => 'Confirm PIN';

  @override
  String get login_savePin => 'Save PIN';

  @override
  String get login_pinMismatch => 'PINs do not match';

  @override
  String get login_invalidPin => 'Invalid PIN';

  @override
  String get login_unlock => 'Unlock';

  @override
  String get login_validation => 'PIN must be at least 4 digits long';

  @override
  String get title => 'Where’s My Rent?';

  @override
  String get home_Logout => 'Logout';

  @override
  String get home_noProperties => 'No properties have been added yet.';

  @override
  String get home_AddProperty => 'Add property';

  @override
  String get home_delete_property_title => 'Delete property.';

  @override
  String home_delete_property_body(String level) {
    return 'Are you sure you want to delete $level? This action is permanent.';
  }

  @override
  String get button_cancel => 'Cancel';

  @override
  String get button_delete => 'Delete';

  @override
  String get settings_title => 'Settings';

  @override
  String get language_spanish => 'Spanish';

  @override
  String get language_english => 'English';

  @override
  String get tooltip_settings => 'Settings';

  @override
  String get rentStatus_paid => 'Paid';

  @override
  String get rentStatus_partial => 'Partial payment';

  @override
  String get rentStatus_unpaid => 'Pending';

  @override
  String get rentStatus_unknown => 'No data';

  @override
  String get addProperty_title => 'Add Property';

  @override
  String get addProperty_step1_name => 'Property name';

  @override
  String get addProperty_step1_address => 'Address';

  @override
  String get addProperty_step1_rent => 'Monthly rent';

  @override
  String get addProperty_step1_dueDay => 'Due day';

  @override
  String get addProperty_step1_startDate => 'Contract start date:';

  @override
  String get addProperty_step1_startDateNotSelected => 'No date selected';

  @override
  String get addProperty_step1_selectDate => 'Select date';

  @override
  String get addProperty_step2_tenantName => 'Tenant\'s name';

  @override
  String get addProperty_step2_tenantEmail => 'Email';

  @override
  String get addProperty_step2_tenantPhone => 'Phone';

  @override
  String get addProperty_step3_contractFile => 'Contract file (optional)';

  @override
  String get addProperty_step3_fileSelected => '📄 File selected';

  @override
  String get addProperty_step3_selectFile => 'Select file';

  @override
  String get addProperty_step3_initialPhotos => 'Initial property photos (optional)';

  @override
  String get addProperty_step3_selectPhotos => 'Select photos';

  @override
  String get addProperty_button_back => 'Back';

  @override
  String get addProperty_button_next => 'Next';

  @override
  String get addProperty_button_save => 'Save';

  @override
  String get addProperty_required => 'This field is required';

  @override
  String get addProperty_required_field => 'Required field';

  @override
  String get addProperty_invalidNumber => 'Enter a valid number';

  @override
  String get addProperty_selectDueDay => 'Select a due day';

  @override
  String get addProperty_invalidEmail => 'Invalid email';

  @override
  String get addProperty_saved => 'Property saved';

  @override
  String get addProperty_updated => 'Property updated';

  @override
  String get summary_paid => 'Paid';

  @override
  String get summary_missing => 'Missing';

  @override
  String get summary_excess => 'Excess';

  @override
  String get summary_maintenance => 'Maintenance';

  @override
  String get summary_expectedRent => 'Expected rent amount:';

  @override
  String get summary_totalPaid => 'Total paid:';

  @override
  String get summary_amountDue => 'Amount due:';

  @override
  String get summary_overpayment => 'Overpayment:';

  @override
  String get summary_maintenanceCosts => 'Maintenance costs:';

  @override
  String get summary_finalBalance => 'Final balance:';

  @override
  String get summary_addPayment => 'Payment';

  @override
  String get summary_addMaintenance => 'Maintenance';

  @override
  String get summary_editExpectedRent => 'Edit expected amount';

  @override
  String get payments_noPayments => 'No payments recorded';

  @override
  String get payments_addPayment => 'Add payment';

  @override
  String get maintenance_noEntries => 'No maintenance records';

  @override
  String get maintenance_addEntry => 'Add maintenance';

  @override
  String get payment_edit => 'Edit payment';

  @override
  String get payment_add => 'Add payment';

  @override
  String get payment_amountLabel => 'Amount';

  @override
  String get payment_noteLabel => 'Note';

  @override
  String get payment_dateLabel => 'Date:';

  @override
  String get payment_galleryButton => 'Gallery';

  @override
  String get payment_cameraButton => 'Camera';

  @override
  String get payment_saveButton => 'Save payment';

  @override
  String get maintenance_add => 'Add maintenance';

  @override
  String get maintenance_edit => 'Edit maintenance';

  @override
  String get maintenance_descriptionLabel => 'Description';

  @override
  String get maintenance_amountLabel => 'Amount (+ income, – expense)';

  @override
  String get maintenance_dateLabel => 'Date:';

  @override
  String get maintenance_galleryButton => 'Gallery';

  @override
  String get maintenance_cameraButton => 'Camera';

  @override
  String get maintenance_saveButton => 'Save maintenance';

  @override
  String get payment_deleteTitle => 'Delete payment?';

  @override
  String get payment_deleteMessage => 'This action cannot be undone.';

  @override
  String get payment_cancelButton => 'Cancel';

  @override
  String get payment_confirmDeleteButton => 'Delete';

  @override
  String get maintenance_deleteTitle => 'Delete maintenance record?';

  @override
  String get maintenance_deleteMessage => 'This action cannot be undone.';

  @override
  String get maintenance_cancelButton => 'Cancel';

  @override
  String get maintenance_confirmDeleteButton => 'Delete';

  @override
  String get editRentDialog_title => 'Edit expected rent';

  @override
  String get editRentDialog_label => 'New amount';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get tab_summary => 'Summary';

  @override
  String get tab_payments => 'Payments';

  @override
  String get tab_maintenance => 'Maintenance';
}
