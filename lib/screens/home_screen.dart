import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wheresmyrent/model/generic/config.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:wheresmyrent/screens/add_property_screen.dart';
import 'package:wheresmyrent/model/generic/app_colors.dart';
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(property.name),
                  subtitle: Text(property.address),
                  leading: Icon(
                    property.hasPendingPayment ? Icons.warning : Icons.check_circle,
                    color: property.hasPendingPayment ? AppColors.warning : AppColors.success,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: AppLocalizations.of(context)!.button_delete,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title:  Text(AppLocalizations.of(context)!.home_delete_property_title),
                          content: Text(AppLocalizations.of(context)!.home_delete_property_body(property.name)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.button_cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteProperty(property.id);
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)!.button_delete, style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(property: property),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddProperty,
        backgroundColor: AppColors.secondary,
        tooltip: loc.home_AddProperty,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
