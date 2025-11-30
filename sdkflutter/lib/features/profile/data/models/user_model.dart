/// Modèle utilisateur de l'API
class UserModel {
  final String firstName;
  final String lastName;
  final String avatarUrl;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
  });

  /// Crée un [UserModel] à partir de l'API
  ///
  /// Paramètres
  /// [json] : données de l'API
  ///
  /// Return
  /// - l'instance [UserModel] remplie à partir du JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    String avatar = '';
    if (json['picture'] != null && json['picture'] is List) {
      final pictures = json['picture'] as List;
      final smallPic = pictures.firstWhere(
            (p) => p['label'] == 'small',
        orElse: () => pictures.first,
      );
      avatar = smallPic['url'] ?? '';
    }

    return UserModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatarUrl: avatar,
    );
  }
}
