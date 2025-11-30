import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../../../core/cache/cache_store.dart';
import '../../../../core/errors/faillures.dart';

/// Service responsable de la récupération et du cache du profil utilisateur.
class UserService {
  // URL de base de l'API (ex: https://api.azeoo.dev/v1)
  final String baseUrl;

  // Cache mémoire pour les profils utilisateur.
  final CacheStore<UserModel> _cacheStore;

  UserService({
    required this.baseUrl,
    required CacheStore<UserModel> cacheStore,
  }) : _cacheStore = cacheStore;

  /// Récupère le profil d'un utilisateur depuis l'API, avec le cache.
  ///
  /// Retourne un [Failure] en cas d'erreur métier (notFound, network, etc.).
  Future<UserModel> fetchUserProfile(String userId, String token) async {
    // Lecture dans le cache si disponible
    final cached = _cacheStore.get(userId);
    if (cached != null) {
      return cached;
    }

    // Appel API
    final url = Uri.parse('$baseUrl/users/me');

    http.Response response;
    try {
      response = await http.get(
        url,
        headers: {
          'Accept-Language': 'fr-FR',
          'X-User-Id': userId,
          'Authorization': 'Bearer $token',
        },
      );
    } on SocketException {
      // Erreur de réseau (pas de connexion, DNS, etc.)
      throw Failure(FailureType.network);
    } catch (e) {
      // Toute autre erreur imprévue côté client
      throw Failure(
        FailureType.unknown,
        message: e.toString(),
      );
    }

    // Gestion des codes HTTP
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final user = UserModel.fromJson(json);

      // Enregistrement dans le cache
      _cacheStore.set(userId, user);

      return user;
    } else if (response.statusCode == 404) {
      throw Failure(FailureType.notFound);
    } else if (response.statusCode == 401) {
      throw Failure(FailureType.unauthorized);
    } else if (response.statusCode >= 500) {
      throw Failure(FailureType.server);
    } else {
      throw Failure(
        FailureType.unknown,
        message: 'Failed to load user profile (status: ${response.statusCode})',
      );
    }
  }

  /// Force un rafraîchissement du profil en ignorant le cache.
  Future<UserModel> refreshUserProfile(String userId, String token) async {
    _cacheStore.invalidate(userId);
    return fetchUserProfile(userId, token);
  }
}
