import 'package:flutter_defend/flutter_defend.dart';

void main() async {
  final dangerous =
      FlutterDefend.sqlInjection.containsInjection("DROP TABLE users");
  print(dangerous);

  await FlutterDefend.secureStorage.write("token", "abc123");

  final compromised = await FlutterDefend.jailbreak.isDeviceCompromised();
  print(compromised);

  final userStorage = FlutterDefend.withPassphrase("user_passphrase");
  await userStorage.write("key", "value");
}
