import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/account_providers.dart';
import '../../../core/services/auth/account_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Écran de connexion — authentification SQLite.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final account = await ref.read(accountRepositoryProvider).login(
            identifier: _identifierController.text,
            password: _passwordController.text,
          );

      if (account.role != widget.role) {
        throw AccountException(
          widget.role == UserRole.teacher
              ? 'Ce compte est enregistré comme élève.'
              : 'Ce compte est enregistré comme enseignant.',
        );
      }

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
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.role == UserRole.teacher;
    return Scaffold(
      appBar: AppBar(title: Text('Connexion ${isTeacher ? 'Enseignant' : 'Élève'}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Bon retour !',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connectez-vous avec votre email ou téléphone',
                style: TextStyle(color: AppColors.darkGray),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email ou téléphone',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Minimum 6 caractères' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.errorRed)),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/auth/forgot-password'),
                  child: const Text('Mot de passe oublié ?'),
                ),
              ),
              const SizedBox(height: 24),
              LoadingButton(label: 'Se connecter', isLoading: _isLoading, onPressed: _login),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push('/auth/offline'),
                icon: const Icon(Icons.wifi_off),
                label: const Text('Connexion hors ligne'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pas de compte ?'),
                  TextButton(
                    onPressed: () => context.push(
                      '/auth/register/${isTeacher ? 'teacher' : 'student'}',
                    ),
                    child: const Text('Créer un compte'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
