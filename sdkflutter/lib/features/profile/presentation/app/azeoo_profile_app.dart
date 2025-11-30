import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/user_model.dart';
import '../../data/services/user_service.dart';
import '../../../../core/cache/cache_store.dart';
import '../pages/info_page.dart';
import '../pages/profile_page.dart';
import '../state/profile_controller.dart';
import '../state/tabbar_controller.dart';

/// Mini-application Flutter embarquée dans le SDK.
/// Gère une bottom tabbar (2 onglets) sans utiliser setState.
class AzeooProfileApp extends StatelessWidget {
  final String baseUrl;
  final String token;
  final String userId;

  const AzeooProfileApp({
    super.key,
    required this.baseUrl,
    required this.token,
    required this.userId,
  });
  
  @override
  Widget build(BuildContext context) {
    // Cache minimal en mémoire pour les profils utilisateur
    final cacheDuration = const Duration(minutes: 1);
    final cacheStore = CacheStore<UserModel>(timeToLive: cacheDuration);

    final userService = UserService(
      baseUrl: baseUrl,
      cacheStore: cacheStore,
    );
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileController(userService),
        ),
        ChangeNotifierProvider(
          create: (_) => TabControllerNotifier(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _ProfileScaffold(),
      ),
    );
  }
}

/// Widget racine de l'application
class _ProfileScaffold extends StatelessWidget {
  const _ProfileScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final tabController = context.watch<TabControllerNotifier>();
    final currentIndex = tabController.currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil utilisateur'),
      ),
      body: _buildBody(currentIndex, context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: tabController.setIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Infos',
          ),
        ],
      ),
    );
  }

  /// Retourne le widget associé à l'index actuel de la barre de navigation.
  ///
  /// - [index] : index actuel de la barre de navigation.
  /// - [context] : contexte de l'appel.
  Widget _buildBody(int index, BuildContext context) {
    final app = context.findAncestorWidgetOfExactType<AzeooProfileApp>();
    if (app == null) {
      // Fallback très simple si jamais le widget n'est pas trouvé.
      return const Center(child: Text('Configuration invalide du SDK'));
    }

    switch (index) {
      case 0:
        return ProfilePage(
          userId: app.userId,
          token: app.token,
        );
      case 1:
      default:
        return const InfoPage();
    }
  }
}