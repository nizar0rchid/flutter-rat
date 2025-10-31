import 'package:equatable/equatable.dart';

class ClientConfig extends Equatable {
  final String serverAddress;
  final int port;
  final String clientId;
  final String outputPath;

  const ClientConfig({
    required this.serverAddress,
    required this.port,
    required this.clientId,
    required this.outputPath,
  });

  @override
  List<Object?> get props => [serverAddress, port, clientId, outputPath];
}
