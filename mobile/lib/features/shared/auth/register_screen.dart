import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/account_providers.dart';
import '../../../core/services/auth/account_repository.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Inscription élève ou enseignant — persistance SQLite.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _schoolController = TextEditingController();
  final _classController = TextEditingController();
  final _levelController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final account = await ref.read(accountRepositoryProvider).register(
            name: _nameController.text,
            identifier: _identifierController.text,
            password: _passwordController.text,
            role: widget.role,
            school: _schoolController.text,
            className: _classController.text,
            level: _levelController.text,
          );

      await ref.read(sessionProvider.notifier).loginFromAccount(
            userId: account.id,
            name: account.name,
            role: account.role,
          );

      if (mounted) {
        context.go(widget.role == UserRole.teacher ? '/teacher' : '/student/home');
      }
    } on AccountException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.role == UserRole.student;

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _identifierController,
                decoration: const InputDecoration(
                  labelText: 'Email ou téléphone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Minimum 6 caractères' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(
                  labelText: isStudent ? 'Établissement' : 'Établissement / Zone',
                  prefixIcon: const Icon(Icons.school_outlined),
                ),
              ),
              if (isStudent) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _classController,
                  decoration: const InputDecoration(
                    labelText: 'Classe',
                    prefixIcon: Icon(Icons.class_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _levelController,
                  decoration: const InputDecoration(
                    labelText: 'Niveau',
                    prefixIcon: Icon(Icons.stairs_outlined),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 32),
              LoadingButton(
                label: 'Créer mon compte',
                isLoading: _isLoading,
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
