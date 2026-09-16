import 'models.dart';

// Level 3: Null safety
class Library {
  final List<LibraryItem> items = [];
  late final DateTime openedAt;
  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
  }

  void open() {
    openedAt = DateTime.now();
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) {
    final book = findByTitle(title);
    return book?.author.country ?? 'unknown';
  }

  String buildReport() {
    return _cachedReport ??= items.map((i) => i.describe()).join('\n');
  }

  // Level 4: Collections

  List<String> get allTitles => items.map((i) => i.title).toList();

  List<Book> get booksAfter2010 =>
      items.whereType<Book>().where((b) => b.year > 2010).toList();

  // fold, not reduce — reduce throws on empty list
  double get averagePages {
    final books = items.whereType<Book>().toList();
    if (books.isEmpty) return 0;
    final total = books.fold<int>(0, (sum, b) => sum + b.pages);
    return total / books.length;
  }


  Map<String, int> get booksByAuthor => items
      .whereType<Book>()
      .fold<Map<String, int>>({}, (map, book) {
    map[book.author.name] = (map[book.author.name] ?? 0) + 1;
    return map;
  });

  Set<String> get distinctAuthors =>
      items.whereType<Book>().map((b) => b.author.name).toSet();

  Set<Genre> get genresPresent =>
      items.whereType<Book>().map((b) => b.genre).toSet();

  List<String> get displayList => [
    'CATALOGUE',
    for (final book in items.whereType<Book>())
      '${book.title} (${book.year})',
    ...distinctAuthors,
    if (items.whereType<Book>().any((b) => b.pages == 0))
      '(incomplete data)',
  ];
}