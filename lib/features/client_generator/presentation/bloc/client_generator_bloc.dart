import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'client_generator_event.dart';
part 'client_generator_state.dart';

class ClientGeneratorBloc extends Bloc<ClientGeneratorEvent, ClientGeneratorState> {
  ClientGeneratorBloc() : super(ClientGeneratorInitial()) {
    on<ClientGeneratorEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
