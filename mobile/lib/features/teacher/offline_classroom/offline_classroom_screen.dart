import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shared_widgets.dart';

/// Salle de classe locale — hotspot Wi-Fi simulé.
class OfflineClassroomScreen extends StatefulWidget {
  const OfflineClassroomScreen({super.key});

  @override
  State<OfflineClassroomScreen> createState() => _OfflineClassroomScreenState();
}

class _OfflineClassroomScreenState extends State<OfflineClassroomScreen> {
  bool _serverRunning = false;
  final _connectedDevices = ['Samsung A12 — Amina', 'Tecno Spark — Ibrahim'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salle de classe locale')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _serverRunning
                ? GradientCard(
                    child: Column(
                      children: [
                        const Icon(Icons.wifi_tethering, color: Colors.white, size: 48),
                        const SizedBox(height: 12),
                        const Text('Serveur actif', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Réseau : MBOA-MENCH-CLASS', style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
                        Text('Mot de passe : mb2026!', style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                  )
                : const Card(
                    color: AppColors.lightGray,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Démarrez le serveur local pour distribuer des packs sans Internet.'),
                    ),
                  ),
            const SizedBox(height: 20),
            if (_serverRunning) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.qr_code_2, color: AppColors.electricBlue),
                  title: const Text('QR Code de connexion'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.tag, color: AppColors.emeraldGreen),
                  title: Text('Code classe : MBOA-TD24'),
                ),
              ),
              SectionHeader(title: 'Appareils connectés (${_connectedDevices.length})'),
              ..._connectedDevices.map((d) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.phone_android),
                      title: Text(d),
                      trailing: const Icon(Icons.check_circle, color: AppColors.emeraldGreen, size: 20),
                    ),
                  )),
              const SectionHeader(title: 'Transferts en cours'),
              const LinearProgressIndicator(value: 0.65),
              const SizedBox(height: 8),
              const Text('Pack Maths — 65 %', style: TextStyle(color: AppColors.darkGray)),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => setState(() => _serverRunning = !_serverRunning),
              icon: Icon(_serverRunning ? Icons.stop : Icons.play_arrow),
              label: Text(_serverRunning ? 'Arrêter le serveur' : 'Démarrer le serveur local'),
              style: FilledButton.styleFrom(
                backgroundColor: _serverRunning ? AppColors.errorRed : AppColors.emeraldGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cloud),
              label: const Text('Mode Cloud — Rejoindre via code Internet'),
            ),
          ],
        ),
      ),
    );
  }
}
