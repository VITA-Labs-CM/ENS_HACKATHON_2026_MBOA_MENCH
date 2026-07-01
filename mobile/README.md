# MBOA MENCH — Application Flutter

**L'École dans la poche** — Plateforme EdTech offline-first pour le Cameroun.

## Stack technique

| Composant | Technologie |
|-----------|-------------|
| Framework | Flutter 3.x / Dart 3.x |
| State | Riverpod |
| Navigation | GoRouter (StatefulShellRoute) |
| UI | Material Design 3 |
| Graphiques | fl_chart |
| Animations | flutter_animate |
| Persistance | shared_preferences (prêt pour Drift) |

## Architecture (Feature First)

```
lib/
├── main.dart
├── core/
│   ├── constants/     # AppConstants, enums (rôles, stages download…)
│   ├── theme/         # Couleurs MBOA MENCH, thèmes clair/sombre
│   ├── router/        # GoRouter — élève + enseignant
│   ├── providers/     # Session, thème, navigation
│   ├── models/        # Entités (prêtes pour Drift/API)
│   ├── data/          # MockData — données simulées
│   └── widgets/       # Composants réutilisables
└── features/
    ├── shared/auth/   # Connexion, inscription, rôle, offline
    ├── student/       # Interface Élève (ÉduPack + EduLocal)
    └── teacher/       # Interface Enseignant (EduLocal AI)
```

## Interfaces incluses

### Élève
- Splash animé, Onboarding (4 pages)
- Auth : connexion, inscription, mot de passe oublié, mode hors ligne
- Dashboard : progression, temps d'étude, objectifs
- 5 onglets : Accueil, Cours, IA, Progression, Profil
- Cours → Chapitres (verrouillage 80 %) → Lecteur → Quiz
- Assistant IA (UI chat, RAG à brancher)
- Packs pédagogiques + Modèles IA (checkpoints visuels)
- Notifications, Paramètres

### Enseignant
- Dashboard avec stats et graphiques
- Classes (CRUD, QR, codes invitation)
- Cours, Élèves (statuts : à jour / retard / difficulté)
- Salle locale (hotspot simulé), Ressources, Livres MINESEC
- Génération IA, Épreuves, Vidéos, Analyse IA
- Tickets, Export packs, Bibliothèque, Notifications, Paramètres

## Lancer l'application

```bash
cd mobile
flutter pub get
flutter run -d linux    # Desktop Linux
flutter run -d android  # Android
flutter run -d windows  # Windows (enseignant)
```

## Prochaines intégrations

- **Drift (SQLite)** : remplacer MockData
- **RAG / ONNX / TFLite** : assistant IA Palier 1 & 2
- **FastAPI** : sync cloud enseignant
- **Chiffrement local** : résultats quiz, messages outbox

## Identité visuelle

- Bleu électrique `#0066FF`
- Vert émeraude `#00C896`
- Orange accent `#FF8C42`
- Dégradés subtils bleu → vert
