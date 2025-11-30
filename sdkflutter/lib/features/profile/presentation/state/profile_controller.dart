import 'package:flutter/foundation.dart';
import '../../data/services/user_service.dart';
import '../../../../core/errors/faillures.dart';
import 'profile_state.dart';

/// Contrôleur responsable de charger / rafraîchir le profil utilisateur.
class ProfileController extends ChangeNotifier {
  final UserService _userService;

  ProfileState _state = ProfileState.initial();
  ProfileState get state => _state;

  ProfileController(this._userService);

  /// Charge le profil en fonction de [userId].
  ///
  /// - [userId] : identifiant utilisateur (provenant de l'app React Native).
  /// - [token] : jeton d'authentification fourni par le client du SDK.
  Future<void> loadProfile({
    required String userId,
    required String token,
  }) async {
    _state = _state.copyWith(
      isLoading: true,
      failure: null,
    );
    notifyListeners();

    try {
      final user = await _userService.fetchUserProfile(userId, token);

      _state = _state.copyWith(
        isLoading: false,
        user: user,
        failure: null,
      );
      notifyListeners();
    } on Failure catch (failure) {
      _state = _state.copyWith(
        isLoading: false,
        user: null,
        failure: failure,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        user: null,
        failure: Failure(
          FailureType.unknown,
          message: e.toString(),
        ),
      );
      notifyListeners();
    }
  }

  /// Rafraîchit le profil en ignorant le cache.
  Future<void> refreshProfile({
    required String userId,
    required String token,
  }) async {
    _state = _state.copyWith(
      isLoading: true,
      failure: null,
    );
    notifyListeners();

    try {
      final user = await _userService.refreshUserProfile(userId, token);

      _state = _state.copyWith(
        isLoading: false,
        user: user,
        failure: null,
      );
      notifyListeners();
    } on Failure catch (failure) {
      _state = _state.copyWith(
        isLoading: false,
        user: null,
        failure: failure,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        user: null,
        failure: Failure(
          FailureType.unknown,
          message: e.toString(),
        ),
      );
      notifyListeners();
    }
  }
}
