import 'package:hive/hive.dart';
import 'package:wheresmyrent/model/generic/config.dart';
import '../model/property.dart';

class PropertyService {
  static const String _boxName = Config.boxName;

  // Obtener instancia del box
  Box<Property> get _box => Hive.box<Property>(_boxName);

  // Obtener todas las propiedades
  List<Property> getAllProperties() {
    return _box.values.toList();
  }

  // Agregar nueva propiedad
  Future<void> addProperty(Property property) async {
    await _box.add(property);
  }

  // Actualizar propiedad por key
  Future<void> updateProperty(int key, Property property) async {
    await _box.put(key, property);
  }

  // Eliminar propiedad por key
  Future<void> deleteProperty(int key) async {
    await _box.delete(key);
  }

  // Obtener propiedad por key
  Property? getProperty(int key) {
    return _box.get(key);
  }

  // Vaciar todo
  Future<void> clearAll() async {
    await _box.clear();
  }
}
