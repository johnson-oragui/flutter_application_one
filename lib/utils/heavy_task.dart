import 'package:flutter_application_one/services/auth_service.dart';

Future<void> runInitAuthInBackground(_) async {
  await authService.value.initAuth(); // Must be static or isolate-safe
}
