import 'dart:async';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'roblox_api.dart';

final api = RobloxApi();

const kTabs = 6;
final activeTab = ValueNotifier<int>(0);
final searchTick = ValueNotifier<int>(0);
final myNick = ValueNotifier<String>('');
final cursorPos = ValueNotifier<Offset?>(null);

// ============================================================
// Языки
// ============================================================
class L10n {
  static const langs = <String, String>{
    'ru': 'Русский',
    'en': 'English',
    'kk': 'Қазақша',
  };

  static const table = <String, Map<String, String>>{
    'ru': {
      'nav_home': 'Главная',
      'nav_games': 'Игры',
      'nav_profile': 'Профиль',
      'nav_catalog': 'Каталог',
      'nav_tools': 'Инструменты',
      'nav_settings': 'Настройки',
      'welcome': 'Добро пожаловать, астронавт 🚀',
      'welcome_back': 'С возвращением, {n} 🚀',
      'tagline': 'Ищи игры, смотри профили, запускай в один тап',
      'play_by_link': 'Играть по ссылке или ID',
      'link_hint': 'roblox.com/games/... или ID',
      'play': 'Играть',
      'id_not_found': 'Не нашёл ID игры. Вставь ссылку или число',
      'favorites': 'Избранное',
      'recent': 'Недавние',
      'clear': 'Очистить',
      'popular': 'Популярное',
      'load_failed': 'Не удалось загрузить игры',
      'retry': 'Повторить',
      'install_roblox': 'Установи официальное приложение Roblox',
      'link_copied': 'Ссылка скопирована',
      'friends_n': 'Друзья ({n})',
      'friends_hint': 'Введи свой ник во вкладке «Профиль», и друзья появятся здесь.',
      'search_games': 'Поиск игр',
      'nothing_found': 'Ничего не найдено или нет связи',
      'sort_players': 'По онлайну',
      'random_game': 'Случайная игра',
      'copy_hint': 'Скопировать ссылку: долгое нажатие или правая кнопка мыши по игре',
      'nick_hint': 'Ник игрока Roblox',
      'player_not_found': 'Игрок не найден или нет связи',
      'since': 'В Roblox с {d}',
      'friends': 'Друзья',
      'followers': 'Подписчики',
      'following': 'Подписки',
      'about': 'О себе',
      'open_profile': 'Открыть профиль на roblox.com',
      'worn': 'Надето сейчас',
      'copy_id': 'Копировать ID',
      'id_copied': 'ID скопирован',
      'set_me': 'Это я',
      'me_saved': 'Сохранено как твой ник',
      'search_catalog': 'Поиск в каталоге',
      'off_sale': 'Не продаётся',
      'free': 'Бесплатно',
      'input_test': 'Тест клавиатуры и мыши',
      'input_hint': 'Нажимай клавиши и кнопки мыши, они подсветятся. CPS показывает клики в секунду.',
      'click_here': 'Кликай здесь, чтобы проверить CPS',
      'cps': 'CPS',
      'max_cps': 'Макс. CPS',
      'clicks_total': 'Всего кликов (Л / П)',
      'keys_pressed': 'Нажато',
      'scroll': 'Прокрутка',
      'pointer_pos': 'Позиция курсора',
      'reset': 'Сбросить',
      'hud_title': 'HUD с клавишами и CPS',
      'hud_sub': 'Маленькая панель поверх лаунчера (внутри самой игры Roblox она работать не может)',
      'ping_title': 'Проверка пинга до Roblox',
      'check_ping': 'Проверить пинг',
      'checking': 'Проверяю…',
      'ping_none': 'Нет ответа от Roblox. Проверь интернет.',
      'ping_summary': 'Мин {a} мс · Средний {b} мс · Макс {c} мс ({v})',
      'ping_good': 'отлично',
      'ping_ok': 'нормально',
      'ping_high': 'высокий',
      'ping_note': 'Это время запроса к серверам Roblox с твоего устройства. Пинг внутри игры обычно немного ниже.',
      'ingame_title': 'FPS и пинг прямо в игре',
      'ingame_text': 'Лаунчер не может рисовать счётчики поверх Roblox: для этого пришлось бы вмешиваться в сам клиент, а это против правил. Зато в игре открой меню Roblox → Настройки и поищи пункт Performance Stats: он показывает FPS и пинг. Если его нет в твоей версии, придётся обойтись проверкой пинга выше.',
      'language': 'Язык',
      'appearance': 'Внешний вид',
      'accent': 'Акцентный цвет',
      'amoled': 'Чёрный AMOLED-фон',
      'compact': 'Компактные карточки',
      'compact_sub': 'Больше карточек на экране',
      'radius': 'Скругление',
      'font_size': 'Размер текста',
      'stars': 'Звёзды на фоне',
      'start_tab': 'Стартовая вкладка',
      'cursor': 'Курсор мыши',
      'cursor_style': 'Стиль курсора',
      'cs_system': 'Системный',
      'cs_hand': 'Рука',
      'cs_cross': 'Прицел',
      'cs_ring': 'Кольцо',
      'cs_dot': 'Точка',
      'cs_plus': 'Крест',
      'cs_arrow': 'Стрелка',
      'cursor_size': 'Размер',
      'cursor_thick': 'Толщина',
      'cursor_color': 'Цвет курсора',
      'cursor_ripple': 'Волна при клике',
      'cursor_hide': 'Скрывать системный курсор',
      'cursor_test': 'Води мышью здесь, чтобы проверить курсор',
      'cursor_note': 'Работает с подключённой мышью. Курсор рисуется только внутри лаунчера, поверх Roblox он работать не может.',
      'shortcuts': 'Горячие клавиши',
      'sc_tabs': '1–6 — переключить вкладку',
      'sc_prev': '[ и ] — предыдущая и следующая вкладка',
      'sc_search': '/ или Ctrl+K — перейти в поиск',
      'sc_esc': 'Esc — выйти из поля ввода',
      'data': 'Данные',
      'clear_fav': 'Очистить избранное',
      'clear_hist': 'Очистить недавние',
      'forget_nick': 'Забыть мой ник',
      'reset_all': 'Сбросить настройки',
      'done': 'Готово',
      'about_title': 'О приложении',
      'about_text': 'RBX Launcher — неофициальный лаунчер-обёртка. Игры запускаются в официальном приложении Roblox. Вход в аккаунт не используется, пароли и cookie не нужны.',
    },
    'en': {
      'nav_home': 'Home',
      'nav_games': 'Games',
      'nav_profile': 'Profile',
      'nav_catalog': 'Catalog',
      'nav_tools': 'Tools',
      'nav_settings': 'Settings',
      'welcome': 'Welcome, astronaut 🚀',
      'welcome_back': 'Welcome back, {n} 🚀',
      'tagline': 'Find games, view profiles, launch in one tap',
      'play_by_link': 'Play by link or ID',
      'link_hint': 'roblox.com/games/... or ID',
      'play': 'Play',
      'id_not_found': "Couldn't find a game ID. Paste a link or a number",
      'favorites': 'Favorites',
      'recent': 'Recent',
      'clear': 'Clear',
      'popular': 'Popular',
      'load_failed': "Couldn't load games",
      'retry': 'Retry',
      'install_roblox': 'Install the official Roblox app',
      'link_copied': 'Link copied',
      'friends_n': 'Friends ({n})',
      'friends_hint': 'Enter your username in the Profile tab and your friends will appear here.',
      'search_games': 'Search games',
      'nothing_found': 'Nothing found or no connection',
      'sort_players': 'By players',
      'random_game': 'Random game',
      'copy_hint': 'Copy link: long-press or right-click a game',
      'nick_hint': 'Roblox username',
      'player_not_found': 'Player not found or no connection',
      'since': 'On Roblox since {d}',
      'friends': 'Friends',
      'followers': 'Followers',
      'following': 'Following',
      'about': 'About',
      'open_profile': 'Open profile on roblox.com',
      'worn': 'Currently wearing',
      'copy_id': 'Copy ID',
      'id_copied': 'ID copied',
      'set_me': 'This is me',
      'me_saved': 'Saved as your username',
      'search_catalog': 'Search catalog',
      'off_sale': 'Off sale',
      'free': 'Free',
      'input_test': 'Keyboard and mouse test',
      'input_hint': 'Press keys and mouse buttons to see them light up. CPS shows clicks per second.',
      'click_here': 'Click here to test CPS',
      'cps': 'CPS',
      'max_cps': 'Max CPS',
      'clicks_total': 'Total clicks (L / R)',
      'keys_pressed': 'Pressed',
      'scroll': 'Scroll',
      'pointer_pos': 'Pointer position',
      'reset': 'Reset',
      'hud_title': 'Keys and CPS HUD',
      'hud_sub': 'A small overlay inside the launcher (it cannot work inside the Roblox game itself)',
      'ping_title': 'Ping check to Roblox',
      'check_ping': 'Check ping',
      'checking': 'Checking…',
      'ping_none': 'No response from Roblox. Check your connection.',
      'ping_summary': 'Min {a} ms · Avg {b} ms · Max {c} ms ({v})',
      'ping_good': 'great',
      'ping_ok': 'okay',
      'ping_high': 'high',
      'ping_note': 'This is the request time to Roblox servers from your device. In-game ping is usually a bit lower.',
      'ingame_title': 'FPS and ping inside the game',
      'ingame_text': 'The launcher cannot draw counters on top of Roblox: that would mean tampering with the client itself, which is against the rules. Instead, open the Roblox menu → Settings in-game and look for Performance Stats: it shows FPS and ping. If your version does not have it, use the ping check above.',
      'language': 'Language',
      'appearance': 'Appearance',
      'accent': 'Accent color',
      'amoled': 'Black AMOLED background',
      'compact': 'Compact cards',
      'compact_sub': 'More cards on screen',
      'radius': 'Corner radius',
      'font_size': 'Text size',
      'stars': 'Background stars',
      'start_tab': 'Start tab',
      'cursor': 'Mouse cursor',
      'cursor_style': 'Cursor style',
      'cs_system': 'System',
      'cs_hand': 'Hand',
      'cs_cross': 'Crosshair',
      'cs_ring': 'Ring',
      'cs_dot': 'Dot',
      'cs_plus': 'Cross',
      'cs_arrow': 'Arrow',
      'cursor_size': 'Size',
      'cursor_thick': 'Thickness',
      'cursor_color': 'Cursor color',
      'cursor_ripple': 'Click ripple',
      'cursor_hide': 'Hide system cursor',
      'cursor_test': 'Move your mouse here to preview the cursor',
      'cursor_note': 'Works with a connected mouse. The cursor is drawn only inside the launcher, not over Roblox.',
      'shortcuts': 'Keyboard shortcuts',
      'sc_tabs': '1–6 — switch tab',
      'sc_prev': '[ and ] — previous and next tab',
      'sc_search': '/ or Ctrl+K — focus search',
      'sc_esc': 'Esc — leave the text field',
      'data': 'Data',
      'clear_fav': 'Clear favorites',
      'clear_hist': 'Clear recent games',
      'forget_nick': 'Forget my username',
      'reset_all': 'Reset settings',
      'done': 'Done',
      'about_title': 'About',
      'about_text': 'RBX Launcher is an unofficial launcher wrapper. Games open in the official Roblox app. No account login is used, no passwords or cookies are needed.',
    },
    'kk': {
      'nav_home': 'Басты бет',
      'nav_games': 'Ойындар',
      'nav_profile': 'Профиль',
      'nav_catalog': 'Каталог',
      'nav_tools': 'Құралдар',
      'nav_settings': 'Баптаулар',
      'welcome': 'Қош келдіңіз, астронавт 🚀',
      'welcome_back': 'Қайта қош келдіңіз, {n} 🚀',
      'tagline': 'Ойындарды тап, профильдерді қара, бір басумен іске қос',
      'play_by_link': 'Сілтеме немесе ID арқылы ойнау',
      'link_hint': 'roblox.com/games/... немесе ID',
      'play': 'Ойнау',
      'id_not_found': 'Ойын ID табылмады. Сілтеме немесе сан қойыңыз',
      'favorites': 'Таңдаулылар',
      'recent': 'Соңғы ойындар',
      'clear': 'Тазалау',
      'popular': 'Танымал',
      'load_failed': 'Ойындар жүктелмеді',
      'retry': 'Қайталау',
      'install_roblox': 'Roblox ресми қосымшасын орнатыңыз',
      'link_copied': 'Сілтеме көшірілді',
      'friends_n': 'Достар ({n})',
      'friends_hint': '«Профиль» қойындысына өз никіңізді енгізіңіз, достарыңыз осында көрінеді.',
      'search_games': 'Ойын іздеу',
      'nothing_found': 'Ештеңе табылмады немесе байланыс жоқ',
      'sort_players': 'Онлайн бойынша',
      'random_game': 'Кездейсоқ ойын',
      'copy_hint': 'Сілтемені көшіру: ойынды ұзақ басыңыз немесе тінтуірдің оң жақ батырмасын басыңыз',
      'nick_hint': 'Roblox никі',
      'player_not_found': 'Ойыншы табылмады немесе байланыс жоқ',
      'since': 'Roblox-та {d} бері',
      'friends': 'Достар',
      'followers': 'Жазылушылар',
      'following': 'Жазылымдар',
      'about': 'Өзі туралы',
      'open_profile': 'Профильді roblox.com сайтында ашу',
      'worn': 'Қазір киіп тұр',
      'copy_id': 'ID көшіру',
      'id_copied': 'ID көшірілді',
      'set_me': 'Бұл — мен',
      'me_saved': 'Никіңіз сақталды',
      'search_catalog': 'Каталогтан іздеу',
      'off_sale': 'Сатылмайды',
      'free': 'Тегін',
      'input_test': 'Пернетақта мен тінтуір тесті',
      'input_hint': 'Пернелер мен тінтуір батырмаларын басыңыз, олар жанады. CPS — секундына басу саны.',
      'click_here': 'CPS тексеру үшін осы жерді басыңыз',
      'cps': 'CPS',
      'max_cps': 'Макс. CPS',
      'clicks_total': 'Барлық басулар (С / О)',
      'keys_pressed': 'Басылған',
      'scroll': 'Айналдыру',
      'pointer_pos': 'Меңзер орны',
      'reset': 'Қалпына келтіру',
      'hud_title': 'Пернелер мен CPS HUD',
      'hud_sub': 'Лаунчер ішіндегі шағын панель (Roblox ойынының ішінде жұмыс істей алмайды)',
      'ping_title': 'Roblox-қа пинг тексеру',
      'check_ping': 'Пингті тексеру',
      'checking': 'Тексеруде…',
      'ping_none': 'Roblox жауап бермеді. Интернетті тексеріңіз.',
      'ping_summary': 'Мин {a} мс · Орташа {b} мс · Макс {c} мс ({v})',
      'ping_good': 'тамаша',
      'ping_ok': 'жаман емес',
      'ping_high': 'жоғары',
      'ping_note': 'Бұл құрылғыңыздан Roblox серверлеріне сұраныс уақыты. Ойын ішіндегі пинг әдетте сәл төмен болады.',
      'ingame_title': 'Ойын ішіндегі FPS және пинг',
      'ingame_text': 'Лаунчер Roblox үстіне есептегіштерді сала алмайды: ол үшін клиентке араласу керек, бұл ережеге қайшы. Оның орнына ойында Roblox мәзірі → Баптаулар ашып, Performance Stats тармағын іздеңіз: ол FPS пен пингті көрсетеді. Нұсқаңызда болмаса, жоғарыдағы пинг тексеруін қолданыңыз.',
      'language': 'Тіл',
      'appearance': 'Көрініс',
      'accent': 'Екпін түсі',
      'amoled': 'Қара AMOLED фон',
      'compact': 'Ықшам карталар',
      'compact_sub': 'Экранда көбірек карта',
      'radius': 'Бұрыштарды дөңгелектеу',
      'font_size': 'Мәтін өлшемі',
      'stars': 'Фондағы жұлдыздар',
      'start_tab': 'Бастапқы қойынды',
      'cursor': 'Тінтуір меңзері',
      'cursor_style': 'Меңзер стилі',
      'cs_system': 'Жүйелік',
      'cs_hand': 'Қол',
      'cs_cross': 'Көздеуіш',
      'cs_ring': 'Сақина',
      'cs_dot': 'Нүкте',
      'cs_plus': 'Крест',
      'cs_arrow': 'Көрсеткі',
      'cursor_size': 'Өлшем',
      'cursor_thick': 'Қалыңдық',
      'cursor_color': 'Меңзер түсі',
      'cursor_ripple': 'Басу толқыны',
      'cursor_hide': 'Жүйелік меңзерді жасыру',
      'cursor_test': 'Меңзерді тексеру үшін тінтуірді осында жүргізіңіз',
      'cursor_note': 'Тінтуір қосылғанда жұмыс істейді. Меңзер тек лаунчер ішінде салынады, Roblox үстінде жұмыс істемейді.',
      'shortcuts': 'Жылдам пернелер',
      'sc_tabs': '1–6 — қойындыны ауыстыру',
      'sc_prev': '[ және ] — алдыңғы және келесі қойынды',
      'sc_search': '/ немесе Ctrl+K — іздеуге өту',
      'sc_esc': 'Esc — енгізу жолынан шығу',
      'data': 'Деректер',
      'clear_fav': 'Таңдаулыларды тазалау',
      'clear_hist': 'Соңғыларды тазалау',
      'forget_nick': 'Никімді ұмыту',
      'reset_all': 'Баптауларды қалпына келтіру',
      'done': 'Дайын',
      'about_title': 'Қосымша туралы',
      'about_text': 'RBX Launcher — бейресми лаунчер. Ойындар Roblox ресми қосымшасында ашылады. Аккаунтқа кіру қолданылмайды, құпия сөз бен cookie қажет емес.',
    },
  };
}

/// Перевод строки по ключу. Если ключа нет, берём русский вариант.
String t(String key, [Map<String, Object>? args]) {
  var s = L10n.table[settings.lang]?[key] ?? L10n.table['ru']![key] ?? key;
  if (args != null) {
    args.forEach((k, v) {
      s = s.replaceAll('{' + k + '}', v.toString());
    });
  }
  return s;
}

List<String> navLabels() => [
      t('nav_home'),
      t('nav_games'),
      t('nav_profile'),
      t('nav_catalog'),
      t('nav_tools'),
      t('nav_settings'),
    ];

// ============================================================
// Настройки (сохраняются на устройстве)
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

  /// null = цвет акцента
  static const cursorColors = <Color?>[
    null,
    Colors.white,
    Color(0xFFFF5252),
    Color(0xFF76FF03),
    Color(0xFFFFEB3B),
    Color(0xFF00E5FF),
    Color(0xFFFF4081),
  ];

  String lang = 'ru';
  int accent = 0;
  bool amoled = true;
  bool compact = false;
  double radius = 16;
  double fontScale = 1.0;
  bool stars = true;
  int startTab = 0;

  /// 0 системный, 1 рука, 2 прицел (системные), 3 кольцо, 4 точка, 5 крест, 6 стрелка (рисуются)
  int cursorStyle = 0;
  double cursorSize = 28;
  double cursorThick = 2;
  int cursorColor = 1;
  bool cursorRipple = true;
  bool hideSystem = true;
  bool hud = false;

  Color get color => accents[accent];
  Color get cursorTint => cursorColors[cursorColor] ?? color;
  bool get drawnCursor => cursorStyle >= 3;

  /// Какой системный курсор подставлять. null = как обычно в Android.
  MouseCursor? get cursorOverride {
    switch (cursorStyle) {
      case 1:
        return SystemMouseCursors.click;
      case 2:
        return SystemMouseCursors.precise;
      case 3:
      case 4:
      case 5:
      case 6:
        return hideSystem ? SystemMouseCursors.none : null;
      default:
        return null;
    }
  }

  static double clampD(double v, double lo, double hi) =>
      v < lo ? lo : (v > hi ? hi : v);

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final sys = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    lang = p.getString('lang') ?? (L10n.langs.containsKey(sys) ? sys : 'ru');
    if (!L10n.langs.containsKey(lang)) lang = 'ru';
    accent = (p.getInt('accent') ?? 0).clamp(0, accents.length - 1).toInt();
    amoled = p.getBool('amoled') ?? true;
    compact = p.getBool('compact') ?? false;
    radius = p.getDouble('radius') ?? 16;
    fontScale = clampD(p.getDouble('fontScale') ?? 1.0, 0.8, 1.4);
    stars = p.getBool('stars') ?? true;
    startTab = (p.getInt('startTab') ?? 0).clamp(0, kTabs - 1).toInt();
    cursorStyle = (p.getInt('cursorStyle') ?? 0).clamp(0, 6).toInt();
    cursorSize = clampD(p.getDouble('cursorSize') ?? 28, 12, 64);
    cursorThick = clampD(p.getDouble('cursorThick') ?? 2, 1, 8);
    cursorColor =
        (p.getInt('cursorColor') ?? 1).clamp(0, cursorColors.length - 1).toInt();
    cursorRipple = p.getBool('cursorRipple') ?? true;
    hideSystem = p.getBool('hideSystem') ?? true;
    hud = p.getBool('hud') ?? false;
  }

  void changed() => notifyListeners();

  Future<void> save() async {
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('lang', lang);
    await p.setInt('accent', accent);
    await p.setBool('amoled', amoled);
    await p.setBool('compact', compact);
    await p.setDouble('radius', radius);
    await p.setDouble('fontScale', fontScale);
    await p.setBool('stars', stars);
    await p.setInt('startTab', startTab);
    await p.setInt('cursorStyle', cursorStyle);
    await p.setDouble('cursorSize', cursorSize);
    await p.setDouble('cursorThick', cursorThick);
    await p.setInt('cursorColor', cursorColor);
    await p.setBool('cursorRipple', cursorRipple);
    await p.setBool('hideSystem', hideSystem);
    await p.setBool('hud', hud);
  }

  Future<void> resetAll() async {
    accent = 0;
    amoled = true;
    compact = false;
    radius = 16;
    fontScale = 1.0;
    stars = true;
    startTab = 0;
    cursorStyle = 0;
    cursorSize = 28;
    cursorThick = 2;
    cursorColor = 1;
    cursorRipple = true;
    hideSystem = true;
    hud = false;
    await save();
  }
}

final settings = AppSettings();

// ============================================================
// Избранное и недавние игры
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

  static Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        'fav', [for (final e in items.value.entries) '${e.key}|${e.value}']);
  }

  static Future<void> toggle(int id, String name) async {
    final m = Map<int, String>.from(items.value);
    if (m.containsKey(id)) {
      m.remove(id);
    } else {
      m[id] = name;
    }
    items.value = m;
    await _save();
  }

  static Future<void> clear() async {
    items.value = {};
    await _save();
  }
}

class History {
  static final items = ValueNotifier<List<MapEntry<int, String>>>([]);

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final l = <MapEntry<int, String>>[];
    for (final s in p.getStringList('hist') ?? <String>[]) {
      final i = s.indexOf('|');
      if (i < 0) continue;
      final id = int.tryParse(s.substring(0, i));
      if (id != null) l.add(MapEntry(id, s.substring(i + 1)));
    }
    items.value = l;
  }

  static Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        'hist', [for (final e in items.value) '${e.key}|${e.value}']);
  }

  static Future<void> add(int id, String name) async {
    final l = items.value.where((e) => e.key != id).toList();
    l.insert(0, MapEntry(id, name));
    if (l.length > 12) l.removeRange(12, l.length);
    items.value = l;
    await _save();
  }

  static Future<void> clear() async {
    items.value = [];
    await _save();
  }
}

// ============================================================
// Состояние ввода (клавиши, мышь, CPS)
// ============================================================
class InputState extends ChangeNotifier {
  final Set<LogicalKeyboardKey> keys = {};
  final List<int> _left = [];
  final List<int> _right = [];
  int _prev = 0;
  bool left = false;
  bool right = false;
  bool middle = false;
  int totalLeft = 0;
  int totalRight = 0;
  int maxCps = 0;
  double scroll = 0;

  int _now() => DateTime.now().millisecondsSinceEpoch;

  void keyDown(LogicalKeyboardKey k) {
    if (keys.add(k)) notifyListeners();
  }

  void keyUp(LogicalKeyboardKey k) {
    if (keys.remove(k)) notifyListeners();
  }

  void setButtons(int b) {
    final newly = b & ~_prev;
    _prev = b;
    if (newly & kPrimaryButton != 0) _click(true);
    if (newly & kSecondaryButton != 0) _click(false);
    left = b & kPrimaryButton != 0;
    right = b & kSecondaryButton != 0;
    middle = b & kMiddleMouseButton != 0;
    notifyListeners();
  }

  void _click(bool isLeft) {
    final now = _now();
    final list = isLeft ? _left : _right;
    list.add(now);
    list.removeWhere((x) => now - x > 1000);
    if (isLeft) {
      totalLeft++;
      if (list.length > maxCps) maxCps = list.length;
    } else {
      totalRight++;
    }
  }

  int cps() {
    final now = _now();
    _left.removeWhere((x) => now - x > 1000);
    return _left.length;
  }

  void addScroll(double dy) {
    scroll += dy;
    notifyListeners();
  }

  void resetCounters() {
    _left.clear();
    _right.clear();
    totalLeft = 0;
    totalRight = 0;
    maxCps = 0;
    scroll = 0;
    notifyListeners();
  }
}

final input = InputState();

// ============================================================
// Вспомогательные функции
// ============================================================
Future<void> openUrl(String url) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

/// Запуск игры в ОФИЦИАЛЬНОМ приложении Roblox через deep link.
Future<void> launchGame(BuildContext ctx, int placeId, [String? name]) async {
  final uri = Uri.parse('roblox://placeId=$placeId');
  bool ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (ok) {
    History.add(placeId, name ?? 'ID $placeId');
  } else if (ctx.mounted) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(t('install_roblox'))),
    );
  }
}

Future<void> copyText(BuildContext ctx, String text, String doneKey) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (ctx.mounted) {
    ScaffoldMessenger.of(ctx)
        .showSnackBar(SnackBar(content: Text(t(doneKey))));
  }
}

int? parsePlaceId(String s) {
  final m =
      RegExp(r'games/(\d+)').firstMatch(s) ?? RegExp(r'(\d{5,})').firstMatch(s);
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

/// Нажимаемая область, которая учитывает выбранный курсор мыши.
class Tap extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  const Tap({super.key, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: settings.cursorOverride ?? SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: child,
        ),
      );
}

class Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;
  const Pill({
    super.key,
    required this.text,
    required this.onTap,
    this.selected = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = settings.color;
    return Material(
      color: selected ? c.withOpacity(0.28) : Colors.white12,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? c : Colors.white24),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        mouseCursor: settings.cursorOverride,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}

class SwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const SwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: settings.cursorOverride,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  if (subtitle != null)
                    Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            IgnorePointer(child: Switch(value: value, onChanged: (_) {})),
          ],
        ),
      ),
    );
  }
}

class KeyCap extends StatelessWidget {
  final String label;
  final bool active;
  final double w;
  final double h;
  const KeyCap(this.label, this.active, {super.key, this.w = 44, this.h = 44});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      width: w,
      height: h,
      margin: const EdgeInsets.all(2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? settings.color : Colors.white12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? Colors.white : Colors.white24),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: h * 0.36),
      ),
    );
  }
}

// ============================================================
// Фон, слой курсора, HUD
// ============================================================
class SpaceBackground extends StatelessWidget {
  const SpaceBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final top = Color.lerp(
            Colors.black, settings.color, settings.amoled ? 0.16 : 0.35)!;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, Colors.black],
            ),
          ),
          child: settings.stars
              ? CustomPaint(painter: _StarsPainter(), child: const SizedBox.expand())
              : const SizedBox.expand(),
        );
      },
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(7);
    final brush = Paint();
    for (var i = 0; i < 90; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final r = rnd.nextDouble() * 1.4 + 0.3;
      brush.color = Colors.white.withOpacity(rnd.nextDouble() * 0.6 + 0.2);
      canvas.drawCircle(Offset(x, y), r, brush);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CursorPainter extends CustomPainter {
  final int style;
  final double size;
  final Color color;
  final double thick;
  final bool pressed;
  _CursorPainter(this.style, this.size, this.color, this.thick, this.pressed);

  @override
  void paint(Canvas canvas, Size _) {
    final r = size / 2 * (pressed ? 0.8 : 1.0);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final edge = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thick + 2
      ..strokeCap = StrokeCap.round;
    const o = Offset.zero;

    switch (style) {
      case 3:
        canvas.drawCircle(o, r, edge);
        canvas.drawCircle(o, r, stroke);
        canvas.drawCircle(o, max(1.5, thick * 0.8), fill);
        break;
      case 4:
        canvas.drawCircle(o, r * 0.45 + 1, Paint()..color = Colors.black.withOpacity(0.6));
        canvas.drawCircle(o, r * 0.45, fill);
        break;
      case 5:
        final gap = r * 0.25;
        for (final d in const [Offset(1, 0), Offset(-1, 0), Offset(0, 1), Offset(0, -1)]) {
          final a = d * gap;
          final b = d * r;
          canvas.drawLine(a, b, edge);
        }
        for (final d in const [Offset(1, 0), Offset(-1, 0), Offset(0, 1), Offset(0, -1)]) {
          final a = d * gap;
          final b = d * r;
          canvas.drawLine(a, b, stroke);
        }
        break;
      case 6:
        final s = size * 0.85 * (pressed ? 0.9 : 1.0);
        final path = Path()
          ..moveTo(0, 0)
          ..lineTo(0, s)
          ..lineTo(s * 0.27, s * 0.74)
          ..lineTo(s * 0.46, s * 1.12)
          ..lineTo(s * 0.6, s * 1.05)
          ..lineTo(s * 0.42, s * 0.68)
          ..lineTo(s * 0.78, s * 0.66)
          ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.black.withOpacity(0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeJoin = StrokeJoin.round,
        );
        canvas.drawPath(path, fill);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Ripple {
  final int id;
  final Offset pos;
  _Ripple(this.id, this.pos);
}

/// Оборачивает всё приложение: рисует свой курсор, волны от кликов и HUD,
/// а также собирает события мыши для теста ввода.
class CursorLayer extends StatefulWidget {
  final Widget child;
  const CursorLayer({super.key, required this.child});

  @override
  State<CursorLayer> createState() => _CursorLayerState();
}

class _CursorLayerState extends State<CursorLayer> {
  final List<_Ripple> ripples = [];
  int _nextId = 0;

  void _move(PointerEvent e) {
    if (e.kind == PointerDeviceKind.mouse) {
      cursorPos.value = e.position;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MouseRegion(
          cursor: settings.cursorOverride ?? MouseCursor.defer,
          onExit: (_) => cursorPos.value = null,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerHover: _move,
            onPointerMove: _move,
            onPointerDown: (e) {
              _move(e);
              if (e.kind == PointerDeviceKind.mouse) {
                input.setButtons(e.buttons);
                if (settings.cursorRipple) {
                  setState(() => ripples.add(_Ripple(_nextId++, e.position)));
                }
              } else {
                input.setButtons(kPrimaryButton);
              }
            },
            onPointerUp: (e) {
              input.setButtons(e.kind == PointerDeviceKind.mouse ? e.buttons : 0);
            },
            onPointerCancel: (e) => input.setButtons(0),
            onPointerSignal: (e) {
              if (e is PointerScrollEvent) input.addScroll(e.scrollDelta.dy);
            },
            child: Stack(
              children: [
                Positioned.fill(child: widget.child),
                if (settings.hud)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: IgnorePointer(child: HudOverlay()),
                      ),
                    ),
                  ),
                for (final r in ripples)
                  Positioned(
                    left: r.pos.dx - 30,
                    top: r.pos.dy - 30,
                    child: IgnorePointer(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(r.id),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 420),
                        onEnd: () {
                          if (mounted) {
                            setState(() => ripples.removeWhere((x) => x.id == r.id));
                          }
                        },
                        builder: (_, v, __) => SizedBox(
                          width: 60,
                          height: 60,
                          child: Center(
                            child: Opacity(
                              opacity: 1 - v,
                              child: Container(
                                width: 14 + 46 * v,
                                height: 14 + 46 * v,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: settings.cursorTint,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (settings.drawnCursor)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ValueListenableBuilder<Offset?>(
                        valueListenable: cursorPos,
                        builder: (_, p, __) {
                          if (p == null) return const SizedBox.shrink();
                          return Stack(
                            children: [
                              Positioned(
                                left: p.dx,
                                top: p.dy,
                                child: CustomPaint(
                                  size: Size.zero,
                                  painter: _CursorPainter(
                                    settings.cursorStyle,
                                    settings.cursorSize,
                                    settings.cursorTint,
                                    settings.cursorThick,
                                    input.left,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HudOverlay extends StatefulWidget {
  HudOverlay({super.key});
  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _k(LogicalKeyboardKey k) => input.keys.contains(k);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: input,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KeyCap('W', _k(LogicalKeyboardKey.keyW), w: 30, h: 30),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KeyCap('A', _k(LogicalKeyboardKey.keyA), w: 30, h: 30),
                      KeyCap('S', _k(LogicalKeyboardKey.keyS), w: 30, h: 30),
                      KeyCap('D', _k(LogicalKeyboardKey.keyD), w: 30, h: 30),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KeyCap('L', input.left, w: 30, h: 30),
                      KeyCap('R', input.right, w: 30, h: 30),
                    ],
                  ),
                  Text('${input.cps()} CPS',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// Приложение
// ============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.load();
  await Favorites.load();
  await History.load();
  final prefs = await SharedPreferences.getInstance();
  myNick.value = prefs.getString('nick') ?? '';
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
        final cur = settings.cursorOverride;
        final ButtonStyle? bs = cur == null
            ? null
            : ButtonStyle(mouseCursor: WidgetStatePropertyAll<MouseCursor?>(cur));
        return MaterialApp(
          title: 'RBX Launcher',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: scheme.copyWith(
              surfaceContainerLow: const Color(0x26FFFFFF),
            ),
            scaffoldBackgroundColor: Colors.black,
            filledButtonTheme: FilledButtonThemeData(style: bs),
            outlinedButtonTheme: OutlinedButtonThemeData(style: bs),
            textButtonTheme: TextButtonThemeData(style: bs),
            iconButtonTheme: IconButtonThemeData(style: bs),
          ),
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final sys = mq.textScaler.scale(1.0);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: TextScaler.linear(settings.fontScale * sys),
              ),
              child: CursorLayer(child: child ?? const SizedBox.shrink()),
            );
          },
          home: const Shell(),
        );
      },
    );
  }
}

// ============================================================
// Каркас: навигация и горячие клавиши
// ============================================================
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const _digits = <LogicalKeyboardKey>[
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
  ];

  @override
  void initState() {
    super.initState();
    activeTab.value = settings.startTab.clamp(0, kTabs - 1).toInt();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _typing() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return false;
    return ctx.widget is EditableText ||
        ctx.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _onKey(KeyEvent e) {
    if (e is KeyUpEvent) {
      input.keyUp(e.logicalKey);
      return false;
    }
    if (e is! KeyDownEvent) return false;
    final k = e.logicalKey;
    input.keyDown(k);

    final hw = HardwareKeyboard.instance;
    final ctrl = hw.isControlPressed || hw.isMetaPressed;
    final typing = _typing();

    if (k == LogicalKeyboardKey.escape) {
      if (typing) {
        FocusManager.instance.primaryFocus?.unfocus();
        return true;
      }
      return false;
    }
    if ((ctrl && k == LogicalKeyboardKey.keyK) ||
        (!typing && !ctrl && k == LogicalKeyboardKey.slash)) {
      searchTick.value++;
      return true;
    }
    if (typing || ctrl) return false;

    final i = _digits.indexOf(k);
    if (i >= 0 && i < kTabs) {
      activeTab.value = i;
      return true;
    }
    if (k == LogicalKeyboardKey.bracketRight) {
      activeTab.value = (activeTab.value + 1) % kTabs;
      return true;
    }
    if (k == LogicalKeyboardKey.bracketLeft) {
      activeTab.value = (activeTab.value + kTabs - 1) % kTabs;
      return true;
    }
    return false;
  }

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
          ToolsPage(),
          SettingsPage(),
        ];
        const icons = [
          Icons.home_outlined,
          Icons.sports_esports_outlined,
          Icons.person_outline,
          Icons.checkroom_outlined,
          Icons.build_outlined,
          Icons.settings_outlined,
        ];
        const iconsOn = [
          Icons.home,
          Icons.sports_esports,
          Icons.person,
          Icons.checkroom,
          Icons.build,
          Icons.settings,
        ];
        final labels = navLabels();
        final wide = MediaQuery.of(context).size.width >= 700;

        return ValueListenableBuilder<int>(
          valueListenable: activeTab,
          builder: (context, tab, _) {
            final content = Stack(
              children: [
                const Positioned.fill(child: SpaceBackground()),
                Positioned.fill(
                  child: SafeArea(
                    child: Material(
                      type: MaterialType.transparency,
                      child: IndexedStack(index: tab, children: pages),
                    ),
                  ),
                ),
              ],
            );
            if (wide) {
              return Scaffold(
                body: Row(
                  children: [
                    Material(
                      color: Colors.black.withOpacity(0.55),
                      child: SafeArea(
                        child: SizedBox(
                          width: 92,
                          child: ListView(
                            padding: const EdgeInsets.only(top: 8),
                            children: [
                              for (var i = 0; i < kTabs; i++)
                                NavBtn(
                                  icon: tab == i ? iconsOn[i] : icons[i],
                                  label: labels[i],
                                  selected: tab == i,
                                  onTap: () => activeTab.value = i,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: content),
                  ],
                ),
              );
            }
            return Scaffold(
              body: content,
              bottomNavigationBar: Material(
                color: Colors.black.withOpacity(0.78),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      for (var i = 0; i < kTabs; i++)
                        Expanded(
                          child: NavBtn(
                            icon: tab == i ? iconsOn[i] : icons[i],
                            label: labels[i],
                            selected: tab == i,
                            onTap: () => activeTab.value = i,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const NavBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = selected ? settings.color : Colors.white70;
    return Tap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? settings.color.withOpacity(0.22) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: c, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                color: c,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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
    void copy() =>
        copyText(context, 'https://www.roblox.com/games/$placeId', 'link_copied');
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(settings.radius)),
      child: InkWell(
        mouseCursor: settings.cursorOverride,
        onTap: () => launchGame(context, placeId, name),
        onLongPress: copy,
        onSecondaryTap: copy,
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

InputDecoration searchDecoration(String hint, IconData icon, {Widget? suffix}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.black26,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(settings.radius),
    ),
  );
}

// ============================================================
// Панель друзей
// ============================================================
class FriendsPanel extends StatefulWidget {
  FriendsPanel({super.key});
  @override
  State<FriendsPanel> createState() => _FriendsPanelState();
}

class _FriendsPanelState extends State<FriendsPanel> {
  List<Map<String, dynamic>> friends = [];
  Map<int, String> pics = {};
  bool loading = false;

  @override
  void initState() {
    super.initState();
    myNick.addListener(load);
    load();
  }

  @override
  void dispose() {
    myNick.removeListener(load);
    super.dispose();
  }

  Future<void> load() async {
    final nick = myNick.value;
    if (nick.isEmpty) {
      if (mounted) setState(() => friends = []);
      return;
    }
    setState(() => loading = true);
    final u = await api.findUser(nick);
    if (u == null) {
      if (!mounted) return;
      setState(() {
        loading = false;
        friends = [];
      });
      return;
    }
    final f = await api.friends(u['id'] as int);
    final p = await api.avatars([for (final e in f.take(20)) e['id'] as int]);
    if (!mounted) return;
    setState(() {
      friends = f;
      pics = p;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(settings.radius)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('friends_n', {'n': friends.length}),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
            if (myNick.value.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(t('friends_hint')),
              ),
            for (final f in friends.take(10))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          pics[f['id']] != null ? NetworkImage(pics[f['id']]!) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((f['displayName'] ?? f['name'] ?? '').toString(),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('@${f['name'] ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
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
  final focus = FocusNode();
  List<Map<String, dynamic>> games = [];
  Map<int, String> icons = {};
  bool loading = true;

  void _tick() {
    if (activeTab.value == 0) focus.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    searchTick.addListener(_tick);
    load();
  }

  @override
  void dispose() {
    searchTick.removeListener(_tick);
    link.dispose();
    focus.dispose();
    super.dispose();
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
        SnackBar(content: Text(t('id_not_found'))),
      );
      return;
    }
    launchGame(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final c = settings.color;
    final mainList = ListView(
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
              ValueListenableBuilder<String>(
                valueListenable: myNick,
                builder: (_, n, __) => Text(
                  n.isEmpty ? t('welcome') : t('welcome_back', {'n': n}),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(t('tagline')),
            ],
          ),
        ),
        SectionTitle(t('play_by_link')),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: link,
                focusNode: focus,
                mouseCursor: settings.cursorOverride,
                onSubmitted: (_) => go(),
                decoration: searchDecoration(t('link_hint'), Icons.link),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: go, child: Text(t('play'))),
          ],
        ),
        ValueListenableBuilder<List<MapEntry<int, String>>>(
          valueListenable: History.items,
          builder: (_, h, __) {
            if (h.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: SectionTitle(t('recent'))),
                    TextButton(onPressed: History.clear, child: Text(t('clear'))),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in h)
                      Pill(
                        text: e.value,
                        icon: Icons.history,
                        onTap: () => launchGame(context, e.key, e.value),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
        ValueListenableBuilder<Map<int, String>>(
          valueListenable: Favorites.items,
          builder: (_, favs, __) {
            if (favs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(t('favorites')),
                for (final e in favs.entries)
                  Card(
                    child: ListTile(
                      title: Text(e.value),
                      trailing: FilledButton(
                        onPressed: () => launchGame(context, e.key, e.value),
                        child: Text(t('play')),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        SectionTitle(t('popular')),
        if (loading) const LinearProgressIndicator(),
        if (!loading && games.isEmpty)
          Row(
            children: [
              Expanded(child: Text(t('load_failed'))),
              TextButton(onPressed: load, child: Text(t('retry'))),
            ],
          ),
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

    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth >= 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: mainList),
              SizedBox(
                width: 300,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  children: [FriendsPanel()],
                ),
              ),
            ],
          );
        }
        return mainList;
      },
    );
  }
}

// ============================================================
// Игры
// ============================================================
class GamesPage extends StatefulWidget {
  GamesPage({super.key});
  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final ctrl = TextEditingController(text: 'obby');
  final focus = FocusNode();
  static const tags = ['obby', 'simulator', 'tycoon', 'horror', 'anime', 'rpg', 'shooter', 'racing'];
  List<Map<String, dynamic>> games = [];
  Map<int, String> icons = {};
  bool loading = false;
  bool sortPlayers = false;

  void _tick() {
    if (activeTab.value == 1) focus.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    searchTick.addListener(_tick);
    search();
  }

  @override
  void dispose() {
    searchTick.removeListener(_tick);
    ctrl.dispose();
    focus.dispose();
    super.dispose();
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

  List<Map<String, dynamic>> get shown {
    final l = List<Map<String, dynamic>>.from(games);
    if (sortPlayers) {
      l.sort((a, b) =>
          (b['playerCount'] as num? ?? 0).compareTo(a['playerCount'] as num? ?? 0));
    }
    return l;
  }

  void randomGame() {
    final l = shown;
    if (l.isEmpty) return;
    final g = l[Random().nextInt(l.length)];
    launchGame(context, g['placeId'] as int, g['name']?.toString());
  }

  @override
  Widget build(BuildContext context) {
    final list = shown;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: ctrl,
            focusNode: focus,
            mouseCursor: settings.cursorOverride,
            onSubmitted: (_) => search(),
            decoration: searchDecoration(t('search_games'), Icons.search),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Pill(
                  text: t('sort_players'),
                  icon: Icons.trending_up,
                  selected: sortPlayers,
                  onTap: () => setState(() => sortPlayers = !sortPlayers),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Pill(
                  text: t('random_game'),
                  icon: Icons.casino_outlined,
                  onTap: randomGame,
                ),
              ),
              for (final tag in tags)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Pill(text: tag, onTap: () => search(tag)),
                ),
            ],
          ),
        ),
        if (loading) const LinearProgressIndicator(),
        if (!loading && games.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(t('nothing_found')),
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
            itemCount: list.length,
            itemBuilder: (_, i) =>
                GameCard(g: list[i], icon: icons[list[i]['universeId']]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
          child: Text(t('copy_hint'), style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

// ============================================================
// Профиль
// ============================================================
class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ctrl = TextEditingController();
  final focus = FocusNode();
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

  void _tick() {
    if (activeTab.value == 2) focus.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    ctrl.text = myNick.value;
    searchTick.addListener(_tick);
  }

  @override
  void dispose() {
    searchTick.removeListener(_tick);
    ctrl.dispose();
    focus.dispose();
    super.dispose();
  }

  Future<void> saveNick(String nick) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('nick', nick);
    myNick.value = nick;
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
        error = t('player_not_found');
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
    if (myNick.value.isEmpty) {
      await saveNick((u['name'] ?? nick).toString());
    }
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
          focusNode: focus,
          mouseCursor: settings.cursorOverride,
          onSubmitted: (_) => load(),
          decoration: searchDecoration(
            t('nick_hint'),
            Icons.person_search,
            suffix: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: load),
          ),
        ),
        if (loading)
          const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
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
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Center(child: Text('@${u['name'] ?? ''}')),
          if (info != null && (info!['created'] ?? '').toString().length >= 10)
            Center(
              child: Text(
                t('since', {'d': info!['created'].toString().substring(0, 10)}),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              stat(t('friends'), friendsCount),
              stat(t('followers'), followersCount),
              stat(t('following'), followingCount),
            ],
          ),
          if (info != null && (info!['description'] ?? '').toString().trim().isNotEmpty) ...[
            SectionTitle(t('about')),
            Text(info!['description'].toString(), maxLines: 6, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => openUrl('https://www.roblox.com/users/${u['id']}/profile'),
                icon: const Icon(Icons.open_in_new),
                label: Text(t('open_profile')),
              ),
              OutlinedButton.icon(
                onPressed: () => copyText(context, '${u['id']}', 'id_copied'),
                icon: const Icon(Icons.copy),
                label: Text(t('copy_id')),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await saveNick((u['name'] ?? '').toString());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(t('me_saved'))));
                  }
                },
                icon: const Icon(Icons.person_pin),
                label: Text(t('set_me')),
              ),
            ],
          ),
          if (worn.isNotEmpty) ...[
            SectionTitle(t('worn')),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in worn)
                  InkWell(
                    mouseCursor: settings.cursorOverride,
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
            SectionTitle(t('friends')),
            for (final f in friends.take(30))
              InkWell(
                mouseCursor: settings.cursorOverride,
                onTap: () {
                  ctrl.text = (f['name'] ?? '').toString();
                  load();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: friendPics[f['id']] != null
                            ? NetworkImage(friendPics[f['id']]!)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((f['displayName'] ?? f['name'] ?? '').toString()),
                            Text('@${f['name'] ?? ''}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ],
    );
  }
}

// ============================================================
// Каталог
// ============================================================
class CatalogPage extends StatefulWidget {
  CatalogPage({super.key});
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ctrl = TextEditingController(text: 'hat');
  final focus = FocusNode();
  static const tags = ['hat', 'hair', 'face', 'shirt', 'pants', 'wings', 'bundle', 'accessory'];
  List<Map<String, dynamic>> items = [];
  Map<int, String> pics = {};
  bool loading = false;

  void _tick() {
    if (activeTab.value == 3) focus.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    searchTick.addListener(_tick);
    search();
  }

  @override
  void dispose() {
    searchTick.removeListener(_tick);
    ctrl.dispose();
    focus.dispose();
    super.dispose();
  }

  String priceText(Map<String, dynamic> i) {
    final p = i['price'];
    if ('${i['priceStatus']}' == 'Off Sale') return t('off_sale');
    if (p == null) return '—';
    if (p == 0) return t('free');
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
            focusNode: focus,
            mouseCursor: settings.cursorOverride,
            onSubmitted: (_) => search(),
            decoration: searchDecoration(t('search_catalog'), Icons.search),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              for (final tag in tags)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Pill(text: tag, onTap: () => search(tag)),
                ),
            ],
          ),
        ),
        if (loading) const LinearProgressIndicator(),
        if (!loading && items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(t('nothing_found')),
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
                  mouseCursor: settings.cursorOverride,
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
                            Text(priceText(it), style: TextStyle(color: settings.color)),
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
// Инструменты: тест ввода, HUD, пинг
// ============================================================
class ToolsPage extends StatefulWidget {
  ToolsPage({super.key});
  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  Timer? _timer;
  bool testing = false;
  List<int>? pings;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted && activeTab.value == 4) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
    if (p.isEmpty) return t('ping_none');
    final mn = p.reduce((a, b) => a < b ? a : b);
    final mx = p.reduce((a, b) => a > b ? a : b);
    final avg = (p.reduce((a, b) => a + b) / p.length).round();
    final verdict = avg < 120 ? t('ping_good') : (avg < 250 ? t('ping_ok') : t('ping_high'));
    return t('ping_summary', {'a': mn, 'b': avg, 'c': mx, 'v': verdict});
  }

  bool _k(LogicalKeyboardKey k) => input.keys.contains(k);

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall;
    return ListenableBuilder(
      listenable: input,
      builder: (context, _) {
        final pressed = input.keys
            .map((k) => k.keyLabel.isNotEmpty ? k.keyLabel : (k.debugName ?? '?'))
            .join('  ');
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            SectionTitle(t('input_test')),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('input_hint'), style: small),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            KeyCap('W', _k(LogicalKeyboardKey.keyW)),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                KeyCap('A', _k(LogicalKeyboardKey.keyA)),
                                KeyCap('S', _k(LogicalKeyboardKey.keyS)),
                                KeyCap('D', _k(LogicalKeyboardKey.keyD)),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                KeyCap(
                                  'Shift',
                                  _k(LogicalKeyboardKey.shiftLeft) ||
                                      _k(LogicalKeyboardKey.shiftRight),
                                  w: 64,
                                ),
                                KeyCap(
                                  'Ctrl',
                                  _k(LogicalKeyboardKey.controlLeft) ||
                                      _k(LogicalKeyboardKey.controlRight),
                                  w: 64,
                                ),
                              ],
                            ),
                            KeyCap('Space', _k(LogicalKeyboardKey.space), w: 132),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                KeyCap('L', input.left),
                                KeyCap('M', input.middle),
                                KeyCap('R', input.right),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 96,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(settings.radius),
                        border: Border.all(color: Colors.white24),
                        color: Colors.black26,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${input.cps()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: settings.color)),
                              Text(t('cps'), style: small),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Text(t('click_here'),
                                textAlign: TextAlign.center, style: small),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('${t('max_cps')}: ${input.maxCps}'),
                    Text('${t('clicks_total')}: ${input.totalLeft} / ${input.totalRight}'),
                    Text('${t('scroll')}: ${input.scroll.round()}'),
                    ValueListenableBuilder<Offset?>(
                      valueListenable: cursorPos,
                      builder: (_, p, __) => Text(
                        '${t('pointer_pos')}: ${p == null ? '—' : '${p.dx.round()}, ${p.dy.round()}'}',
                      ),
                    ),
                    Text('${t('keys_pressed')}: ${pressed.isEmpty ? '—' : pressed}'),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: input.resetCounters,
                      icon: const Icon(Icons.restart_alt),
                      label: Text(t('reset')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: SwitchRow(
                title: t('hud_title'),
                subtitle: t('hud_sub'),
                value: settings.hud,
                onChanged: (v) {
                  settings.hud = v;
                  settings.save();
                },
              ),
            ),
            SectionTitle(t('ping_title')),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilledButton.icon(
                      onPressed: testing ? null : runPing,
                      icon: const Icon(Icons.network_ping),
                      label: Text(testing ? t('checking') : t('check_ping')),
                    ),
                    if (pings != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(pingSummary()),
                      ),
                    const SizedBox(height: 8),
                    Text(t('ping_note'), style: small),
                  ],
                ),
              ),
            ),
            SectionTitle(t('ingame_title')),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(t('ingame_text')),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// Настройки
// ============================================================
class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  static const _styleKeys = [
    'cs_system',
    'cs_hand',
    'cs_cross',
    'cs_ring',
    'cs_dot',
    'cs_plus',
    'cs_arrow',
  ];

  Widget _step(String title, String value, VoidCallback minus, VoidCallback plus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          IconButton(onPressed: minus, icon: const Icon(Icons.remove_circle_outline)),
          SizedBox(width: 52, child: Text(value, textAlign: TextAlign.center)),
          IconButton(onPressed: plus, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }

  void _done(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('done'))));
  }

  @override
  Widget build(BuildContext context) {
    final s = settings;
    final labels = navLabels();
    final small = Theme.of(context).textTheme.bodySmall;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SectionTitle(t('language')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in L10n.langs.entries)
              Pill(
                text: e.value,
                selected: s.lang == e.key,
                onTap: () {
                  s.lang = e.key;
                  s.save();
                },
              ),
          ],
        ),
        SectionTitle(t('appearance')),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(t('accent')),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < AppSettings.accents.length; i++)
                      Tap(
                        onTap: () {
                          s.accent = i;
                          s.save();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppSettings.accents[i],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: s.accent == i ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SwitchRow(
                title: t('amoled'),
                value: s.amoled,
                onChanged: (v) {
                  s.amoled = v;
                  s.save();
                },
              ),
              SwitchRow(
                title: t('stars'),
                value: s.stars,
                onChanged: (v) {
                  s.stars = v;
                  s.save();
                },
              ),
              SwitchRow(
                title: t('compact'),
                subtitle: t('compact_sub'),
                value: s.compact,
                onChanged: (v) {
                  s.compact = v;
                  s.save();
                },
              ),
              _step(
                t('radius'),
                '${s.radius.round()}',
                () {
                  s.radius = AppSettings.clampD(s.radius - 2, 4, 32);
                  s.save();
                },
                () {
                  s.radius = AppSettings.clampD(s.radius + 2, 4, 32);
                  s.save();
                },
              ),
              _step(
                t('font_size'),
                '${(s.fontScale * 100).round()}%',
                () {
                  s.fontScale = AppSettings.clampD(
                      double.parse((s.fontScale - 0.05).toStringAsFixed(2)), 0.8, 1.4);
                  s.save();
                },
                () {
                  s.fontScale = AppSettings.clampD(
                      double.parse((s.fontScale + 0.05).toStringAsFixed(2)), 0.8, 1.4);
                  s.save();
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('start_tab')),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < kTabs; i++)
                          Pill(
                            text: labels[i],
                            selected: s.startTab == i,
                            onTap: () {
                              s.startTab = i;
                              s.save();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SectionTitle(t('cursor')),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(t('cursor_style')),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _styleKeys.length; i++)
                      Pill(
                        text: t(_styleKeys[i]),
                        selected: s.cursorStyle == i,
                        onTap: () {
                          s.cursorStyle = i;
                          s.save();
                        },
                      ),
                  ],
                ),
              ),
              if (s.drawnCursor) ...[
                _step(
                  t('cursor_size'),
                  '${s.cursorSize.round()}',
                  () {
                    s.cursorSize = AppSettings.clampD(s.cursorSize - 4, 12, 64);
                    s.save();
                  },
                  () {
                    s.cursorSize = AppSettings.clampD(s.cursorSize + 4, 12, 64);
                    s.save();
                  },
                ),
                _step(
                  t('cursor_thick'),
                  '${s.cursorThick.round()}',
                  () {
                    s.cursorThick = AppSettings.clampD(s.cursorThick - 1, 1, 8);
                    s.save();
                  },
                  () {
                    s.cursorThick = AppSettings.clampD(s.cursorThick + 1, 1, 8);
                    s.save();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('cursor_color')),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (var i = 0; i < AppSettings.cursorColors.length; i++)
                            Tap(
                              onTap: () {
                                s.cursorColor = i;
                                s.save();
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppSettings.cursorColors[i] ?? s.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: s.cursorColor == i ? Colors.white : Colors.white24,
                                    width: s.cursorColor == i ? 3 : 1,
                                  ),
                                ),
                                child: i == 0
                                    ? const Icon(Icons.auto_awesome, size: 16)
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SwitchRow(
                  title: t('cursor_hide'),
                  value: s.hideSystem,
                  onChanged: (v) {
                    s.hideSystem = v;
                    s.save();
                  },
                ),
              ],
              SwitchRow(
                title: t('cursor_ripple'),
                value: s.cursorRipple,
                onChanged: (v) {
                  s.cursorRipple = v;
                  s.save();
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  height: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(s.radius),
                    border: Border.all(color: Colors.white24),
                    color: Colors.black26,
                  ),
                  child: Text(t('cursor_test'), style: small, textAlign: TextAlign.center),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Text(t('cursor_note'), style: small),
              ),
            ],
          ),
        ),
        SectionTitle(t('shortcuts')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('sc_tabs')),
                const SizedBox(height: 6),
                Text(t('sc_prev')),
                const SizedBox(height: 6),
                Text(t('sc_search')),
                const SizedBox(height: 6),
                Text(t('sc_esc')),
              ],
            ),
          ),
        ),
        SectionTitle(t('data')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: () async {
                await Favorites.clear();
                if (context.mounted) _done(context);
              },
              child: Text(t('clear_fav')),
            ),
            OutlinedButton(
              onPressed: () async {
                await History.clear();
                if (context.mounted) _done(context);
              },
              child: Text(t('clear_hist')),
            ),
            OutlinedButton(
              onPressed: () async {
                final p = await SharedPreferences.getInstance();
                await p.remove('nick');
                myNick.value = '';
                if (context.mounted) _done(context);
              },
              child: Text(t('forget_nick')),
            ),
            OutlinedButton(
              onPressed: () async {
                await settings.resetAll();
                if (context.mounted) _done(context);
              },
              child: Text(t('reset_all')),
            ),
          ],
        ),
        SectionTitle(t('about_title')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t('about_text')),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
