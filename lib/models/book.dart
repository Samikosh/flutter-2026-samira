import 'category.dart';

class Book {
  final String id;
  final String title;
  final BookCategory category;
  final DateTime when;
  final int limit;
  final List<String> readers;
  final bool mode; // true = online, false = offline
  final String? description;
  final bool favourite;

  // R1: Immutable, const constructor, readers list cannot be mutated from outside
  Book({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.limit,
    required List<String> readers,
    required this.mode,
    this.description,
    required this.favourite,
  }) : readers = List.unmodifiable(readers);

  // R3: Named constructor for empty defaults
  Book.empty()
      : id=' ',
        title = '',
        category = BookCategory.fantasy,
        when = DateTime.now().add(const Duration(days: 1)),
        limit = 10,
        readers = const [],
        mode = false,
        description = null,
        favourite = false;

  // R1: copyWith
  Book copyWith({
    String? id,
    String? title,
    BookCategory? category,
    DateTime? when,
    int? limit,
    List<String>? readers,
    bool? mode,
    String? description,
    bool? favourite,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      when: when ?? this.when,
      limit: limit ?? this.limit,
      readers: readers ?? this.readers,
      mode: mode ?? this.mode,
      description: description ?? this.description,
      favourite: favourite ?? this.favourite,
    );
  }

  // R4: Derived values are getters, never fields
  int get count => readers.length;
  int get freePlaces => limit - count;
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());

  bool contains(String name) => readers.contains(name);

  // R5: Record getter
  ({int taken, int free}) get places => (taken: count, free: freePlaces);
}