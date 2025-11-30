# Azeoo – Test technique Flutter SDK + React Native

Ce repo contient :

- **`sdkflutter/`** : un SDK Flutter qui affiche un profil utilisateur.
- **`Reactflut/`** : une application React Native qui gère la saisie de l’`userId` et prépare l’appel au SDK Flutter.

L’objectif : montrer la conception d’un SDK Flutter réutilisable autour du profil utilisateur, avec une app React Native simple qui lui fournit l’`userId`.

---

## 1. Architecture globale

### Dossiers principaux

- `sdkflutter/` (SDK Flutter)
  - `lib/core/cache/cache_store.dart` : cache mémoire générique avec durée de vie (TTL).
  - `lib/core/errors/failures.dart` : modèle d’erreurs métier + template messages d’erreur.
  - `lib/features/profile/data/models/user_model.dart` : modèle de profil utilisateur.
  - `lib/features/profile/data/services/user_service.dart` : accès API + gestion du cache.
  - `lib/features/profile/presentation/state/profile_state.dart` : état de l’écran profil.
  - `lib/features/profile/presentation/state/profile_controller.dart` : logique de chargement/rafraîchissement.
  - `lib/features/profile/presentation/state/tabbar_controller.dart` : état de la bottom tabbar Flutter.
  - `lib/features/profile/presentation/pages/profile_page.dart` : UI du profil (chargement, succès, erreurs, pull‑to‑refresh).
  - `lib/features/profile/presentation/pages/info_page.dart` : seconde page “Infos”.
  - `lib/features/profile/presentation/app/azeoo_profile_app.dart` : mini‑application Flutter avec bottom tabbar (2 onglets).
  - `lib/azeoo_sdk.dart` : API publique du SDK.
  - `lib/azeoo_entrypoint.dart` ou `lib/main.dart` : point d’entrée qui lance le SDK en standalone.

- `Reactflut/` (app React Native)
  - `src/context/UserIdContext.tsx` : contexte global `userId`.
  - `src/navigation/RootTabs.tsx` : tab bar RN avec 2 onglets.
  - `src/screens/UserIdScreen.tsx` : saisie / sauvegarde de l’`userId`.
  - `src/screens/ProfileScreen.tsx` : écran qui affichera le profil via le SDK (aujourd’hui placeholder + `userId`).

---

## 2. SDK Flutter (`sdkflutter`)

### 2.1 Objectifs et API

Le SDK affiche un profil utilisateur en interrogeant l’API fournie :

- `GET https://api.azeoo.dev/v1/users/me`
- Headers :
  - `Accept-Language: fr-FR`
  - `X-User-Id: <userId>`
  - `Authorization: Bearer <token>`

L’API publique du SDK est centrée sur :

- la classe `AzeooSdk`, initialisée avec `baseUrl` et `token` ;
- la méthode `buildProfileRoot(userId: ...)` qui renvoie le widget racine du module profil.

Idée d’utilisation dans une app Flutter hôte :

- créer un `AzeooSdk` avec `baseUrl` et `token`,
- appeler `runApp(sdk.buildProfileRoot(userId: '1'))` pour afficher l’écran profil.

### 2.2 Architecture Flutter

#### Séparation `core` / `features`

- `core` contient les briques réutilisables :
  - **cache** (générique),
  - **erreurs** (modèle d’erreurs métier et mapping vers un message utilisateur).
- `features/profile` regroupe tout ce qui concerne la feature “profil” :
  - **data** : modèles et service API,
  - **presentation/state** : controllers et états,
  - **presentation/pages** : UI.

  Pourquoi ce choix :

  - “ce qui dépend du réseau" dans `data`,
  - “ce qui dépend de l’UI" dans `presentation`,
  - “ce qui est générique" dans `core`.
  

#### State management (sans `setState`)

Contraintes du test :

- ne pas utiliser `setState`,
- avoir un state management “avancé”.

Choix retenu :

- **`ChangeNotifier` + `Provider`** (via `MultiProvider`) pour :
  - `ProfileController` : gère le cycle de vie du profil (loading, succès, erreur, refresh),
  - `TabControllerNotifier` : gère l’index de la tabbar Flutter.

  Pourquoi `Provider` :

  - sépare bien la logique de l’UI,
  - évite les appels directs au service dans les widgets (`FutureBuilder` avec HTTP dans `build`),

Concrètement :

  - les widgets n’appellent jamais directement l’API,
  - ils lisent un état (`ProfileState`) exposé par `ProfileController`,
  - quand l’état change, `notifyListeners()` reconstruit seulement les parties concernées.


#### Gestion des erreurs 

Dans `lib/core/errors/failures.dart` :

- `enum FailureType { notFound, network, unauthorized, server, unknown }`
- `class Failure` :
  - porte un `type` + un `message` optionnel,
- `String profileFailureToMessage(Failure failure)` :
  - convertit le type d’erreur en message utilisateur pour l’écran de profil.

Pourquoi ce choix :

- en pratique, on veut différencier les cas :
  - “profil introuvable” (404),
  - “pas de réseau”,
  - “token invalide”,
  - “erreur serveur”.

#### Gestion du cache
  
 Dans `lib/core/cache/cache_store.dart` :

- `CacheStore<T>` gère :
  - une map `Map<String, T>` pour les valeurs,
  - une map `Map<String, DateTime>` pour les timestamps,
  - une durée de vie (TTL) configurable.
- `get(key)` :
  - retourne la valeur si elle n’est pas expirée,
  - sinon `null`.
- `set(key, value)` :
  - met à jour valeur + timestamp.

  Dans `UserService` :

- avant d’appeler l’API, on regarde le cache :
  - si `userId` est présent et non expiré → on renvoie le `UserModel` immédiatement,
  - sinon → on appelle `/users/me`, puis on stocke la réponse dans le cache.
- `refreshUserProfile` ignore le cache et force un nouvel appel API.

#### UI & navigation interne au SDK 
  `AzeooProfileApp` :

- encapsule toute la logique du SDK dans une mini‑app Flutter :

  - initialise le **cache**, le **service** et les **contrôleurs** dans un `MultiProvider`,

    - `AppBar(title: 'Profil utilisateur')`,
    - `BottomNavigationBar` (2 onglets),
    - body :
      - onglet 0 : `ProfilePage(userId, token)`,
      - onglet 1 : `InfoPage()`.

- le sujet demande une **tabbar (2 onglets) gérée par Flutter**,
- le SDK fournit un seul widget racine,
  - l’app React Native ou native n’a pas besoin de connaître la navigation interne du SDK.


### 2.3 Entrypoint embarqué

Un entrypoint Flutter (lib/azeoo_entrypoint.dart) lance uniquement le SDK:
  - instanciation d’AzeooSdk avec baseUrl + token de test,
  - appel à runApp(sdk.buildProfileRoot(userId: ...)).

Cet entrypoint sert à deux choses:
  - tester le SDK en standalone avec flutter run (sans React Native),
  - offrir un point d’entrée clair pour un moteur Flutter natif (Android/iOS) ou pour tout autre hôte qui voudrait embarquer le SDK.

---

## 3. Application React Native (`Reactflut`)

### 3.1 Objectifs

- Onglet 1 : permettre à l’utilisateur de saisir et sauvegarder un `userId` (par exemple `1` ou `3`).
- Onglet 2 (“Profile”) :
  - lire l’`userId` global,
  - l’afficher (pour prouver le flux de données),
  - servir de point d’ancrage pour le SDK Flutter intégré via un module natif.

### 3.2 Navigation et gestion de l’`userId`

- **Navigation**
  - top tabbar avec deux écrans :
    - `UserIdScreen` (saisie),
    - `ProfileScreen` (profil).

**`UserIdContext`**
- Définit un contexte global :
  - `userId: string | null`,
  - `setUserId: (id: string | null) => void`.
  
- Le provider est monté à la racine (`App.tsx`), autour de `NavigationContainer`.
- le contexte est une solution standard dans React pour partager une petite donnée globale comme un identifiant utilisateur.

**`UserIdScreen`**
- `TextInput` :
  - clavier numérique (`keyboardType="number-pad"`),
  - nettoyage de l’entrée avec une regex pour ne garder que les chiffres

- ce choix permet :
    - d’éviter que des lettres ou coller/coller du texte cassent la logique,
    - d’aligner avec l’idée que l’`userId` est un identifiant numérique côté API.

- Bouton “Save” :
  - met à jour le contexte global
  - Affiche ensuite `UserId global actuel : X` pour prouver le bon fonctionnement du contexte.


**`ProfileScreen`**
  - lit `userId` dans le contexte,
  - affiche un placeholder + la valeur actuelle de `userId` (prouve que l’`userId` circule bien du formulaire vers l’onglet 2),
  - sert de point d’ancrage où le SDK Flutter serait affiché via un bridge natif.

> Remarque sur la navigation (double tabbar)

Le sujet demandait à la fois :
- une tabbar entièrement gérée par le SDK Flutter,
- et une tabbar React Native à deux onglets.

Techniquement, il est possible d’embarquer une vue Flutter dans un écran React Native, mais cela demande une intégration native assez avancée (configuration Gradle, moteur Flutter partagé, Native Modules, etc.). 

Compte tenu du temps imparti et de mon niveau (alternance / étudiant), j’ai choisi de :
- implémenter une tabbar fonctionnelle dans le SDK Flutter (démontrable en lançant l'appli) ;
- implémenter une tabbar React Native simple qui gère la navigation entre la saisie de l’`userId` et un écran “hôte” du SDK.

---

## 4. Intégration native du SDK – principe général

Le sujet demande que :
> L’appel du SDK doit être fait de manière propre, soit via un package Flutter Module intégré, soit via Native Modules dans React Native.

L’architecture prévue est la suivante :

1. **Côté Flutter**
   - le SDK expose un point d’entrée unique :
     - `AzeooSdk(baseUrl, token)` + `buildProfileRoot(userId)`,
   - tout le reste (API, cache, navigation, erreurs) est géré dans le module.

2. **Côté iOS / Android**
   - l’application hôte initialise un moteur Flutter (FlutterEngine) au démarrage,
   - ce moteur lance l’entrypoint du SDK,
   - un écran natif (UIViewController / Activity) affiche ensuite le contenu du SDK Flutter.

3. **Côté React Native**
   - un module natif expose une méthode simple comme `openProfile(userId)`,
   - le code RN appelle cette méthode depuis l’onglet 2 en lui passant l’`userId` stocké dans le contexte,
   - le module natif se charge d’ouvrir l’écran Flutter déjà prêt dans le SDK.

### Travail réellement effectué

- SDK Flutter complet et testable en standalone (API, erreurs, cache, navigation).
- App React Native fonctionnelle (navigation, saisie + stockage du `userId`).

### Limites assumées

- L’intégration native n’est pas finalisée de bout en bout.
- La priorité a été mise sur :
  - un SDK Flutter propre et structuré,
  - une app React Native claire,
  - une compréhension correcte de l’architecture d’intégration, même si tous les détails du bridge natif ne sont pas encore maîtrisés.

---

## 5. Choix techniques principaux

### Côté Flutter

  - **State management : `Provider` + `ChangeNotifier` plutôt que `setState`**.
    - `ChangeNotifier` + `Provider` sont accessibles, tout en :
      - séparant la logique (dans `ProfileController`) de la vue (`ProfilePage`),
      - rendant possible l’injection de dépendances (`UserService`, `CacheStore`),
      - étant l’un des patterns recommandés pour Flutter
  - **Architecture : séparation `core` / `features`, découpage données / état / pages**.
    - séparation de:
      - `core` pour les fonctions communes à plusieurs features,
      - `features/profile` pour tout ce qui est propre au profil,
      - correspond à une “clean architecture” et facilite l’évolution du SDK.
  - **API & cache**.
    - Le couple `UserService` + `CacheStore` permet :
      - de centraliser les règles d’accès à `/users/me`,
      - de limiter les appels HTTP (cache minimal en mémoire),
      - de séparer la responsabilité “accès réseau + cache” du reste du code.
  - **Modèle d’erreurs `Failure` centralisé**
    - `FailureType` (notFound, network, unauthorized, server, unknown),
    - une classe `Failure`,
    - et une fonction `profileFailureToMessage`
    - on obtient :
      - une seule source pour les erreurs,
      - une UI qui décide facilement quoi afficher en fonction du type d’erreur,
      - une possibilité d’ajouter d’autres features en réutilisant la même approche.

### Côté React Native

  - Le sujet impose 2 onglets.
  - Utiliser un `BottomTabNavigator` standard avec 2 écrans (`UserIdScreen`, `ProfileScreen`) est :
    - aligné avec les bonnes pratiques React Navigation,
    - suffisant pour montrer la logique de flux entre les onglets,
    - facile à lire pour un recruteur familier de RN.
  - **`UserIdContext` plutôt que Redux ou un simple `useState` local**
    - Un contexte (`UserIdContext`) est le bon compromis :
      - la mise en place reste simple (juste un hook et un provider),
      - on garde la possibilité de le combiner plus tard avec une persistance (AsyncStorage).
  - **Filtrage du champ `userId` par regex**
    - `keyboardType="number-pad"` limite déjà la saisie, mais on peut encore coller du texte.
    - L’utilisation d’une regex simple (`text.replace(/[^0-9]/g, '')`) :
      - garantit que l’état `userId` reste toujours numérique,
      - évite de gérer des cas d’erreur côté Flutter si une valeur non valide passe.


---

## 6. Lancer les projets

### 6.1 Lancer le SDK Flutter seul

Dans le dossier `sdkflutter/` :
```bash
flutter pub get
flutter run # lance l’entrypoint et affiche directement l’écran profil
```
L’entrypoint lance directement l’écran profil du SDK en fonction du `userId`.

### 6.2 Lancer l’app React Native (iOS)

Dans `Reactflut/` :

```bash
npm install # ou yarn
cd ios
pod install
cd ..
npx react-native run-ios # ou run-android
```

- Onglet 1 :
  - saisir un `userId`,
  - cliquer sur “Save” → le `userId` global se met à jour.
- Onglet 2 :
  - affiche la valeur actuelle du `userId` et représente le point d’intégration prévu pour le SDK Flutter.


