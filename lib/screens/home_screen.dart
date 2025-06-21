import 'package:flutter/material.dart';
import 'package:wheresmyrent/gen_l10n/app_localizations.dart';
import 'package:wheresmyrent/model/generic/app_colors.dart';
import 'package:wheresmyrent/screens/add_property_screen.dart';
import 'package:wheresmyrent/services/auth_service.dart';
import 'package:wheresmyrent/screens/pin_login_screen.dart';
import 'package:wheresmyrent/model/property.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Property> _properties = [];

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PinLoginScreen()),
    );
  }

  Future<void> _addProperty() async {
    final newProperty = await Navigator.push<Property>(
      context,
      MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
    );

    if (newProperty != null) {
      setState(() {
        _properties.add(newProperty);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Where’s My Rent?",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: loc.home_Logout,
            color: Colors.white,
          ),
        ],
      ),
      body: _properties.isEmpty
          ? Center(
              child: Text(
                loc.home_welcome,
                style: const TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _properties.length,
              itemBuilder: (context, index) {
                final p = _properties[index];
                return ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(p.name),
                  subtitle: Text("${p.tenantName} • \$${p.monthlyRent.toStringAsFixed(0)}"),
                  trailing: Text("📅 ${p.dueDay}"),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.success,
        onPressed: _addProperty,
        tooltip: loc.home_AddProperty,
        child: const Icon(Icons.add),
      ),
    );
  }
}
