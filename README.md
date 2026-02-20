# FlutterDefend: A Lightweight Security SDK for Flutter Apps

![FlutterDefend](https://img.shields.io/badge/FlutterDefend-Security%20SDK-blue.svg)  
[![Releases](https://img.shields.io/badge/Releases-latest-brightgreen.svg)](https://github.com/SrTroche/flutter_defend/releases)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Key Components](#key-components)
- [Security Measures](#security-measures)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Overview

FlutterDefend is a lightweight, modular, and pluggable security SDK designed for Flutter mobile applications. It aims to protect critical operations and data within your app. This SDK provides tools to defend against common attacks and enhance overall security. Key features include SQL injection detection, local encrypted storage, screenshot prevention for input fields, and detection of jailbroken or rooted devices.

For the latest releases, please visit [Releases](https://github.com/SrTroche/flutter_defend/releases).

---

## Features

- **SQL Injection Detection**: Protect your app from SQL injection attacks by validating inputs and sanitizing queries.
  
- **Local Encrypted Storage**: Store sensitive data securely on the device using strong encryption algorithms.
  
- **Screenshot Prevention**: Prevent unauthorized screenshots of sensitive input fields to protect user privacy.
  
- **Jailbreak/Root Detection**: Identify if the app runs on compromised devices, reducing the risk of data breaches.

- **Modular Architecture**: Add or remove components based on your app's needs without bloating the codebase.

---

## Installation

To install FlutterDefend, follow these steps:

1. **Add Dependency**: Open your `pubspec.yaml` file and add the following line under dependencies:

   ```yaml
   dependencies:
     flutter_defend: ^1.0.0
   ```

2. **Install Packages**: Run the following command in your terminal:

   ```bash
   flutter pub get
   ```

3. **Import the Package**: In your Dart files, import the package:

   ```dart
   import 'package:flutter_defend/flutter_defend.dart';
   ```

4. **Download and Execute**: For the latest version, visit [Releases](https://github.com/SrTroche/flutter_defend/releases) to download the necessary files and execute them.

---

## Usage

Here’s a quick guide on how to use FlutterDefend in your application.

### Initialize the SDK

Before using any features, initialize the SDK in your `main.dart` file:

```dart
void main() {
  FlutterDefend.initialize();
  runApp(MyApp());
}
```

### SQL Injection Protection

To protect your queries, use the built-in validation methods:

```dart
String safeQuery(String input) {
  return FlutterDefend.validateSQL(input);
}
```

### Encrypted Storage

Store sensitive data securely:

```dart
void storeData(String key, String value) {
  FlutterDefend.storeEncrypted(key, value);
}

Future<String> retrieveData(String key) async {
  return await FlutterDefend.retrieveEncrypted(key);
}
```

### Screenshot Prevention

Enable screenshot prevention for specific input fields:

```dart
Widget sensitiveInputField() {
  return FlutterDefend.preventScreenshot(
    child: TextField(
      obscureText: true,
      decoration: InputDecoration(labelText: 'Password'),
    ),
  );
}
```

### Jailbreak/Root Detection

Check if the device is compromised:

```dart
bool isDeviceSecure = FlutterDefend.isDeviceSecure();
if (!isDeviceSecure) {
  // Handle the situation accordingly
}
```

---

## Key Components

### SQL Injection Detection

This component scans user inputs and queries to identify potential SQL injection patterns. It uses a set of predefined rules and algorithms to sanitize inputs.

### Local Encrypted Storage

FlutterDefend employs AES encryption to ensure that sensitive data is stored securely. This component manages encryption keys and handles data read/write operations seamlessly.

### Screenshot Prevention

By wrapping sensitive widgets, this component blocks screenshot capabilities. It leverages platform-specific APIs to enforce this restriction.

### Jailbreak/Root Detection

This component checks various indicators of device compromise. It examines system files, settings, and installed applications to determine the security status of the device.

---

## Security Measures

FlutterDefend adheres to best practices in security. Here are some measures implemented in the SDK:

- **Data Encryption**: All sensitive data is encrypted using AES-256, ensuring high security.

- **Input Validation**: User inputs undergo rigorous validation to prevent common attacks like SQL injection.

- **Regular Updates**: The SDK is regularly updated to address new security vulnerabilities and improve features.

- **Community Contributions**: The open-source nature of FlutterDefend encourages contributions, ensuring that the SDK evolves with community input.

---

## Contributing

We welcome contributions from the community. If you want to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with clear messages.
4. Push your branch and submit a pull request.

For more details, check the [CONTRIBUTING.md](CONTRIBUTING.md) file in the repository.

---

## License

FlutterDefend is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

---

## Contact

For any inquiries or issues, please reach out via the following channels:

- GitHub Issues: [GitHub Issues](https://github.com/SrTroche/flutter_defend/issues)
- Email: support@flutterdefend.com

For the latest releases, please visit [Releases](https://github.com/SrTroche/flutter_defend/releases).