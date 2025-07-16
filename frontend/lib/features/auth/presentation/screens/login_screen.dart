import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydration_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:hydration_tracker/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    await ref.read(authProvider.notifier).login(
      username: username,
      password: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Navigate to dashboard if authenticated
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.login)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.username,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => v != null && v.trim().isNotEmpty 
                      ? null 
                      : AppLocalizations.of(context)!.enterUsername,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => v != null && v.length >= 6 
                      ? null 
                      : AppLocalizations.of(context)!.min6chars,
                ),
                const SizedBox(height: 24),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(AppLocalizations.of(context)!.login),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: authState.isLoading
                      ? null
                      : () => Navigator.pushReplacementNamed(context, '/register'),
                  child: Text(AppLocalizations.of(context)!.noAccountRegister),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 