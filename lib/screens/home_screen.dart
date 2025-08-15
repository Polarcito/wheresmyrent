import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wheresmyrent/main.dart';
import 'package:wheresmyrent/model/generic/app_theme.dart';
import 'package:wheresmyrent/model/generic/config.dart';
import 'package:wheresmyrent/model/generic/upper_case_text_formatter.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:wheresmyrent/model/services/settings_service.dart';
import 'package:wheresmyrent/screens/add_property_screen.dart';
import 'package:wheresmyrent/screens/pin_login_screen.dart';
import 'package:wheresmyrent/gen_l10n/app_localizations.dart';
import 'package:wheresmyrent/screens/property_detail_screen.dart';
import 'package:wheresmyrent/model/monthly_rent_block.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Box<Property> _box;

  // Estado local para el modal (se inicializa desde SettingsService)
  late bool _showCurrency;
  late String _currencyCode;
  late List<String> _currencies;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Property>(Config.boxName);

    // Inicializa desde cache del servicio (ya cargado en main)
    _showCurrency = SettingsService.showCurrency;
    _currencyCode = SettingsService.currencyCode;
    _currencies = List<String>.from(SettingsService.currencies);
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PinLoginScreen()),
    );
  }

  void _goToAddProperty() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
    );
    if (result != null) {
      setState(() {}); // Refresca la vista si se agregó una propiedad
    }
  }

  void _deleteProperty(String id) async {
    final box = Hive.box<Property>(Config.boxName);
    await box.delete(id);
    setState(() {}); // Refresca la lista
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: loc.home_Logout,
            color: Colors.white,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (context, Box<Property> box, _) {
          final properties = box.values.toList();

          if (properties.isEmpty) {
            return Center(child: Text(loc.home_noProperties));
          }

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              final colorScheme = theme.colorScheme;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(property: property),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.house_rounded, size: 36, color: colorScheme.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  getRentStatusIcon(property),
                                  const SizedBox(width: 6),
                                  Text(
                                    getRentStatusLabel(property),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: colorScheme.error,
                          tooltip: AppLocalizations.of(context)!.button_delete,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  AppLocalizations.of(context)!.home_delete_property_title,
                                  style: theme.textTheme.titleMedium,
                                ),
                                content: Text(
                                  AppLocalizations.of(context)!.home_delete_property_body(property.name),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(AppLocalizations.of(context)!.button_cancel,
                                        style: TextStyle(color: colorScheme.primary)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteProperty(property.id);
                                      Navigator.pop(context);
                                    },
                                    child: Text(AppLocalizations.of(context)!.button_delete,
                                        style: TextStyle(color: colorScheme.error)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          FloatingActionButton(
            heroTag: 'settings_fab',
            onPressed: _showThemeSelector,
            backgroundColor: AppColors.secondary,
            tooltip: loc.tooltip_settings,
            child: const Icon(Icons.settings, color: Colors.white),
          ),
          const Spacer(),
          FloatingActionButton(
            heroTag: 'add_fab',
            onPressed: _goToAddProperty,
            backgroundColor: AppColors.secondary,
            tooltip: loc.home_AddProperty,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget getRentStatusIcon(Property property) {
    final currentMonthBlock = property.getBlockFor(DateTime.now());
    final status = currentMonthBlock?.getPaymentStatus();
    switch (status) {
      case 'paid':   return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case 'partial':return const Icon(Icons.timelapse, color: Colors.orange, size: 20);
      case 'unpaid': return const Icon(Icons.cancel, color: Colors.red, size: 20);
      default:       return const Icon(Icons.help_outline, color: Colors.grey, size: 20);
    }
  }

  String getRentStatusLabel(Property property) {
    final currentMonthBlock = property.getBlockFor(DateTime.now());
    final status = currentMonthBlock?.getPaymentStatus();
    final loc = AppLocalizations.of(context)!;
    switch (status) {
      case 'paid':   return loc.rentStatus_paid;
      case 'partial':return loc.rentStatus_partial;
      case 'unpaid': return loc.rentStatus_unpaid;
      default:       return loc.rentStatus_unknown;
    }
  }

  // ===================== MODAL SETTINGS =====================
  Future<String?> _askForCustomCurrencyCode({
    required BuildContext context,
    required String label,
    required String hint,
    required String errorText,
    required String okText,
    required String cancelText,
  }) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(label, style: const TextStyle(color: AppColors.primary)),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                LengthLimitingTextInputFormatter(3),
                UpperCaseTextFormatter(),
              ],
              decoration: InputDecoration(hintText: hint),
              validator: (value) {
                final v = (value ?? '').trim().toUpperCase();
                if (v.length != 3 || !RegExp(r'^[A-Z]{3}$').hasMatch(v)) {
                  return errorText;
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(ctx).pop(controller.text.trim().toUpperCase());
                }
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: Text(cancelText)),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(ctx).pop(controller.text.trim().toUpperCase());
                }
              },
              child: Text(okText),
            ),
          ],
        );
      },
    );
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final loc = AppLocalizations.of(context)!;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              // Normaliza lista/value por si acaso
              () async {
                await SettingsService.normalizeAndPersist();
                setModalState(() {
                  _currencies = List<String>.from(SettingsService.currencies);
                  _currencyCode = SettingsService.currencyCode;
                });
              }();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.settings_title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Idiomas
                  ListTile(
                    leading: const Text("🇪🇸", style: TextStyle(fontSize: 24)),
                    title: Text(
                      loc.language_spanish,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    onTap: () {
                      localeNotifier.setLocale(const Locale('es'));
                      setState(() {}); // refresca pantalla padre
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Text("🇬🇧", style: TextStyle(fontSize: 24)),
                    title: Text(
                      loc.language_english,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    onTap: () {
                      localeNotifier.setLocale(const Locale('en'));
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),

                  const Divider(height: 24),

                  // Switch: Mostrar moneda
                  SwitchListTile(
                    title: Text(loc.settings_showCurrency_title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        )),
                    subtitle: Text(loc.settings_showCurrency_subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        )),
                    value: _showCurrency,
                    onChanged: (val) async {
                      setModalState(() => _showCurrency = val);
                      await SettingsService.saveShowCurrency(val);
                      setState(() {}); // refresca Home si lo usas en UI
                    },
                  ),

                  if (_showCurrency) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        loc.settings_currencyType_label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Dropdown Monedas
                    DropdownButtonFormField<String>(
                      key: ValueKey('curr-${_currencies.length}-${_currencyCode}'),
                      value: _currencyCode.isEmpty ? null : _currencyCode,
                      items: [
                        ..._currencies.map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, style: const TextStyle(color: AppColors.primary)),
                            )),
                        const DropdownMenuItem(
                          value: '_custom',
                          child: Row(
                            children: [
                              Icon(Icons.add, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text("Personalizar…", style: TextStyle(color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (val) async {
                        if (val == null) return;

                        if (val == '_custom') {
                          final custom = await _askForCustomCurrencyCode(
                            context: context,
                            label: loc.settings_currencyType_custom_label,
                            hint: loc.settings_currencyType_custom_hint,
                            errorText: loc.settings_currencyType_error_invalid,
                            okText: loc.common_ok,
                            cancelText: loc.common_cancel,
                          );
                          if (custom == null) return;

                          await SettingsService.addCurrencyIfMissing(custom);
                          await SettingsService.saveCurrencyCode(custom);

                          setModalState(() {
                            _currencies = List<String>.from(SettingsService.currencies);
                            _currencyCode = SettingsService.currencyCode;
                          });
                          setState(() {}); // refresca Home si fuera necesario
                          return;
                        }

                        // Selección normal
                        await SettingsService.saveCurrencyCode(val);
                        setModalState(() => _currencyCode = val);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.common_close),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
