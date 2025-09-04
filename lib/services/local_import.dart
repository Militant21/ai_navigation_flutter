// lib/services/local_import.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

/// Ide gyűjtjük a felhasználótól importált fájlokat.
/// (Nem az /Android/data-ba írunk!)
const String kMapsRoot = '/storage/emulated/0/ai_nav_maps';

class LocalImport {
  /// Létrehozza a /ai_nav_maps mappát, ha nem létezik.
  static Future<Directory> ensureMapsDir() async {
    final d = Directory(kMapsRoot);
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    return d;
  }

  /// Fájlok importálása a készülékről (SAF fájlválasztó).
  /// Nagy fájlokat streamelve másol, hogy ne fusson ki a memóriából.
  static Future<List<File>> importFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withReadStream: true,   // nagy fájlokhoz
      withData: false,        // ne töltse memóriába
      type: FileType.custom,
      allowedExtensions: ['pmtiles', 'mbtiles', 'geojson', 'zip'],
    );
    if (result == null) return [];

    final destDir = await ensureMapsDir();
    final imported = <File>[];

    for (final f in result.files) {
      final dest = File(p.join(destDir.path, f.name));

      if (f.readStream != null) {
        final sink = dest.openWrite();
        await f.readStream!.pipe(sink);
        await sink.close();
        imported.add(dest);
        continue;
      }

      if (f.path != null) {
        await File(f.path!).copy(dest.path);
        imported.add(dest);
        continue;
      }

      if (f.bytes != null) {
        await dest.writeAsBytes(f.bytes!, flush: true);
        imported.add(dest);
      }
    }

    return imported;
  }
}
