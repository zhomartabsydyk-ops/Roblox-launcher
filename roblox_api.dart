import 'dart:convert';
import 'package:http/http.dart' as http;

/// Только публичные эндпоинты Roblox: без авторизации и без cookie.
/// Roblox может менять API, поэтому ошибки обрабатываем мягко.
class RobloxApi {
  static const _headers = {'Content-Type': 'application/json'};

  /// Поиск пользователя по нику -> id
  Future<Map<String, dynamic>?> findUser(String username) async {
    final r = await http.post(
      Uri.parse('https://users.roblox.com/v1/usernames/users'),
      headers: _headers,
      body: jsonEncode({'usernames': [username], 'excludeBannedUsers': true}),
    );
    if (r.statusCode != 200) return null;
    final data = (jsonDecode(r.body)['data'] as List);
    return data.isEmpty ? null : data.first as Map<String, dynamic>;
  }

  /// Публичный список друзей пользователя
  Future<List<Map<String, dynamic>>> friends(int userId) async {
    final r = await http.get(
      Uri.parse('https://friends.roblox.com/v1/users/$userId/friends'),
    );
    if (r.statusCode != 200) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(r.body)['data']);
  }

  /// Поиск игр по ключевому слову
  Future<List<Map<String, dynamic>>> searchGames(String query) async {
    try {
      final r = await http.get(Uri.parse(
        'https://apis.roblox.com/search-api/omni-search'
        '?searchQuery=${Uri.encodeQueryComponent(query)}'
        '&sessionId=3f1c2b7e-9a41-4d6e-8c55-2b7f0e1a9d34&pageType=all',
      ));
      if (r.statusCode != 200) return [];
      final groups = (jsonDecode(r.body)['searchResults'] as List?) ?? [];
      final out = <Map<String, dynamic>>[];
      for (final g in groups) {
        if (g['contentGroupType'] != 'Game') continue;
        for (final c in (g['contents'] as List)) {
          if (c['rootPlaceId'] == null) continue;
          out.add({
            'name': c['name'],
            'playerCount': c['playerCount'] ?? 0,
            'placeId': c['rootPlaceId'],
          });
        }
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  /// Миниатюры аватаров по списку userId
  Future<Map<int, String>> avatars(List<int> ids) async {
    if (ids.isEmpty) return {};
    final r = await http.get(Uri.parse(
      'https://thumbnails.roblox.com/v1/users/avatar-headshot'
      '?userIds=${ids.join(",")}&size=150x150&format=Png',
    ));
    if (r.statusCode != 200) return {};
    final list = jsonDecode(r.body)['data'] as List;
    return {
      for (final e in list)
        if (e['imageUrl'] != null) e['targetId'] as int: e['imageUrl'] as String
    };
  }
}
