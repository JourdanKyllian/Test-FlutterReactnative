/// Enum des types d'erreur.
enum FailureType {
  notFound,
  network,
  unauthorized,
  server,
  unknown,
}

/// Classe représentant une erreur type.
class Failure {
  final FailureType type;
  final String? message;

  Failure(this.type, {this.message});

  @override
  String toString() => 'Failure($type, message: $message)';

}

/// Message d'erreur pour l'affichage d'un profil.
String profileFailureToMessage(Failure failure) {
  switch (failure.type) {
    case FailureType.notFound:
      return 'Aucun profil lié à cet identifiant.';
    case FailureType.network:
      return 'Problème de connexion. Vérifiez votre réseau.';
    case FailureType.unauthorized:
      return 'Accès non autorisé. Vérifiez le token.';
    case FailureType.server:
      return 'Erreur serveur. Réessayez plus tard.';
    case FailureType.unknown:
    default:
      return failure.message ?? 'Erreur inconnue lors du chargement du profil.';
  }
}
