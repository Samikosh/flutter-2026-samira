import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../widgets/book_card.dart';
import 'book_form_screen.dart';

class ListTab extends StatefulWidget {
  final List<Book> books;
  final Function(List<Book>) onBooksChanged;
  final Function(Book) onBookTap;

  const ListTab({
    super.key,
    required this.books,
    required this.onBooksChanged,
    required this.onBookTap,
  });

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  String _searchQuery = '';
  BookCategory? _selectedCategory;
  bool _showOnlyPast = false;

  @override
  Widget build(BuildContext context) {
    final filteredBooks = widget.books.where((book) {
      final matchesSearch = book.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || book.category == _selectedCategory;
      final matchesPast = !_showOnlyPast || book.isPast;
      return matchesSearch && matchesCategory && matchesPast;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Club'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newBook = await Navigator.push<Book>(
                context,
                MaterialPageRoute(builder: (_) => const BookFormScreen()),
              );
              if (newBook != null) {
                widget.onBooksChanged([...widget.books, newBook]);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                for (final cat in BookCategory.values) ...[
                  ChoiceChip(
                    label: Text(cat.label),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Past items'),
                  selected: _showOnlyPast,
                  onSelected: (val) => setState(() => _showOnlyPast = val),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredBooks.isEmpty
                ? const Center(child: Text('No books found'))
                : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 600) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      mainAxisExtent: 120,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return BookCard(
                        book: book,
                        onTap: () => widget.onBookTap(book),
                        onFavouriteToggle: () => _toggleFavourite(book),
                      );
                    },
                  );
                }
                return ListView.builder(
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return BookCard(
                      book: book,
                      onTap: () => widget.onBookTap(book),
                      onFavouriteToggle: () => _toggleFavourite(book),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavourite(Book book) {
    final updated = widget.books.map((b) {
      if (b == book) return b.copyWith(favourite: !b.favourite);
      return b;
    }).toList();
    widget.onBooksChanged(updated);
  }
}