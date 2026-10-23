import 'package:flutter/material.dart';
import 'data/seed_data.dart';
import 'models/book.dart';
import 'models/profile.dart';
import 'screens/list_tab.dart';
import 'screens/detail_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _changeTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF800020); // Бордовый

    return MaterialApp(
      title: 'Reading Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          surface: const Color(0xFFFCF9F7),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFCF9F7),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: AppShell(
        themeMode: _themeMode,
        onThemeChanged: _changeTheme,
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late List<Book> _books;
  Profile _profile = const Profile(name: '', group: '');

  @override
  void initState() {
    super.initState();
    _books = getSeedBooks();
  }

  void _updateBooks(List<Book> newBooks) {
    setState(() => _books = newBooks);
  }

  void _updateProfile(Profile newProfile) {
    setState(() => _profile = newProfile);
  }

  void _resetData() {
    setState(() {
      _books = getSeedBooks();
      _profile = const Profile(name: '', group: '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Жалпы BookTap функциясы (List және Favourites үшін)
    void onBookTap(Book book) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailScreen(
            book: book,
            isBorrowed: book.readers.contains(_profile.name),
            onBorrow: () {
              if (_profile.name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please set your name in Profile first.')),
                );
                return;
              }
              final updatedBook = book.copyWith(
                readers: [...book.readers, _profile.name],
              );
              _updateBooks(_books.map((b) => b.title == book.title ? updatedBook : b).toList());
              Navigator.pop(context);
            },
          ),
        ),
      );
    }

    final tabs = [
      // 1-ші таб: ListTab
      ListTab(
        books: _books,
        onBooksChanged: _updateBooks,
        onBookTap: onBookTap,
      ),

      // 2-ші таб: Favourites
      ListTab(
        books: _books.where((b) => b.favourite).toList(),
        onBooksChanged: (newFavs) {
          final updatedBooks = _books.map((b) {
            final updatedFav = newFavs.firstWhere((f) => f.title == b.title, orElse: () => b);
            return updatedFav;
          }).toList();
          _updateBooks(updatedBooks);
        },
        onBookTap: onBookTap,
      ),

      // 3-ші таб: Profile
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              onSubmitted: (v) => _updateProfile(_profile.copyWith(name: v)),
              controller: TextEditingController(text: _profile.name),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Group', border: OutlineInputBorder()),
              onSubmitted: (v) => _updateProfile(_profile.copyWith(group: v)),
              controller: TextEditingController(text: _profile.group),
            ),
            const SizedBox(height: 32),
            const Text('Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Light'),
                  selected: widget.themeMode == ThemeMode.light,
                  onSelected: (_) => widget.onThemeChanged(ThemeMode.light),
                ),
                ChoiceChip(
                  label: const Text('Dark'),
                  selected: widget.themeMode == ThemeMode.dark,
                  onSelected: (_) => widget.onThemeChanged(ThemeMode.dark),
                ),
                ChoiceChip(
                  label: const Text('System'),
                  selected: widget.themeMode == ThemeMode.system,
                  onSelected: (_) => widget.onThemeChanged(ThemeMode.system),
                ),
              ],
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: scheme.primary),
              child: Text(
                'Reading Club',
                style: TextStyle(color: scheme.onPrimary, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('About'),
                    content: const Text('Reading Club App. Lab 1 Project.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset data'),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset data?'),
                    content: const Text('This will restore the seed books and clear your profile.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  _resetData();
                }
              },
            ),
          ],
        ),
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'List'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favourites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}