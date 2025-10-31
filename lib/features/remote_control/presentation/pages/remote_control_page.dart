// ...existing code...
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/remote_control_bloc.dart';
import '../bloc/remote_control_event.dart';
import '../bloc/remote_control_state.dart';
import '../widgets/active_sessions_list.dart';
import '../widgets/connection_form.dart';

// Added imports to call the use case directly (no BLoC / DI for testing)
import 'package:axess/features/client_generator/domain/entities/client_config.dart';
import 'package:axess/features/client_generator/domain/usecases/generate_client.dart';
import 'package:axess/features/client_generator/data/datasources/client_generator_datasource.dart';
import 'package:axess/features/client_generator/data/repositories/client_generator_repository_impl.dart';
import 'package:axess/core/error/failures.dart';

class RemoteControlPage extends StatelessWidget {
  const RemoteControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<RemoteControlBloc>().add(LoadActiveSessionsEvent());
            },
          ),
          // Simple button to trigger the usecase directly for testing
          IconButton(
            icon: const Icon(Icons.build),
            tooltip: 'Generate test client',
            onPressed: () => _showGenerateClientDialog(context),
          ),
        ],
      ),
      body: BlocListener<RemoteControlBloc, RemoteControlState>(
        listener: (context, state) {
          if (state is RemoteControlError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SessionInitiated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connected to ${state.session.hostName}'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is SessionTerminated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session terminated successfully'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConnectionForm(),
              const SizedBox(height: 24),
              const Text(
                'Active Sessions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<RemoteControlBloc, RemoteControlState>(
                  buildWhen: (previous, current) =>
                      current is ActiveSessionsLoaded ||
                      current is RemoteControlLoading,
                  builder: (context, state) {
                    if (state is RemoteControlLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is ActiveSessionsLoaded) {
                      return ActiveSessionsList(sessions: state.sessions);
                    }
                    return const Center(
                      child: Text('No active sessions'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.download),
        label: const Text('Generate Client'),
        onPressed: () => _showGenerateClientDialog(context),
      ),
    );
  }

  Future<void> _showGenerateClientDialog(BuildContext context) async {
    final serverController = TextEditingController(text: '127.0.0.1');
    final portController = TextEditingController(text: '8080');
    final clientIdController = TextEditingController(text: 'client-001');
    final outputPathController = TextEditingController(text: r'C:\temp');

    // Await the dialog so we can dispose controllers *after* it's closed
    await showDialog<void>(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Generate Client Executable (test)'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: serverController,
                    decoration:
                        const InputDecoration(labelText: 'Server address'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: portController,
                    decoration: const InputDecoration(labelText: 'Port'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final n = int.tryParse(v);
                      return (n == null) ? 'Invalid port' : null;
                    },
                  ),
                  TextFormField(
                    controller: clientIdController,
                    decoration: const InputDecoration(labelText: 'Client ID'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: outputPathController,
                    decoration: const InputDecoration(labelText: 'Output path'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // do not dispose here
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() != true) return;

                final config = ClientConfig(
                  serverAddress: serverController.text.trim(),
                  port: int.parse(portController.text.trim()),
                  clientId: clientIdController.text.trim(),
                  outputPath: outputPathController.text.trim(),
                );

                // --- Direct, simple call chain for testing (no BLoC / DI) ---
                final datasource = ClientGeneratorDatasourceImpl();
                final repository = ClientGeneratorRepositoryImpl(datasource);
                final usecase = GenerateClient(repository);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting generation...')),
                );

                final result = await usecase.call(config);

                result.fold(
                  (failure) {
                    final message = (failure is Failure)
                        ? failure.message
                        : failure.toString();
                    log("RemoteControlError: ${failure.message}");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Generation failed: $message'),
                          backgroundColor: Colors.red),
                    );
                  },
                  (exePath) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Generated: $exePath'),
                          backgroundColor: Colors.green),
                    );
                  },
                );

                Navigator.of(context)
                    .pop(); // close dialog, controllers disposed after await
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );

/*     // Dispose controllers only after the dialog is closed
    serverController.dispose();
    portController.dispose();
    clientIdController.dispose();
    outputPathController.dispose(); */
  }
}
// ...existing code...