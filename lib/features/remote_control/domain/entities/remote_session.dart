import 'package:equatable/equatable.dart';

class RemoteSession extends Equatable {
  final String id;
  final String hostName;
  final String ipAddress;
  final bool isConnected;

  const RemoteSession({
    required this.id,
    required this.hostName,
    required this.ipAddress,
    this.isConnected = false,
  });

  @override
  List<Object?> get props => [id, hostName, ipAddress, isConnected];
}
