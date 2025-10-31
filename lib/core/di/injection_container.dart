import 'package:get_it/get_it.dart';
import '../../features/remote_control/data/repositories/remote_control_repository_impl.dart';
import '../../features/remote_control/domain/repositories/remote_control_repository.dart';
import '../../features/remote_control/presentation/bloc/remote_control_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Remote Control
  sl.registerFactory(
    () => RemoteControlBloc(repository: sl()),
  );

  // Repositories
  sl.registerLazySingleton<RemoteControlRepository>(
    () => RemoteControlRepositoryImpl(),
  );

  // Core

  // External
}
