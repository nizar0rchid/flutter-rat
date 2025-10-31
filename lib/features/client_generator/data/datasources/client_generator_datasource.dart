// ...existing code...
import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:axess/features/client_generator/data/models/client_config_model.dart';
import 'package:path/path.dart' as path;

abstract class ClientGeneratorDatasource {
  Future<String> generateExe(ClientConfigModel config);
}

class ClientGeneratorDatasourceImpl implements ClientGeneratorDatasource {
  /// Path to the prebuilt native stub executable.
  /// Put your compiled stub in this templates folder (relative to app working dir)
  /// or use an absolute path.
  final String stubRelativePath;

  ClientGeneratorDatasourceImpl(
      {this.stubRelativePath = 'lib/templates/client_stub.exe'});

  static const String _marker = 'AXESSCFGv1'; // must match what stub looks for

  @override
  Future<String> generateExe(ClientConfigModel config) async {
    // Ensure output directory exists
    final outDir = Directory(config.outputPath);
    if (!outDir.existsSync()) {
      log("Creating output directory at ${config.outputPath}");
      outDir.createSync(recursive: true);
    }

    // Resolve stub path
    final stubPath =
        path.normalize(path.join(Directory.current.path, stubRelativePath));
    final stubFile = File(stubPath);
    if (!stubFile.existsSync()) {
      throw Exception('Stub executable not found at: $stubPath');
    }

    // Destination exe path (copy of the stub)
    final exePath =
        path.join(config.outputPath, '${config.clientId}_client.exe');
    await stubFile.copy(exePath);

    // Prepare config payload
    final cfg = {
      'serverAddress': config.serverAddress,
      'port': config.port,
      'clientId': config.clientId,
    };
    final jsonBytes = utf8.encode(jsonEncode(cfg));
    final markerBytes = utf8.encode(_marker);

    // 8-byte length little-endian to store JSON length
    final lengthBuffer = ByteData(8)
      ..setUint64(0, jsonBytes.length, Endian.little);
    final lengthBytes = lengthBuffer.buffer.asUint8List();

    // Append marker + length + json to the copied exe
    final exeFile = File(exePath);
    await exeFile.writeAsBytes(
      [
        ...markerBytes,
        ...lengthBytes,
        ...jsonBytes,
      ],
      mode: FileMode.append,
    );

    log('Wrote config (len=${jsonBytes.length}) to $exePath');
    return exePath;
  }
}
// ...existing code...