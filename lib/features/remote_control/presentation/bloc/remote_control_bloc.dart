import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/remote_control_repository.dart';
import 'remote_control_event.dart';
import 'remote_control_state.dart';

class RemoteControlBloc extends Bloc<RemoteControlEvent, RemoteControlState> {
  final RemoteControlRepository repository;

  RemoteControlBloc({required this.repository})
      : super(RemoteControlInitial()) {
    on<InitiateSessionEvent>(_onInitiateSession);
    on<TerminateSessionEvent>(_onTerminateSession);
    on<LoadActiveSessionsEvent>(_onLoadActiveSessions);
  }

  Future<void> _onInitiateSession(
    InitiateSessionEvent event,
    Emitter<RemoteControlState> emit,
  ) async {
    emit(RemoteControlLoading());
    final result = await repository.initiateSession(event.targetIp);
    result.fold(
      (failure) => emit(RemoteControlError(failure.message)),
      (session) => emit(SessionInitiated(session)),
    );
  }

  Future<void> _onTerminateSession(
    TerminateSessionEvent event,
    Emitter<RemoteControlState> emit,
  ) async {
    emit(RemoteControlLoading());
    final result = await repository.terminateSession(event.sessionId);
    result.fold(
      (failure) => emit(RemoteControlError(failure.message)),
      (_) => emit(SessionTerminated()),
    );
  }

  Future<void> _onLoadActiveSessions(
    LoadActiveSessionsEvent event,
    Emitter<RemoteControlState> emit,
  ) async {
    emit(RemoteControlLoading());
    final result = await repository.getActiveSessions();
    result.fold(
      (failure) => emit(RemoteControlError(failure.message)),
      (sessions) => emit(ActiveSessionsLoaded(sessions)),
    );
  }
}
