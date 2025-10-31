import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/remote_session.dart';

abstract class RemoteControlRepository {
  Future<Either<Failure, RemoteSession>> initiateSession(String targetIp);
  Future<Either<Failure, void>> terminateSession(String sessionId);
  Future<Either<Failure, List<RemoteSession>>> getActiveSessions();
}
