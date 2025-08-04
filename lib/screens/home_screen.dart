import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wheresmyrent/main.dart';
import 'package:wheresmyrent/model/generic/app_theme.dart';
import 'package:wheresmyrent/model/generic/config.dart';
import 'package:wheresmyrent/model/monthly_rent_block.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:wheresmyrent/screens/add_property_screen.dart';
import 'package:wheresmyrent/screens/pin_login_screen.dart';
import 'package:wheresmyrent/gen_l10n/app_localizations.dart';
import 'package:wheresmyrent/screens/property_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Box<Property> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Property>(Config.boxName);
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Where’s My Rent?", style: const TextStyle(color: Colors.white)),
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
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
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
                        Icon(
                          Icons.house_rounded,
                          size: 36,
                          color: colorScheme.primary,
                        ),
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
                                    child: Text(
                                      AppLocalizations.of(context)!.button_cancel,
                                      style: TextStyle(color: colorScheme.primary),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteProperty(property.id);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.button_delete,
                                      style: TextStyle(color: colorScheme.error),
                                    ),
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
          const SizedBox(width: 48), // espacio lateral izquierdo
          FloatingActionButton(
            heroTag: 'settings_fab',
            onPressed: () {
              _showThemeSelector();
            },
            backgroundColor: AppColors.secondary,
            tooltip: "Configuración",
            child: const Icon(Icons.settings, color: Colors.white),
          ),

          const Spacer(),

          // ➕ Botón de agregar propiedad
          FloatingActionButton(
            heroTag: 'add_fab',
            onPressed: _goToAddProperty,
            backgroundColor: AppColors.secondary,
            tooltip: loc.home_AddProperty,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(width: 16), // espacio lateral derecho
        ],
      ),
    );
  }

  Widget getRentStatusIcon(Property property) {
    final currentMonthBlock = property.getBlockFor(DateTime.now());
    final status = currentMonthBlock?.getPaymentStatus(); // ejemplo: 'paid', 'partial', 'unpaid'

    switch (status) {
      case 'paid':
        return Icon(Icons.check_circle, color: Colors.green, size: 20);
      case 'partial':
        return Icon(Icons.timelapse, color: Colors.orange, size: 20);
      case 'unpaid':
        return Icon(Icons.cancel, color: Colors.red, size: 20);
      default:
        return Icon(Icons.help_outline, color: Colors.grey, size: 20);
    }
  }

  String getRentStatusLabel(Property property) {
    final currentMonthBlock = property.getBlockFor(DateTime.now());
    final status = currentMonthBlock?.getPaymentStatus();

    switch (status) {
      case 'paid':
        return 'Pagado';
      case 'partial':
        return 'Pago parcial';
      case 'unpaid':
        return 'Pendiente';
      default:
        return 'Sin datos';
    }
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Seleccionar tema", style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Claro'),
                onTap: () {
                  themeNotifier.setTheme(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Oscuro'),
                onTap: () {
                  themeNotifier.setTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: const Text('Sistema'),
                onTap: () {
                  themeNotifier.setTheme(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
