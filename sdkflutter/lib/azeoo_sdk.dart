import 'package:flutter/widgets.dart';
import '../features/profile/presentation/app/azeoo_profile_app.dart';

/// Point d'entrée public du SDK Azeoo.
class AzeooSdk {
  final String baseUrl;
  final String token;

  AzeooSdk({
    required this.baseUrl,
    required this.token,
  });

  /// Construit le widget racine du module profil.
  ///
  /// - [userId] : identifiant utilisateur fourni par l'application hôte.
  Widget buildProfileRoot({required String userId}) {
    return AzeooProfileApp(
      baseUrl: baseUrl,
      token: token,
      userId: userId,
    );
  }
}
