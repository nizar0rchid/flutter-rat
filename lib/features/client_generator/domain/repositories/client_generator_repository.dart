import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/client_config.dart';

abstract class ClientGeneratorRepository {
  /// Generates a client executable with the given configuration
  /// Returns the path to the generated executable on success
  /// Returns a [GenerationFailure] on failure
  Future<Either<Failure, String>> generateClient(ClientConfig config);

  /// Gets the list of all generated clients
  Future<Either<Failure, List<ClientConfig>>> getGeneratedClients();
}
