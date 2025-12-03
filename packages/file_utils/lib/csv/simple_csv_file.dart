import 'dart:io';

class SimpleCsvFile {
  final String path;

  SimpleCsvFile({
    required this.path,
  });

  Future<void> clear({bool bom = false}) async {
    final file = File(path);
    if (bom) {
      // Write UTF-8 BOM
      await file.writeAsBytes([0xEF, 0xBB, 0xBF]);
    } else {
      await file.writeAsString('');
    }
  }

  Future<void> writeAsString({
    required List<String> data,
  }) async {
    final file = File(path);
    final csvLine = _rowToCsv(data);
    await file.writeAsString('$csvLine\n', mode: FileMode.append);
  }

  Future<void> write({
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final file = File(path);
    final buffer = StringBuffer();

    // Write headers
    buffer.writeln(_rowToCsv(headers));

    // Write rows
    for (final row in rows) {
      buffer.writeln(_rowToCsv(row));
    }

    await file.writeAsString(buffer.toString());
  }

  String _rowToCsv(List<String> row) {
    return row.map((cell) {
      // Escape quotes and wrap in quotes if contains comma or quote
      if (cell.contains(',') || cell.contains('"') || cell.contains('\n')) {
        return '"${cell.replaceAll('"', '""')}"';
      }
      return cell;
    }).join(',');
  }
}
