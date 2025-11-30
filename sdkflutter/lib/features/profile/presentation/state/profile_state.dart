import '../../data/models/user_model.dart';
import '../../../../core/errors/faillures.dart';

/// Représente l'état de l'écran profil.
class ProfileState {
  final bool isLoading;
  final UserModel? user;
  final Failure? failure;

  const ProfileState({
    required this.isLoading,
    required this.user,
    required this.failure,
  });

  /// État initial : pas de données, pas d'erreur, pas de chargement.
  factory ProfileState.initial() {
    return const ProfileState(
      isLoading: false,
      user: null,
      failure: null,
    );
  }

  /// Crée une copie de l'état avec certaines valeurs modifiées.
  ProfileState copyWith({
    bool? isLoading,
    UserModel? user,
    Failure? failure,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      failure: failure,
    );
  }

  /// Indique si un utilisateur a été correctement chargé.
  bool get hasUser => user != null && failure == null;
}
