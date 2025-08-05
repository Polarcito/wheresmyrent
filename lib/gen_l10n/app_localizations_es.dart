// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get login_createPin => 'Crear PIN';

  @override
  String get login_enterPin => 'Ingresar PIN';

  @override
  String get login_confirmPin => 'Confirmar PIN';

  @override
  String get login_savePin => 'Guardar PIN';

  @override
  String get login_pinMismatch => 'Los PIN no coinciden';

  @override
  String get login_invalidPin => 'PIN inválido';

  @override
  String get login_unlock => 'Desbloquear';

  @override
  String get login_validation => 'El PIN debe tener al menos 4 dígitos';

  @override
  String get title => 'Where’s My Rent?';

  @override
  String get home_Logout => 'Cerrar sesión';

  @override
  String get home_noProperties => 'Aún no se han agregado propiedades.';

  @override
  String get home_AddProperty => 'Agregar propiedad';

  @override
  String get home_delete_property_title => 'Eliminar propiedad.';

  @override
  String home_delete_property_body(String level) {
    return '¿Estás seguro de que deseas eliminar $level? Esta acción será permanente.';
  }

  @override
  String get button_cancel => 'Cancelar';

  @override
  String get button_delete => 'Eliminar';

  @override
  String get settings_title => 'Configuración';

  @override
  String get language_spanish => 'Español';

  @override
  String get language_english => 'English';

  @override
  String get tooltip_settings => 'Configuración';

  @override
  String get rentStatus_paid => 'Pagado';

  @override
  String get rentStatus_partial => 'Pago parcial';

  @override
  String get rentStatus_unpaid => 'Pendiente';

  @override
  String get rentStatus_unknown => 'Sin datos';

  @override
  String get addProperty_title => 'Agregar Propiedad';

  @override
  String get addProperty_step1_name => 'Nombre de la propiedad';

  @override
  String get addProperty_step1_address => 'Dirección';

  @override
  String get addProperty_step1_rent => 'Arriendo mensual';

  @override
  String get addProperty_step1_dueDay => 'Día de vencimiento';

  @override
  String get addProperty_step1_startDate => 'Fecha de inicio del contrato:';

  @override
  String get addProperty_step1_startDateNotSelected => 'Fecha no seleccionada';

  @override
  String get addProperty_step1_selectDate => 'Seleccionar fecha';

  @override
  String get addProperty_step2_tenantName => 'Nombre del arrendatario';

  @override
  String get addProperty_step2_tenantEmail => 'Correo electrónico';

  @override
  String get addProperty_step2_tenantPhone => 'Teléfono';

  @override
  String get addProperty_step3_contractFile => 'Archivo de contrato (opcional)';

  @override
  String get addProperty_step3_fileSelected => '📄 Archivo seleccionado';

  @override
  String get addProperty_step3_selectFile => 'Seleccionar archivo';

  @override
  String get addProperty_step3_initialPhotos => 'Fotos iniciales del inmueble (opcional)';

  @override
  String get addProperty_step3_selectPhotos => 'Seleccionar fotos';

  @override
  String get addProperty_button_back => 'Volver';

  @override
  String get addProperty_button_next => 'Siguiente';

  @override
  String get addProperty_button_save => 'Guardar';

  @override
  String get addProperty_required => 'Este campo es obligatorio';

  @override
  String get addProperty_required_field => 'Campo obligatorio';

  @override
  String get addProperty_invalidNumber => 'Ingresa un número válido';

  @override
  String get addProperty_selectDueDay => 'Selecciona un día de vencimiento';

  @override
  String get addProperty_invalidEmail => 'Correo no válido';

  @override
  String get addProperty_saved => 'Propiedad guardada';

  @override
  String get addProperty_updated => 'Propiedad actualizada';

  @override
  String get summary_paid => 'Pagado';

  @override
  String get summary_missing => 'Faltante';

  @override
  String get summary_excess => 'Excedente';

  @override
  String get summary_maintenance => 'Mantención';

  @override
  String get summary_expectedRent => 'Monto esperado de arriendo:';

  @override
  String get summary_totalPaid => 'Total pagado:';

  @override
  String get summary_amountDue => 'Faltante por pagar:';

  @override
  String get summary_overpayment => 'Excedente:';

  @override
  String get summary_maintenanceCosts => 'Gastos de mantención:';

  @override
  String get summary_finalBalance => 'Balance final:';

  @override
  String get summary_addPayment => 'Pago';

  @override
  String get summary_addMaintenance => 'Mantención';

  @override
  String get summary_editExpectedRent => 'Editar monto esperado';

  @override
  String get payments_noPayments => 'Sin pagos registrados';

  @override
  String get payments_addPayment => 'Ingresar pago';

  @override
  String get maintenance_noEntries => 'Sin registros de mantención';

  @override
  String get maintenance_addEntry => 'Agregar mantención';

  @override
  String get payment_edit => 'Editar pago';

  @override
  String get payment_add => 'Ingresar pago';

  @override
  String get payment_amountLabel => 'Monto';

  @override
  String get payment_noteLabel => 'Nota';

  @override
  String get payment_dateLabel => 'Fecha:';

  @override
  String get payment_galleryButton => 'Galería';

  @override
  String get payment_cameraButton => 'Cámara';

  @override
  String get payment_saveButton => 'Guardar pago';

  @override
  String get maintenance_add => 'Ingresar mantención';

  @override
  String get maintenance_edit => 'Editar mantención';

  @override
  String get maintenance_descriptionLabel => 'Descripción';

  @override
  String get maintenance_amountLabel => 'Monto (+ ingreso, – gasto)';

  @override
  String get maintenance_dateLabel => 'Fecha:';

  @override
  String get maintenance_galleryButton => 'Galería';

  @override
  String get maintenance_cameraButton => 'Cámara';

  @override
  String get maintenance_saveButton => 'Guardar mantención';

  @override
  String get payment_deleteTitle => '¿Eliminar pago?';

  @override
  String get payment_deleteMessage => 'Esta acción no se puede deshacer.';

  @override
  String get payment_cancelButton => 'Cancelar';

  @override
  String get payment_confirmDeleteButton => 'Eliminar';

  @override
  String get maintenance_deleteTitle => '¿Eliminar registro de mantención?';

  @override
  String get maintenance_deleteMessage => 'Esta acción no se puede deshacer.';

  @override
  String get maintenance_cancelButton => 'Cancelar';

  @override
  String get maintenance_confirmDeleteButton => 'Eliminar';

  @override
  String get editRentDialog_title => 'Editar monto esperado';

  @override
  String get editRentDialog_label => 'Nuevo monto';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_save => 'Guardar';

  @override
  String get tab_summary => 'Resumen';

  @override
  String get tab_payments => 'Pagos';

  @override
  String get tab_maintenance => 'Mantención';
}
