import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/login_page.dart';
import 'pages/todos_page.dart';
import 'scheme_registrar.dart';
import 'supabase_config.dart';

Future<void> main() async {
  // Necesario antes de usar plugins (como Supabase) en main().
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el cliente de Supabase una sola vez al arrancar la app.
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // En Windows, registra el esquema de URL para el login con Google.
  // En el resto de plataformas no hace nada.
  await registerOAuthScheme();

  runApp(const TodoApp());
}

// Acceso corto al cliente de Supabase desde cualquier parte de la app.
final supabase = Supabase.instance.client;

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Decide qué pantalla mostrar según el estado de sesión.
///
/// Escucha los cambios de autenticación de Supabase: si hay sesión activa
/// muestra la lista de tareas, si no, la pantalla de login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Mientras llega el primer evento, mostramos un spinner.
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data!.session;
        if (session != null) {
          return const TodosPage();
        }
        return const LoginPage();
      },
    );
  }
}
