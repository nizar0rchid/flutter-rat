import '../../domain/entities/client_config.dart';

class ClientConfigModel extends ClientConfig {
  const ClientConfigModel({
    required String serverAddress,
    required int port,
    required String clientId,
    required String outputPath,
  }) : super(
          serverAddress: serverAddress,
          port: port,
          clientId: clientId,
          outputPath: outputPath,
        );

  factory ClientConfigModel.fromJson(Map<String, dynamic> json) {
    return ClientConfigModel(
      serverAddress: json['serverAddress'] as String,
      port: json['port'] as int,
      clientId: json['clientId'] as String,
      outputPath: json['outputPath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverAddress': serverAddress,
      'port': port,
      'clientId': clientId,
      'outputPath': outputPath,
    };
  }

  factory ClientConfigModel.fromEntity(ClientConfig entity) {
    return ClientConfigModel(
      serverAddress: entity.serverAddress,
      port: entity.port,
      clientId: entity.clientId,
      outputPath: entity.outputPath,
    );
  }
}
