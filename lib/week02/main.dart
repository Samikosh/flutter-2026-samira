import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  // Build library from rawBooks
  final library = Library();
  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }
  library.open();

  // Print queries
  print('=== Catalogue ===');
  for (final line in library.displayList) {
    print(line);
  }

  print('\n=== All titles ===');
  print(library.allTitles);

  print('\n=== Books after 2010 ===');
  print(library.booksAfter2010.map((b) => b.title).toList());

  print('\n=== Average pages ===');
  print(library.averagePages);

  print('\n=== Books by author ===');
  print(library.booksByAuthor);

  print('\n=== Distinct authors ===');
  print(library.distinctAuthors);

  print('\n=== Genres present ===');
  print(library.genresPresent);

  print('\n=== Country of "Clean Code" ===');
  print(library.countryOf('Clean Code'));

  print('\n=== Country of "Nonexistent" ===');
  print(library.countryOf('Nonexistent'));

  // statsOf record
  final books = library.items.whereType<Book>().toList();
  final stats = statsOf(books);
  print('\n=== Stats record ===');
  print('count: ${stats.count}, avgPages: ${stats.avgPages}');

  // describe for all three states
  print('\n=== Shelf states ===');
  print(describe(const Empty()));
  print(describe(Ready(books)));
  print(describe(const Broken('shelf fell over')));
}