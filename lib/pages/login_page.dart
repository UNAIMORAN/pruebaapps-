import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

// Esquema de URL al que vuelve el navegador tras el login con Google en
// móvil y escritorio. Debe coincidir con lo configurado en Android/iOS y
// en la lista de "Redirect URLs" de Supabase.
const String _oauthRedirect = 'com.example.pruebaapps://login-callback/';

/// Pantalla de inicio de sesión y registro con email + contraseña.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // True mientras esperamos respuesta de Supabase (deshabilita los botones).
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Inicia sesión con un usuario ya registrado.
  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // No navegamos manualmente: el AuthGate detecta la sesión y cambia de pantalla.
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Ocurrió un error inesperado.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Registra un usuario nuevo. Con "Confirm email" desactivado en Supabase,
  /// la sesión queda activa de inmediato.
  Future<void> _signUp() async {
    setState(() => _loading = true);
    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Si la confirmación por email está activada, no habrá sesión todavía.
      if (response.session == null && mounted) {
        _showMessage('Revisa tu correo para confirmar la cuenta.');
      }
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Ocurrió un error inesperado.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Inicia sesión con Google (OAuth).
  ///
  /// Abre el navegador para que el usuario elija su cuenta. Al terminar, vuelve
  /// a la app y la sesión llega por `onAuthStateChange` (el AuthGate cambia solo
  /// de pantalla), igual que con el login de email.
  Future<void> _signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // En web no hace falta esquema: vuelve a la URL actual de la web.
        // En móvil/escritorio usamos el esquema propio de la app.
        redirectTo: kIsWeb ? null : _oauthRedirect,
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('No se pudo iniciar sesión con Google.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Tareas')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.checklist_rounded, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Inicia sesión o regístrate',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _signIn,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Entrar'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _loading ? null : _signUp,
                  child: const Text('Registrarse'),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('o'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _signInWithGoogle,
                  icon: const Icon(Icons.login),
                  label: const Text('Continuar con Google'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
