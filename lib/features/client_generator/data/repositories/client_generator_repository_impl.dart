import 'package:dartz/dartz.dart';
import '../../domain/repositories/client_generator_repository.dart';
import '../../domain/entities/client_config.dart';
import '../datasources/client_generator_datasource.dart';
import '../models/client_config_model.dart';
import '../../../../core/error/failures.dart';

class ClientGeneratorRepositoryImpl implements ClientGeneratorRepository {
  final ClientGeneratorDatasource datasource;

  ClientGeneratorRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, String>> generateClient(ClientConfig config) async {
    try {
      final configModel = ClientConfigModel.fromEntity(config);
      final result = await datasource.generateExe(configModel);
      return Right(result);
    } catch (e) {
      return Left(GenerationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ClientConfig>>> getGeneratedClients() {
    // TODO: implement getGeneratedClients
    throw UnimplementedError();
  }
}
