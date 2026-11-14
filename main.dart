import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'roblox_api.dart';

void main() => runApp(const LauncherApp());

class LauncherApp extends StatelessWidget {
  const LauncherApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'RBX Launcher',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
        ),
        home: const Home(),
      );
}

/// Запуск игры в ОФИЦИАЛЬНОМ приложении Roblox через deep link.
Future<void> launchGame(BuildContext ctx, int placeId) async {
  final uri = Uri.parse('roblox://placeId=$placeId');
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && ctx.mounted) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(content: Text('Установи официальное приложение Roblox')),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [const GamesPage(), const FriendsPage(), const FavoritesPage()];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sports_esports), label: 'Игры'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Друзья'),
          NavigationDestination(icon: Icon(Icons.star), label: 'Избранное'),
        ],
      ),
    );
  }
}

// ---------- Избранное (хранится локально) ----------
class Favorites {
  static Future<Map<String, String>> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList('fav') ?? [];
    return {for (final s in raw) s.split('|').first: s.split('|').last};
  }

  static Future<void> toggle(int placeId, String name) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList('fav') ?? [];
    final key = '$placeId|$name';
    list.any((e) => e.startsWith('$placeId|')) ? list.removeWhere((e) => e.startsWith('$placeId|')) : list.add(key);
    await p.setStringList('fav', list);
  }
}

// ---------- Игры ----------
class GamesPage extends StatefulWidget {
  const GamesPage({super.key});
  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final api = RobloxApi();
  final ctrl = TextEditingController(text: 'obby');
  List<Map<String, dynamic>> games = [];
  bool loading = false;

  Future<void> search() async {
    setState(() => loading = true);
    final r = await api.searchGames(ctrl.text.trim());
    if (mounted) setState(() { games = r; loading = false; });
  }

  @override
  void initState() { super.initState(); search(); }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: ctrl,
            onSubmitted: (_) => search(),
            decoration: const InputDecoration(
              hintText: 'Поиск игр', prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (loading) const LinearProgressIndicator(),
        Expanded(
          child: ListView.builder(
            itemCount: games.length,
            itemBuilder: (_, i) {
              final g = games[i];
              final placeId = g['placeId'] as int;
              return ListTile(
                title: Text(g['name'] ?? ''),
                subtitle: Text('Онлайн: ${g['playerCount'] ?? 0}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.star_border),
                    onPressed: () => Favorites.toggle(placeId, g['name'] ?? ''),
                  ),
                  FilledButton(
                    onPressed: () => launchGame(context, placeId),
                    child: const Text('Играть'),
                  ),
                ]),
              );
            },
          ),
        ),
      ]);
}

// ---------- Друзья (публичный список по нику) ----------
class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final api = RobloxApi();
  final ctrl = TextEditingController();
  List<Map<String, dynamic>> friends = [];
  Map<int, String> pics = {};
  String? error;

  Future<void> load() async {
    setState(() { error = null; friends = []; });
    final u = await api.findUser(ctrl.text.trim());
    if (u == null) { setState(() => error = 'Пользователь не найден'); return; }
    final f = await api.friends(u['id'] as int);
    final p = await api.avatars(f.take(50).map((e) => e['id'] as int).toList());
    if (mounted) setState(() { friends = f; pics = p; });
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: ctrl,
            onSubmitted: (_) => load(),
            decoration: const InputDecoration(
              hintText: 'Ник игрока', prefixIcon: Icon(Icons.person_search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (error != null) Text(error!),
        Expanded(
          child: ListView.builder(
            itemCount: friends.length,
            itemBuilder: (_, i) {
              final f = friends[i];
              final pic = pics[f['id']];
              return ListTile(
                leading: CircleAvatar(backgroundImage: pic != null ? NetworkImage(pic) : null),
                title: Text(f['displayName'] ?? f['name'] ?? ''),
                subtitle: Text('@${f['name'] ?? ''}'),
              );
            },
          ),
        ),
      ]);
}

// ---------- Избранное ----------
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<Map<String, String>> fut = Favorites.load();
  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: fut,
        builder: (_, snap) {
          final m = snap.data ?? {};
          if (m.isEmpty) return const Center(child: Text('Пока пусто. Нажми ★ у игры'));
          return ListView(children: [
            for (final e in m.entries)
              ListTile(
                title: Text(e.value),
                trailing: FilledButton(
                  onPressed: () => launchGame(context, int.parse(e.key)),
                  child: const Text('Играть'),
                ),
              ),
          ]);
        },
      );
}
