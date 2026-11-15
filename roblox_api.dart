import 'dart:convert';
import 'package:http/http.dart' as http;

/// Только публичные эндпоинты Roblox: без авторизации и без cookie.
/// Roblox иногда меняет API, поэтому все ошибки обрабатываем мягко.
class RobloxApi {
  static const _headers = {'Content-Type': 'application/json'};
  static const _timeout = Duration(seconds: 15);

  Future<dynamic> _getJson(String url) async {
    try {
      final r = await http.get(Uri.parse(url)).timeout(_timeout);
      if (r.statusCode != 200) return null;
      return jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  /// Поиск пользователя по нику -> {id, name, displayName}
  Future<Map<String, dynamic>?> findUser(String username) async {
    try {
      final uri = Uri.parse('https://users.roblox.com/v1/usernames/users');
      final body = jsonEncode({
        'usernames': [username],
        'excludeBannedUsers': true,
      });
      var r = await http.post(uri, headers: _headers, body: body).timeout(_timeout);
      if (r.statusCode == 403 && r.headers['x-csrf-token'] != null) {
        r = await http
            .post(uri,
                headers: {..._headers, 'x-csrf-token': r.headers['x-csrf-token']!},
                body: body)
            .timeout(_timeout);
      }
      if (r.statusCode != 200) return null;
      final data = jsonDecode(r.body)['data'] as List;
      return data.isEmpty ? null : Map<String, dynamic>.from(data.first as Map);
    } catch (_) {
      return null;
    }
  }

  /// Описание, дата регистрации и т.д.
  Future<Map<String, dynamic>?> userInfo(int id) async {
    final d = await _getJson('https://users.roblox.com/v1/users/$id');
    return d is Map ? Map<String, dynamic>.from(d) : null;
  }

  /// kind: friends | followers | followings
  Future<int?> count(String kind, int id) async {
    final d = await _getJson('https://friends.roblox.com/v1/users/$id/$kind/count');
    return (d is Map && d['count'] is int) ? d['count'] as int : null;
  }

  Future<List<Map<String, dynamic>>> friends(int userId) async {
    final d = await _getJson('https://friends.roblox.com/v1/users/$userId/friends');
    if (d is Map && d['data'] is List) {
      return [for (final e in d['data'] as List) Map<String, dynamic>.from(e as Map)];
    }
    return [];
  }

  /// Аватар (скин) в полный рост
  Future<String?> avatarFull(int id) async {
    final d = await _getJson(
        'https://thumbnails.roblox.com/v1/users/avatar?userIds=$id&size=420x420&format=Png&isCircular=false');
    if (d is Map && d['data'] is List && (d['data'] as List).isNotEmpty) {
      final u = (d['data'] as List).first['imageUrl'];
      return u is String ? u : null;
    }
    return null;
  }

  /// Что надето на игроке (публичные данные)
  Future<List<Map<String, dynamic>>> wornAssets(int id) async {
    final d = await _getJson('https://avatar.roblox.com/v1/users/$id/avatar');
    if (d is Map && d['assets'] is List) {
      return [for (final a in d['assets'] as List) Map<String, dynamic>.from(a as Map)];
    }
    return [];
  }

  /// Миниатюры вещей по assetId
  Future<Map<int, String>> assetThumbs(List<int> ids) async {
    if (ids.isEmpty) return {};
    final d = await _getJson(
        'https://thumbnails.roblox.com/v1/assets?assetIds=${ids.take(50).join(",")}&size=150x150&format=Png&isCircular=false');
    final out = <int, String>{};
    if (d is Map && d['data'] is List) {
      for (final e in d['data'] as List) {
        if (e['imageUrl'] is String && e['targetId'] is int) {
          out[e['targetId'] as int] = e['imageUrl'] as String;
        }
      }
    }
    return out;
  }

  /// Аватарки-головы пользователей
  Future<Map<int, String>> avatars(List<int> ids) async {
    if (ids.isEmpty) return {};
    final d = await _getJson(
        'https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=${ids.join(",")}&size=150x150&format=Png');
    final out = <int, String>{};
    if (d is Map && d['data'] is List) {
      for (final e in d['data'] as List) {
        if (e['imageUrl'] is String && e['targetId'] is int) {
          out[e['targetId'] as int] = e['imageUrl'] as String;
        }
      }
    }
    return out;
  }

  /// Поиск игр
  Future<List<Map<String, dynamic>>> searchGames(String query) async {
    try {
      final r = await http
          .get(Uri.parse(
            'https://apis.roblox.com/search-api/omni-search'
            '?searchQuery=${Uri.encodeQueryComponent(query)}'
            '&sessionId=3f1c2b7e-9a41-4d6e-8c55-2b7f0e1a9d34&pageType=all',
          ))
          .timeout(_timeout);
      if (r.statusCode != 200) return [];
      final groups = (jsonDecode(utf8.decode(r.bodyBytes))['searchResults'] as List?) ?? [];
      final out = <Map<String, dynamic>>[];
      for (final g in groups) {
        if (g['contentGroupType'] != 'Game') continue;
        for (final c in (g['contents'] as List)) {
          if (c['rootPlaceId'] == null) continue;
          out.add({
            'name': c['name'],
            'playerCount': c['playerCount'] ?? 0,
            'placeId': c['rootPlaceId'],
            'universeId': c['universeId'],
          });
        }
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  /// Иконки игр по universeId
  Future<Map<int, String>> gameIcons(List<int> universeIds) async {
    if (universeIds.isEmpty) return {};
    final d = await _getJson(
        'https://thumbnails.roblox.com/v1/games/icons?universeIds=${universeIds.take(50).join(",")}&size=256x256&format=Png&isCircular=false');
    final out = <int, String>{};
    if (d is Map && d['data'] is List) {
      for (final e in d['data'] as List) {
        if (e['imageUrl'] is String && e['targetId'] is int) {
          out[e['targetId'] as int] = e['imageUrl'] as String;
        }
      }
    }
    return out;
  }

  /// Каталог вещей (шапки, волосы, одежда и т.д.)
  Future<List<Map<String, dynamic>>> searchCatalog(String keyword) async {
    final d = await _getJson(
        'https://catalog.roblox.com/v1/search/items/details?Keyword=${Uri.encodeQueryComponent(keyword)}&Limit=30');
    if (d is Map && d['data'] is List) {
      return [
        for (final e in d['data'] as List)
          if (e is Map && e['id'] is int) Map<String, dynamic>.from(e)
      ];
    }
    return [];
  }

  /// Приблизительный пинг до серверов Roblox (время HTTP-запроса, мс)
  Future<List<int>> ping({int n = 5}) async {
    final out = <int>[];
    for (var i = 0; i < n; i++) {
      final sw = Stopwatch()..start();
      try {
        await http
            .get(Uri.parse('https://users.roblox.com/v1/users/1'))
            .timeout(const Duration(seconds: 6));
        sw.stop();
        out.add(sw.elapsedMilliseconds);
      } catch (_) {}
    }
    return out;
  }
}
