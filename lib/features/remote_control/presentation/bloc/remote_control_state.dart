import 'package:equatable/equatable.dart';
import '../../domain/entities/remote_session.dart';

abstract class RemoteControlState extends Equatable {
  const RemoteControlState();

  @override
  List<Object?> get props => [];
}

class RemoteControlInitial extends RemoteControlState {}

class RemoteControlLoading extends RemoteControlState {}

class RemoteControlError extends RemoteControlState {
  final String message;

  const RemoteControlError(this.message);

  @override
  List<Object?> get props => [message];
}

class SessionInitiated extends RemoteControlState {
  final RemoteSession session;

  const SessionInitiated(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionTerminated extends RemoteControlState {}

class ActiveSessionsLoaded extends RemoteControlState {
  final List<RemoteSession> sessions;

  const ActiveSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}
