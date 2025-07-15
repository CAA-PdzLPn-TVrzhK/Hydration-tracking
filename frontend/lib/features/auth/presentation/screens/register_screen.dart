import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _email = '';
  bool _loading = false;
  String? _error;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    _formKey.currentState!.save();
    // Здесь должна быть логика запроса к API
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loading = false;
    });
    // Для примера: если email не занят, регистрация успешна
    if (_email != 'test@test.com') {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() {
        _error = 'Email уже зарегистрирован';
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                  v != null && v.contains('@') ? null : 'Введите email',
                  onSaved: (v) => _email = v ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (v) =>
                  v != null && v.length >= 6 ? null : 'Минимум 6 символов',
                  onSaved: (v) => _password = v ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration:
                  const InputDecoration(labelText: 'Повторите пароль'),
                  obscureText: true,
                  controller: _confirmPasswordController,
                  validator: (v) => v == _passwordController.text
                      ? null
                      : 'Пароли не совпадают',
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Зарегистрироваться'),
                  ),
                ),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Уже есть аккаунт? Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
