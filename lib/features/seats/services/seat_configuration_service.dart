import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/seat.dart';

enum SeatFileFormat { excel, csv, json }

class SeatConfigurationService {
  Future<String?> export(List<Seat> seats, SeatFileFormat format) async {
    final bytes = switch (format) {
      SeatFileFormat.json => utf8.encode(
        jsonEncode([
          for (final seat in seats)
            {'seatId': seat.seatId, 'seatLabel': seat.seatLabel},
        ]),
      ),
      SeatFileFormat.csv => utf8.encode(
        [
          'seatId,seatLabel',
          for (final seat in seats)
            '${_csv(seat.seatId)},${_csv(seat.seatLabel)}',
        ].join('\n'),
      ),
      SeatFileFormat.excel => _excelBytes(seats),
    };
    final extension = format == SeatFileFormat.excel ? 'xlsx' : format.name;
    return FilePicker.platform.saveFile(
      dialogTitle: 'Export seat configuration',
      fileName: 'seat-configuration.$extension',
      bytes: Uint8List.fromList(bytes),
    );
  }

  Future<List<String>?> import() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json', 'csv', 'xlsx'],
      withData: true,
    );
    if (result == null) return null;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) return null;
    switch (file.extension?.toLowerCase()) {
      case 'json':
        final data = jsonDecode(utf8.decode(bytes)) as List<dynamic>;
        return [
          for (final item in data)
            (item as Map<String, dynamic>)['seatLabel'].toString(),
        ];
      case 'csv':
        return LineSplitter.split(
          utf8.decode(bytes),
        ).skip(1).where((line) => line.trim().isNotEmpty).map((line) {
          final parts = line.split(',');
          return parts.length > 1
              ? _unquote(parts.sublist(1).join(','))
              : _unquote(parts.first);
        }).toList();
      case 'xlsx':
        final book = Excel.decodeBytes(bytes);
        final sheet = book.tables.values.first;
        return [
          for (final row in sheet.rows.skip(1))
            if (row.length > 1 && row[1]?.value != null)
              row[1]!.value.toString(),
        ];
      default:
        return null;
    }
  }

  List<int> _excelBytes(List<Seat> seats) {
    final book = Excel.createExcel();
    final sheet = book['Seats'];
    sheet.appendRow([TextCellValue('seatId'), TextCellValue('seatLabel')]);
    for (final seat in seats) {
      sheet.appendRow([
        TextCellValue(seat.seatId),
        TextCellValue(seat.seatLabel),
      ]);
    }
    book.delete('Sheet1');
    return book.encode()!;
  }

  String _csv(String value) => '"${value.replaceAll('"', '""')}"';
  String _unquote(String value) =>
      value.trim().replaceAll(RegExp(r'^"|"$'), '').replaceAll('""', '"');
}
