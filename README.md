# ENS_HACKATHON_2026_MBOA_MENCH

# Cahier des charges — MVP
## Plateforme d'apprentissage offline-first pour élèves des zones défavorisées (Cameroun)

*Nom de projet provisoire — à définir. Version 1.0.*

---

## 1. Contexte et objectifs

### 1.1 Problème adressé
Les élèves en classe d'examen (3e, Probatoire, Terminale/Tle) dans les zones défavorisées du Cameroun (extrême-nord notamment) font face à :
- Un accès internet rare, cher et instable
- Une pénurie d'enseignants dans certaines matières
- Un manque de ressources pédagogiques structurées et alignées sur le format d'examen (APC)
- Un manque de suivi individualisé de leur progression

### 1.2 Vision produit
Une plateforme hybride **Google Classroom × NotebookLM**, pensée *offline-first*, permettant à un enseignant de structurer une classe/matière et à un élève de progresser à son rythme sur les supports de cette classe, avec une assistance IA basée sur ces mêmes supports — disponible même sans connexion.

### 1.3 Objectifs du MVP
- Valider l'usage réel en conditions de terrain (connectivité faible, matériel bas de gamme)
- Prouver la valeur du couple "contenu offline + IA locale" sur l'apprentissage
- Fournir à l'enseignant un minimum de visibilité sur la progression de sa classe
- Rester déployable avec une infrastructure légère et un coût de data minimal pour l'élève

---

## 2. Public cible et personas

### Persona 1 — Élève (utilisateur principal)
- En classe d'examen (3e/Proba/Tle), zone rurale ou péri-urbaine défavorisée
- Smartphone Android d'entrée de gamme (2-4 Go RAM), parfois partagé en famille
- Connexion internet intermittente, 2G/3G, données chères
- Accès électricité parfois irrégulier (recharge solaire dans certaines zones)
- Niveau de littératie numérique basique à moyen

### Persona 2 — Enseignant
- Peut enseigner plusieurs matières faute de personnel disponible
- Connexion un peu plus stable que l'élève (établissement, cybercafé, domicile)
- Veut créer du contenu une fois et le réutiliser, sans y passer des heures
- A besoin d'un signal simple ("qui est en difficulté ?") plutôt que d'un dashboard complexe

---

## 3. Périmètre fonctionnel du MVP (MoSCoW)

### 3.1 MUST HAVE (cœur du MVP)

**Authentification & comptes**
- Inscription/connexion enseignant et élève (email ou téléphone + mot de passe)
- Fonctionnement possible en mode déjà-connecté hors ligne (session persistante locale)

**Gestion des classes**
- Création de classe/mini-classe par matière (enseignant)
- Génération d'un code d'invitation par classe
- Rejoindre une classe via code (élève)
- Un enseignant peut gérer plusieurs classes/matières

**Contenu pédagogique**
- Upload de supports par l'enseignant (texte, PDF, éventuellement audio simple)
- Organisation des supports en modules/chapitres
- Téléchargement explicite d'un module par l'élève (action volontaire, pas automatique)
- Consultation des modules téléchargés en mode 100% hors ligne

**IA embarquée — Palier 1 (MVP)**
- Indexation locale des supports téléchargés (retrieval par embeddings légers, local)
- Banque de questions/quiz au format APC générée côté serveur au moment de l'upload (quand l'enseignant a de la connexion)
- Réponse aux questions de l'élève hors ligne par recherche + extraction du passage pertinent dans les supports, avec priorité à la banque pré-générée
- *(Palier 2 — génération conversationnelle via petit LLM on-device — reporté en V1, voir section 8)*

**Quiz et auto-évaluation**
- Passage de quiz liés à un module, disponible hors ligne
- Correction locale immédiate (feedback à l'élève)
- Stockage local des résultats en attente de synchronisation

**Discussions de classe**
- Fil de discussion par classe (élève ↔ enseignant, élève ↔ élève)
- Rédaction de messages hors ligne, envoi en file d'attente
- Synchronisation à la reconnexion (voir section 6)

**Suivi enseignant (basique)**
- Liste des élèves de la classe avec statut simple : à jour / en retard / en difficulté
- Vue par élève : modules complétés, scores aux quiz, dernière activité
- Alerte simple si un élève n'a pas progressé depuis X jours ou échoue répétitivement sur un module

**Synchronisation**
- Sync automatique à la détection de connexion : messages, résultats de quiz, manifest des nouveaux modules disponibles
- Téléchargement des fichiers lourds toujours en action séparée et volontaire
- Option "Wi-Fi uniquement" pour les téléchargements de contenu

### 3.2 SHOULD HAVE (si le temps le permet)
- Notifications locales (nouveau message, nouveau module disponible)
- Statistiques de temps passé par module pour l'enseignant
- Export simple des résultats de classe (CSV/PDF) pour l'enseignant
- Mode sombre / optimisation batterie

### 3.3 COULD HAVE (post-MVP, V1+)
- IA génératif on-device (Palier 2) pour les appareils plus puissants
- Contenu audio/vidéo léger dans les modules
- Système de badges/gamification pour motiver la régularité
- Classement anonymisé au sein de la classe (optionnel, activable par l'enseignant)
- Support multi-établissements avec rôle "directeur/coordinateur"

### 3.4 WON'T HAVE (explicitement hors périmètre MVP)
- Visioconférence ou cours en direct
- Paiement intégré / modèle payant (le MVP reste gratuit ou financé par établissement/ONG)
- Application native complètement indépendante par OS (on démarre PWA + éventuellement wrapper Capacitor unique)
- Génération de contenu par l'enseignant assistée par IA (création de supports) — l'IA sert l'élève, pas la création de cours, au MVP
- Correction automatique de rédactions longues (dissertations) par l'IA

---

## 4. Exigences non-fonctionnelles

| Catégorie | Exigence |
|---|---|
| **Offline-first** | Toute fonctionnalité MUST HAVE doit être utilisable sans connexion après le premier téléchargement de contenu |
| **Performance matériel** | Fonctionnel sur Android 8+, 2 Go de RAM minimum ; dégradation progressive au-delà (pas de crash) |
| **Consommation data** | Sync des métadonnées (messages, manifest, résultats) < 200 Ko par session type ; téléchargement de contenu toujours explicite |
| **Consommation batterie** | Pas de traitement IA en tâche de fond continue ; indexation/retrieval déclenchés à la demande |
| **Stockage local** | Gestion explicite de l'espace utilisé (voir/supprimer modules téléchargés), alerte si stockage plein |
| **Langue** | Interface et contenus en français ; prévoir structure i18n pour extension future (langues locales) |
| **Sécurité** | Chiffrement des données sensibles en local (résultats, messages en attente) ; HTTPS obligatoire pour la sync |
| **Accessibilité** | Interface utilisable par des élèves à littératie numérique basique (icônes claires, peu de texte, feedback visuel simple) |
| **Résilience réseau** | Toute requête réseau doit avoir un timeout court et un retry en arrière-plan, sans bloquer l'usage offline |

---

## 5. Architecture technique (résumé)

- **Backend** : Django + DRF, PostgreSQL, multi-tenant (établissement → enseignant → classe → élève)
- **Frontend web/PWA** : React, service worker pour cache applicatif, IndexedDB pour modules/progression/messages en attente
- **Mobile** : PWA installable au MVP ; évaluation d'un wrapper Capacitor si les limites de stockage PWA sont bloquantes en usage réel
- **IA (Palier 1)** :
  - Pipeline serveur : extraction texte des supports → génération banque Q/R et quiz format APC (API LLM cloud) au moment de l'upload enseignant
  - Package offline par module : contenu + banque pré-générée + index d'embeddings légers
  - Runtime local : modèle d'embeddings quantifié (léger, quelques dizaines de Mo) pour le retrieval, exécuté en WebAssembly
- **Sync** : endpoint unique `GET /sync?since=<timestamp>` retournant messages, manifest de modules, accusés de réception ; pattern outbox local avec UUID pour les envois élève → serveur
- **Notifications** : file d'attente locale, synchronisée à la reconnexion

*(Le détail du modèle de données et du protocole de sync peut être formalisé dans un document technique séparé si utile.)*

---

## 6. Contraintes spécifiques au contexte camerounais

- Coût de la data mobile élevé en zones comme l'extrême-nord → minimiser tout transfert non essentiel
- Couverture réseau 2G/3G dominante hors grandes villes → tolérance élevée à la latence, pas de dépendance à un flux temps réel
- Accès électricité irrégulier → l'app ne doit pas être gourmande en CPU/batterie en usage courant
- Partage d'appareil possible entre plusieurs membres d'une famille → prévoir un changement de compte simple et rapide
- Alignement avec le curriculum APC (Approche Par Compétences) → structure des quiz et questions doit suivre ce format dès la conception du modèle de données
- Disparité de niveau des enseignants selon les zones → l'outil de création de classe/module doit rester très simple, sans jargon technique

---

## 7. Phasage / Roadmap

| Phase | Contenu | Durée indicative |
|---|---|---|
| **MVP (V0)** | Fonctionnalités MUST HAVE de la section 3.1, testées sur un nombre restreint de classes pilotes | 8-12 semaines |
| **V1** | Ajout SHOULD HAVE + retours terrain du pilote + Palier 2 IA sur appareils compatibles | 6-8 semaines après pilote |
| **V2** | Élargissement des COULD HAVE selon retours (gamification, multi-établissements, audio/vidéo) | À définir selon traction |

---

## 8. Critères de succès du MVP

- Taux de complétion de module (% d'élèves qui terminent un module téléchargé)
- Taux de rétention hebdomadaire (élèves actifs après la première semaine)
- Nombre moyen de questions posées à l'IA par élève et par module
- Taux de réponses "utiles" de l'IA (feedback simple type pouce haut/bas)
- Taux de synchronisation réussie sans perte de données (messages/résultats) après période offline
- Satisfaction enseignant sur la visibilité offerte par le dashboard de suivi

---

## 9. Risques et mitigations

| Risque | Impact | Mitigation |
|---|---|---|
| Modules trop volumineux pour le stockage/la data des élèves | Élevé | Limiter le poids par module, compresser fortement, privilégier texte structuré à l'image/PDF lourd |
| Qualité insuffisante des réponses IA en mode extraction (Palier 1) | Moyen | Investir dans la qualité de la banque pré-générée côté serveur, feedback utilisateur pour amélioration continue |
| Faible adoption par les enseignants (charge de création de contenu) | Élevé | Fournir des modules de démarrage pré-remplis pour les matières/classes les plus courantes |
| Conflits de synchronisation (messages, résultats) | Faible-Moyen | Pattern outbox + UUID, pas de vrai risque de conflit sur données append-only |
| Abandon dû à la complexité perçue de l'app | Élevé | Tester l'UX en conditions réelles très tôt avec de vrais élèves du public cible |

---

*Document à faire évoluer avec les retours du pilote terrain. Prochaine étape suggérée : formaliser le modèle de données détaillé (entités, relations, schéma de versioning des modules) et le protocole de synchronisation.*
