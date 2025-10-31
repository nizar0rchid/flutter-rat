# Axess

A proof of concept (POC) Windows implementation of a remote access tool built with Flutter/Dart using a native stub template approach.

## Overview

Axess is a remote access and monitoring tool that uses a unique approach of generating client executables from a pre-built native stub. The project demonstrates:

- Client executable generation without Dart SDK dependency
- Clean Architecture with feature-based organization
- BLoC pattern for state management
- Native Windows integration

## Project Structure

```
axess/
├── lib/
│   └── features/
│       ├── remote_control/      # Remote control feature
│       └── client_generator/    # Client generation feature
├── templates/
│   └── client_stub.exe         # Pre-built native stub template
└── ...
```

## Technical Details

- **Client Generation**: Uses a C-based stub executable that reads appended configuration
- **Architecture**: Follows clean architecture principles with domain-driven design
- **State Management**: Implements BLoC pattern for reactive UI updates
- **Platform**: Targets Windows systems for both server and client components

## Getting Started

1. Ensure you have Flutter installed and Windows development environment set up
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Compile the client stub (requires MSVC or MinGW):
   ```bash
   # Using MSVC (Developer Command Prompt)
   cl /O2 /MT stub.c /Fe:templates\client_stub.exe
   
   # Or using MinGW
   gcc -O2 -static -o templates\client_stub.exe stub.c
   ```
5. Run the application: `flutter run -d windows`

## Development Status

This is a proof of concept implementation demonstrating the technical feasibility of:
- Runtime client executable generation
- Configuration injection without recompilation
- Clean architecture in a Flutter Windows application

## Disclaimer

This project is for educational purposes only. Ensure compliance with all applicable laws and regulations when using remote access tools.