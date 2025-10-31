import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/remote_control_bloc.dart';
import '../bloc/remote_control_event.dart';

class ConnectionForm extends StatefulWidget {
  const ConnectionForm({super.key});

  @override
  State<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<ConnectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  String? _validateIpAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an IP address';
    }

    // Basic IP address validation
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );

    if (!ipRegex.hasMatch(value)) {
      return 'Please enter a valid IP address';
    }

    return null;
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context
          .read<RemoteControlBloc>()
          .add(InitiateSessionEvent(_ipController.text));
      _ipController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Connection',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'IP Address',
                    hintText: 'Enter remote machine IP address',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateIpAddress,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.connect_without_contact),
                label: const Text('Connect'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
