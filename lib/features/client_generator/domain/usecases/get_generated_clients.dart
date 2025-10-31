import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/client_config.dart';
import '../repositories/client_generator_repository.dart';

class GetGeneratedClients {
  final ClientGeneratorRepository repository;

  GetGeneratedClients(this.repository);

  Future<Either<Failure, List<ClientConfig>>> call() async {
    return await repository.getGeneratedClients();
  }
}
