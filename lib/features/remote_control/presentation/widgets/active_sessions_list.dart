import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/remote_session.dart';
import '../bloc/remote_control_bloc.dart';
import '../bloc/remote_control_event.dart';

class ActiveSessionsList extends StatelessWidget {
  final List<RemoteSession> sessions;

  const ActiveSessionsList({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text('No active sessions'),
      );
    }

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          child: ListTile(
            leading: Icon(
              Icons.computer,
              color: session.isConnected ? Colors.green : Colors.grey,
            ),
            title: Text(session.hostName),
            subtitle: Text(session.ipAddress),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context
                    .read<RemoteControlBloc>()
                    .add(TerminateSessionEvent(session.id));
              },
            ),
          ),
        );
      },
    );
  }
}
