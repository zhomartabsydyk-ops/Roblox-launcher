import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'roblox_api.dart';

final api = RobloxApi();

// ============================================================
// Настройки внешнего вида (сохраняются на телефоне)
// ============================================================
class AppSettings extends ChangeNotifier {
  static const accents = <Color>[
    Color(0xFF7C4DFF),
    Color(0xFF2979FF),
    Color(0xFF00BFA5),
    Color(0xFFFF4081),
    Color(0xFFFF9100),
    Color(0xFF76FF03),
    Color(0xFFFF5252),
    Color(0xFF00E5FF),
  ];
  int accent = 0;
  bool amoled = true;
  bool compact = false;
  double radius = 16;

  Color get color => accents[accent];

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    accent = (p.getInt('accent') ?? 0).clamp(0, accents.length - 1).toInt();
    amoled = p.getBool('amoled') ?? true;
    compact = p.getBool('compact') ?? false;
    radius = p.getDouble('radius') ?? 16;
  }

  void changed() => notifyListeners();

  Future<void> save() async {
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt('accent', accent);
    await p.setBool('amoled', amoled);
    await p.setBool('compact', compact);
    await p.setDouble('radius', radius);
  }
}

final settings = AppSettings();

// ============================================================
// Избранные игры
// ============================================================
class Favorites {
  static final items = ValueNotifier<Map<int, String>>({});

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final m = <int, String>{};
    for (final s in p.getStringList('fav') ?? <String>[]) {
      final i = s.indexOf('|');
      if (i < 0) continue;
      final id = int.tryParse(s.substring(0, i));
      if (id != null) m[id] = s.substring(i + 1);
    }
    items.value = m;
  }

  static Future<void> toggle(int id, String name) async {
    final m = Map<int, String>.from(items.value);
    if (m.containsKey(id)) {
      m.remove(id);
    } else {
      m[id] = name;
    }
    items.value = m;
    final p = await SharedPreferences.getInstance();
    await p.setStringList('fav', [for (final e in m.entries) '${e.key}|${e.value}']);
  }
}

// ============================================================
// Вспомогательные функции
// ============================================================
Future<void> openUrl(String url) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

/// Запуск игры в ОФИЦИАЛЬНОМ приложении Roblox через deep link.
Future<void> launchGame(BuildContext ctx, int placeId) async {
  final uri = Uri.parse('roblox://placeId=$placeId');
  bool ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok && ctx.mounted) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(content: Text('Установи официальное приложение Roblox')),
    );
  }
}

int? parsePlaceId(String s) {
  final m = RegExp(r'games/(\d+)').firstMatch(s) ?? RegExp(r'(\d{5,})').firstMatch(s);
  return m == null ? null : int.tryParse(m.group(1)!);
}

class NetImg extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  const NetImg(this.url, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: Colors.white10,
      child: Center(child: Icon(Icons.image_outlined)),
    );
    if (url == null) return placeholder;
    return Image.network(
      url!,
      fit: fit,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
}

// ============================================================
// Приложение
// ============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.load();
  await Favorites.load();
  runApp(const LauncherApp());
}

class LauncherApp extends StatelessWidget {
  const LauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final scheme = ColorScheme.fromSeed(
          seedColor: settings.color,
          brightness: Brightness.dark,
        );
        return MaterialApp(
          title: 'RBX Launcher',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: scheme,
            scaffoldBackgroundColor: settings.amoled ? Colors.black : scheme.surface,
          ),
          home: const Shell(),
        );
      },
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final pages = <Widget>[
          HomePage(),
          GamesPage(),
          ProfilePage(),
          CatalogPage(),
          StylePage(),
        ];
        return Scaffold(
          body: SafeArea(child: IndexedStack(index: tab, children: pages)),
          bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) => setState(() => tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Главная'),
              NavigationDestination(icon: Icon(Icons.sports_esports_outlined), selectedIcon: Icon(Icons.sports_esports), label: 'Игры'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Профиль'),
              NavigationDestination(icon: Icon(Icons.checkroom_outlined), selectedIcon: Icon(Icons.checkroom), label: 'Каталог'),
              NavigationDestination(icon: Icon(Icons.palette_outlined), selectedIcon: Icon(Icons.palette), label: 'Стиль'),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// Карточка игры
// ============================================================
class GameCard extends StatelessWidget {
  final Map<String, dynamic> g;
  final String? icon;
  const GameCard({super.key, required this.g, this.icon});

  @override
  Widget build(BuildContext context) {
    final placeId = g['placeId'] as int;
    final name = (g['name'] ?? '').toString();
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(settings.radius)),
      child: InkWell(
        onTap: () => launchGame(context, placeId),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SizedBox(width: double.infinity, child: NetImg(icon))),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('👥 ${g['playerCount'] ?? 0}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<Map<int, String>>(
                    valueListenable: Favorites.items,
                    builder: (_, favs, __) => IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(favs.containsKey(placeId) ? Icons.star : Icons.star_border),
                      onPressed: () => Favorites.toggle(placeId, name),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Главная
// ============================================================
class HomePage extends StatefulWidget {
  HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final link = TextEditingController();
  List<Map<String, dynamic>> games = [];
  Map<int, String> icons = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final r = await api.searchGames('popular');
    final ids = [for (final g in r) if (g['universeId'] is int) g['universeId'] as int];
    final ic = await api.gameIcons(ids);
    if (!mounted) return;
    setState(() {
      games = r.take(12).toList();
      icons = ic;
      loading = false;
    });
  }

  void go() {
    final id = parsePlaceId(link.text);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не нашёл ID игры. Вставь ссылку или число')),
      );
      return;
    }
    launchGame(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final c = settings.color;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          height: 140,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(settings.radius),
            gradient: LinearGradient(
              colors: [c, c.withOpacity(0.3), Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RBX Launcher',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Text('Ищи игры, смотри профили, запускай в один тап'),
            ],
          ),
        ),
        const SectionTitle('Играть по ссылке или ID'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: link,
                onSubmitted: (_) => go(),
                decoration: InputDecoration(
                  hintText: 'roblox.com/games/... или ID',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(settings.radius),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: go, child: const Text('Играть')),
          ],
        ),
        ValueListenableBuilder<Map<int, String>>(
          valueListenable: Favorites.items,
          builder: (_, favs, __) {
            if (favs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Избранное'),
                for (final e in favs.entries)
                  Card(
                    child: ListTile(
                      title: Text(e.value),
                      trailing: FilledButton(
                        onPressed: () => launchGame(context, e.key),
                        child: const Text('Играть'),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SectionTitle('Популярное'),
        if (loading) const LinearProgressIndicator(),
        if (!loading && games.isEmpty) const Text('Не удалось загрузить игры'),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: games.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => SizedBox(
              width: 160,
              child: GameCard(g: games[i], icon: icons[games[i]['universeId']]),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Игры (поиск)
// ============================================================
class GamesPage extends StatefulWidget {
  GamesPage({super.key});
  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final ctrl = TextEditingController(text: 'obby');
  static const tags = ['obby', 'simulator', 'tycoon', 'horror', 'anime', 'rpg', 'shooter', 'racing'];
  List<Map<String, dynamic>> games = [];
  Map<int, String> icons = {};
  bool loading = false;

  @override
  void initState() {
    super.initState();
    search();
  }

  Future<void> search([String? q]) async {
    if (q != null) ctrl.text = q;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => loading = true);
    final r = await api.searchGames(ctrl.text.trim());
    final ids = [for (final g in r) if (g['universeId'] is int) g['universeId'] as int];
    final ic = await api.gameIcons(ids);
    if (!mounted) return;
    setState(() {
      games = r;
      icons = ic;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: ctrl,
            onSubmitted: (_) => search(),
            decoration: InputDecoration(
              hintText: 'Поиск игр',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(settings.radius),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              for (final t in tags)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: ActionChip(label: Text(t), onPressed: () => search(t)),
                ),
            ],
          ),
        ),
        if (loading) const LinearProgressIndicator(),
        if (!loading && games.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Ничего не найдено или нет связи'),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: settings.compact ? 150 : 210,
              childAspectRatio: 0.85,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: games.length,
            itemBuilder: (_, i) =>
                GameCard(g: games[i], icon: icons[games[i]['universeId']]),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Профиль: ник -> скин, надетое, друзья
// ============================================================
class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ctrl = TextEditingController();
  bool loading = false;
  String? error;
  Map<String, dynamic>? user;
  Map<String, dynamic>? info;
  String? avatar;
  int? friendsCount, followersCount, followingCount;
  List<Map<String, dynamic>> worn = [];
  Map<int, String> wornPics = {};
  List<Map<String, dynamic>> friends = [];
  Map<int, String> friendPics = {};

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      final nick = p.getString('nick');
      if (nick != null && nick.isNotEmpty && mounted) {
        ctrl.text = nick;
      }
    });
  }

  Future<void> load() async {
    final nick = ctrl.text.trim();
    if (nick.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      loading = true;
      error = null;
      user = null;
    });
    final u = await api.findUser(nick);
    if (u == null) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Игрок не найден или нет связи';
      });
      return;
    }
    final id = u['id'] as int;
    final res = await Future.wait<Object?>([
      api.userInfo(id),
      api.avatarFull(id),
      api.count('friends', id),
      api.count('followers', id),
      api.count('followings', id),
      api.wornAssets(id),
      api.friends(id),
    ]);
    final w = res[5] as List<Map<String, dynamic>>;
    final f = res[6] as List<Map<String, dynamic>>;
    final wp = await api.assetThumbs([for (final a in w) a['id'] as int]);
    final fp = await api.avatars([for (final e in f.take(30)) e['id'] as int]);
    final p = await SharedPreferences.getInstance();
    await p.setString('nick', nick);
    if (!mounted) return;
    setState(() {
      user = u;
      info = res[0] as Map<String, dynamic>?;
      avatar = res[1] as String?;
      friendsCount = res[2] as int?;
      followersCount = res[3] as int?;
      followingCount = res[4] as int?;
      worn = w;
      wornPics = wp;
      friends = f;
      friendPics = fp;
      loading = false;
    });
  }

  Widget stat(String label, int? v) => Expanded(
        child: Column(
          children: [
            Text(v?.toString() ?? '—',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final u = user;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        TextField(
          controller: ctrl,
          onSubmitted: (_) => load(),
          decoration: InputDecoration(
            hintText: 'Ник игрока Roblox',
            prefixIcon: const Icon(Icons.person_search),
            suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: load),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(settings.radius),
            ),
          ),
        ),
        if (loading) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
        if (error != null) Padding(padding: const EdgeInsets.all(16), child: Text(error!)),
        if (u != null) ...[
          const SizedBox(height: 12),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(settings.radius),
              child: SizedBox(width: 240, height: 240, child: NetImg(avatar, fit: BoxFit.contain)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              (u['displayName'] ?? u['name'] ?? '').toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Center(child: Text('@${u['name'] ?? ''}')),
          if (info != null && (info!['created'] ?? '').toString().length >= 10)
            Center(
              child: Text(
                'В Roblox с ${info!['created'].toString().substring(0, 10)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              stat('Друзья', friendsCount),
              stat('Подписчики', followersCount),
              stat('Подписки', followingCount),
            ],
          ),
          if (info != null && (info!['description'] ?? '').toString().trim().isNotEmpty) ...[
            const SectionTitle('О себе'),
            Text(info!['description'].toString(), maxLines: 6, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => openUrl('https://www.roblox.com/users/${u['id']}/profile'),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Открыть профиль на roblox.com'),
          ),
          if (worn.isNotEmpty) ...[
            const SectionTitle('Надето сейчас'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in worn)
                  InkWell(
                    onTap: () => openUrl('https://www.roblox.com/catalog/${a['id']}'),
                    child: SizedBox(
                      width: 92,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(width: 92, height: 92, child: NetImg(wornPics[a['id']])),
                          ),
                          Text((a['name'] ?? '').toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (friends.isNotEmpty) ...[
            const SectionTitle('Друзья'),
            for (final f in friends.take(30))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundImage: friendPics[f['id']] != null
                      ? NetworkImage(friendPics[f['id']]!)
                      : null,
                ),
                title: Text((f['displayName'] ?? f['name'] ?? '').toString()),
                subtitle: Text('@${f['name'] ?? ''}'),
                onTap: () {
                  ctrl.text = (f['name'] ?? '').toString();
                  load();
                },
              ),
          ],
        ],
      ],
    );
  }
}

// ============================================================
// Каталог вещей
// ============================================================
class CatalogPage extends StatefulWidget {
  CatalogPage({super.key});
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ctrl = TextEditingController(text: 'hat');
  static const tags = ['hat', 'hair', 'face', 'shirt', 'pants', 'wings', 'bundle', 'accessory'];
  List<Map<String, dynamic>> items = [];
  Map<int, String> pics = {};
  bool loading = false;

  @override
  void initState() {
    super.initState();
    search();
  }

  String priceText(Map<String, dynamic> i) {
    final p = i['price'];
    if ('${i['priceStatus']}' == 'Off Sale') return 'Не продаётся';
    if (p == null) return '—';
    if (p == 0) return 'Бесплатно';
    return 'R\$ $p';
  }

  Future<void> search([String? q]) async {
    if (q != null) ctrl.text = q;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => loading = true);
    final r = await api.searchCatalog(ctrl.text.trim());
    final th = await api.assetThumbs([for (final i in r) i['id'] as int]);
    if (!mounted) return;
    setState(() {
      items = r;
      pics = th;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: ctrl,
            onSubmitted: (_) => search(),
            decoration: InputDecoration(
              hintText: 'Поиск в каталоге',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(settings.radius),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              for (final t in tags)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: ActionChip(label: Text(t), onPressed: () => search(t)),
                ),
            ],
          ),
        ),
        if (loading) const LinearProgressIndicator(),
        if (!loading && items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Ничего не найдено или нет связи'),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: settings.compact ? 150 : 200,
              childAspectRatio: 0.78,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final it = items[i];
              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(settings.radius),
                ),
                child: InkWell(
                  onTap: () => openUrl('https://www.roblox.com/catalog/${it['id']}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: NetImg(pics[it['id']]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((it['name'] ?? '').toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(priceText(it),
                                style: TextStyle(color: settings.color)),
                            Text((it['creatorName'] ?? '').toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Стиль: оформление + диагностика сети
// ============================================================
class StylePage extends StatefulWidget {
  StylePage({super.key});
  @override
  State<StylePage> createState() => _StylePageState();
}

class _StylePageState extends State<StylePage> {
  bool testing = false;
  List<int>? pings;

  Future<void> runPing() async {
    setState(() {
      testing = true;
      pings = null;
    });
    final r = await api.ping();
    if (!mounted) return;
    setState(() {
      pings = r;
      testing = false;
    });
  }

  String pingSummary() {
    final p = pings;
    if (p == null) return '';
    if (p.isEmpty) return 'Нет ответа от Roblox. Проверь интернет.';
    final min = p.reduce((a, b) => a < b ? a : b);
    final max = p.reduce((a, b) => a > b ? a : b);
    final avg = (p.reduce((a, b) => a + b) / p.length).round();
    final verdict = avg < 120 ? 'отлично' : (avg < 250 ? 'нормально' : 'высокий');
    return 'Мин $min мс · Средний $avg мс · Макс $max мс ($verdict)';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const SectionTitle('Акцентный цвет'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < AppSettings.accents.length; i++)
              GestureDetector(
                onTap: () {
                  settings.accent = i;
                  settings.save();
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppSettings.accents[i],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: settings.accent == i ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SectionTitle('Внешний вид'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Чёрный AMOLED-фон'),
                value: settings.amoled,
                onChanged: (v) {
                  settings.amoled = v;
                  settings.save();
                },
              ),
              SwitchListTile(
                title: const Text('Компактные карточки'),
                subtitle: const Text('Больше карточек на экране'),
                value: settings.compact,
                onChanged: (v) {
                  settings.compact = v;
                  settings.save();
                },
              ),
              ListTile(
                title: Text('Скругление: ${settings.radius.round()}'),
                subtitle: Slider(
                  value: settings.radius,
                  min: 4,
                  max: 32,
                  onChanged: (v) {
                    settings.radius = v;
                    settings.changed();
                  },
                  onChangeEnd: (_) => settings.save(),
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Проверка пинга до Roblox'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton.icon(
                  onPressed: testing ? null : runPing,
                  icon: const Icon(Icons.network_ping),
                  label: Text(testing ? 'Проверяю…' : 'Проверить пинг'),
                ),
                if (pings != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(pingSummary()),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Это время запроса к серверам Roblox с твоего телефона. '
                  'Пинг внутри игры обычно немного ниже.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SectionTitle('FPS и пинг прямо в игре'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'Лаунчер не может рисовать счётчики поверх Roblox: для этого пришлось бы '
              'вмешиваться в сам клиент, а это против правил. Зато в игре открой меню Roblox → '
              'Настройки и поищи пункт Performance Stats: он показывает FPS и пинг. '
              'Если его нет в твоей версии, придётся обойтись проверкой пинга выше.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
