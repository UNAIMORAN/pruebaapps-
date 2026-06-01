import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

// Debe coincidir con _oauthRedirect en pages/login_page.dart.
const String _scheme = 'com.example.pruebaapps';

/// Registra el esquema de URL en el registro de Windows para que el navegador
/// pueda devolver el control a la app tras el login con Google.
///
/// En otras plataformas (Android, iOS, Linux, macOS) no hace nada: ahí el
/// esquema se declara en los archivos nativos o no hace falta.
Future<void> registerOAuthScheme() async {
  if (!Platform.isWindows) return;

  final appPath = Platform.resolvedExecutable;

  final protocolRegKey = 'Software\\Classes\\$_scheme';
  const protocolRegValue = RegistryValue(
    'URL Protocol',
    RegistryValueType.string,
    '',
  );
  const protocolCmdRegKey = 'shell\\open\\command';
  final protocolCmdRegValue = RegistryValue(
    '',
    RegistryValueType.string,
    '"$appPath" "%1"',
  );

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(protocolRegValue);
  regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
}
