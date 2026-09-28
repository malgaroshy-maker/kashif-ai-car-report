import 'dart:developer' as dev;

/// Manages API keys with rotation and cooldown tracking.
/// When a key encounters a rate limit (HTTP 429 / 503), it enters a cooldown
/// period, and subsequent calls automatically pick the next available active key.
class KeyPoolManager {
  static final KeyPoolManager instance = KeyPoolManager._();
  KeyPoolManager._();

  final Map<String, DateTime> _cooldowns = {};
  int _rotationPointer = 0;

  /// Returns candidate keys in rotation order.
  /// Keys not in cooldown are ordered first.
  /// If all keys are in cooldown, it still returns them (oldest cooldown first)
  /// and appends null (server fallback) at the end.
  List<String?> getCandidateKeys(List<String> userKeys) {
    if (userKeys.isEmpty) return [null];

    final now = DateTime.now();
    // Clean expired cooldowns
    _cooldowns.removeWhere((_, until) => now.isAfter(until));

    final activeKeys = <String>[];
    final coolingKeys = <String>[];

    final total = userKeys.length;
    for (int i = 0; i < total; i++) {
      final key = userKeys[(i + _rotationPointer) % total];
      if (_cooldowns.containsKey(key)) {
        coolingKeys.add(key);
      } else {
        activeKeys.add(key);
      }
    }

    // Sort cooling keys by cooldown expiry time (ascending)
    coolingKeys.sort((a, b) {
      final timeA = _cooldowns[a] ?? now;
      final timeB = _cooldowns[b] ?? now;
      return timeA.compareTo(timeB);
    });

    return [...activeKeys, ...coolingKeys, null];
  }

  /// Marks a key in cooldown for a given duration (default 3 minutes)
  void markCooldown(
    String? key, {
    Duration duration = const Duration(minutes: 3),
  }) {
    if (key == null || key.trim().isEmpty) return;
    final cleanKey = key.trim();
    _cooldowns[cleanKey] = DateTime.now().add(duration);
    _rotationPointer++;
    dev.log(
      '[KeyPoolManager] Key ${maskKey(cleanKey)} placed in cooldown for ${duration.inSeconds}s',
    );
  }

  /// Checks if a key is currently cooling down
  bool isCoolingDown(String key) {
    final expiry = _cooldowns[key.trim()];
    if (expiry == null) return false;
    if (DateTime.now().isAfter(expiry)) {
      _cooldowns.remove(key.trim());
      return false;
    }
    return true;
  }

  /// Clears cooldown for a key (e.g. after successful test)
  void clearCooldown(String key) {
    _cooldowns.remove(key.trim());
  }

  /// Helper to mask key for logging and UI display
  static String maskKey(String key) {
    final clean = key.trim();
    if (clean.length <= 10) return '••••••••';
    return '${clean.substring(0, 6)}...${clean.substring(clean.length - 4)}';
  }
}
