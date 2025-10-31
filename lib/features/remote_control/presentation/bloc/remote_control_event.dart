import 'package:equatable/equatable.dart';

abstract class RemoteControlEvent extends Equatable {
  const RemoteControlEvent();

  @override
  List<Object?> get props => [];
}

class InitiateSessionEvent extends RemoteControlEvent {
  final String targetIp;

  const InitiateSessionEvent(this.targetIp);

  @override
  List<Object?> get props => [targetIp];
}

class TerminateSessionEvent extends RemoteControlEvent {
  final String sessionId;

  const TerminateSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class LoadActiveSessionsEvent extends RemoteControlEvent {}
