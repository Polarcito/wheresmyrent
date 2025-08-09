// lib/services/file_storage_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

/// Servicio de almacenamiento interno de la app.
/// - Copia archivos a una subcarpeta dentro del directorio de documentos de la app.
/// - Devuelve la ruta final (string) para guardar en tu modelo (Hive).
class FileStorageService {

  static String extractExtension(String path) => p.extension(path);

  FileStorageService._();
  static final _uuid = const Uuid();

  /// Directorio base: Application Documents (privado para la app).
  static Future<Directory> _appDocsDir() async {
    return getApplicationDocumentsDirectory();
  }

  /// Copia un [source] (File) a `.../<subdir>/<filename>` dentro del almacenamiento interno.
  /// - Si [filename] es null, se genera uno (conservando extensión si existe).
  /// - Crea subcarpetas si no existen.
  /// - Retorna la ruta final del archivo copiado.
  static Future<String> copyToAppStorage(
    File source, {
    required String subdir,
    String? filename,
  }) async {
    final base = await _appDocsDir();
    final destDir = Directory('${base.path}/$subdir');

    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    // Intenta conservar extensión
    String ext = _extractExtension(source.path);
    final safeName = filename ?? '${_uuid.v4()}$ext';
    final destPath = '${destDir.path}/$safeName';

    final copied = await source.copy(destPath);
    return copied.path;
  }

  static Future<String> copyXFileToAppStorage(
    XFile xfile, {
    required String subdir,
    String? filename,
  }) async {
    final file = File(xfile.path);
    final name = filename ?? '${_uuid.v4()}${_extractExtension(xfile.path)}';
    return copyToAppStorage(file, subdir: subdir, filename: name);
  }

  /// Elimina un archivo por ruta (ignora si no existe).
  static Future<void> deleteFileIfExists(String path) async {
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }

  /// Elimina una carpeta (y su contenido) por ruta relativa a la raíz de documentos de la app.
  /// Útil para limpiar `properties/<id>/photos` al borrar una propiedad.
  static Future<void> deleteAppSubdirRecursively(String subdir) async {
    final base = await _appDocsDir();
    final dir = Directory('${base.path}/$subdir');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Retorna la ruta absoluta del directorio de documentos de la app.
  static Future<String> appDocsPath() async {
    final base = await _appDocsDir();
    return base.path;
  }

  /// Extrae extensión (incluyendo el punto). Si no tiene, retorna ''.
  static String _extractExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot != -1 && dot < path.length - 1) {
      return path.substring(dot);
    }
    return '';
  }
}