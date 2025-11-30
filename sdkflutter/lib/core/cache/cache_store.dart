/// Représente une entrée de cache avec une valeur et sa date d'enregistrement.
class CacheEntry<T> {
  final T value;
  final DateTime timestamp;

  CacheEntry(this.value, this.timestamp);
}

/// Cache mémoire générique avec gestion d'expiration (timeToLive).
///
/// - [T] : type de la valeur mise en cache (ex : UserModel).
class CacheStore<T> {
  final Duration timeToLive;
  final Map<String, CacheEntry<T>> _store = {};

  CacheStore({required this.timeToLive});

  /// Récupère la valeur associée à [key] si elle existe et n'est pas expirée.
  ///
  /// Retourne `null` si :
  /// - la clé n'existe pas,
  /// - ou si l'entrée est expirée (elle est alors supprimée du cache).
  T? get(String key) {
    final entry = _store[key];
    if (entry == null) return null;

    final isExpired = DateTime.now().difference(entry.timestamp) > timeToLive;
    if (isExpired) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  /// Enregistre une valeur [value] dans le cache sous la clé [key].
  void set(String key, T value) {
    _store[key] = CacheEntry(value, DateTime.now());
  }

  /// Supprime l'entrée de cache associée à [key].
  void invalidate(String key) {
    _store.remove(key);
  }

  /// Vide complètement le cache.
  void clear() {
    _store.clear();
  }
}
