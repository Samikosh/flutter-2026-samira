import 'models.dart';

// ===== Level 5: sealed class =====
sealed class ShelfState {
  const ShelfState();
}

class Empty extends ShelfState {
  const Empty();
}

class Ready extends ShelfState {
  final List<Book> books;
  const Ready(this.books);
}

class Broken extends ShelfState {
  final String message;
  const Broken(this.message);
}

// switch expression — no default
String describe(ShelfState state) => switch (state) {
  Empty() => 'The shelf is empty.',
  Ready(:final books) => 'The shelf holds ${books.length} books.',
  Broken(:final message) => 'The shelf is broken: $message',
};

// record — not a class, not a List
({int count, double avgPages}) statsOf(List<Book> books) {
  if (books.isEmpty) return (count: 0, avgPages: 0);
  final total = books.fold<int>(0, (sum, b) => sum + b.pages);
  return (count: books.length, avgPages: total / books.length);
}