import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Réinitialisation du mot de passe.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _controller = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mark_email_read, size: 64, color: AppColors.emeraldGreen),
                  const SizedBox(height: 16),
                  Text(
                    'Instructions envoyées !',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vérifiez votre email ou SMS pour réinitialiser votre mot de passe.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.darkGray),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Entrez votre email ou téléphone',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Email ou téléphone',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),
                  LoadingButton(
                    label: 'Envoyer',
                    isLoading: _loading,
                    onPressed: _submit,
                  ),
                ],
              ),
      ),
    );
  }
}
