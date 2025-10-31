import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/client_config.dart';
import '../repositories/client_generator_repository.dart';

class GenerateClient {
  final ClientGeneratorRepository repository;

  GenerateClient(this.repository);

  Future<Either<Failure, String>> call(ClientConfig params) async {
    return await repository.generateClient(params);
  }
}
