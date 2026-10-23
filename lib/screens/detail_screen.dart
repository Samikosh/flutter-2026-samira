import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/countdown.dart';

class DetailScreen extends StatefulWidget {
  final Book book;
  final VoidCallback onBorrow;
  final bool isBorrowed;

  const DetailScreen({
    super.key,
    required this.book,
    required this.onBorrow,
    required this.isBorrowed,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Countdown _countdown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _countdown = getCountdown(widget.book.when);

    // R13: Timer әр минут сайын жаңарады
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _countdown = getCountdown(widget.book.when);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // R13: dispose-та таймерді тоқтату
    super.dispose();
  }

  String _formatCountdown(Countdown c) {
    return switch (c) {
      CountdownUpcoming(:final duration) => '${duration.inDays}d ${duration.inHours % 24}h left',
      CountdownStarted(:final duration) => 'Started ${duration.inMinutes}m ago',
      CountdownEnded() => 'Ended',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final book = widget.book;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                actions: [
                  // R31: Мәзір (Edit, Delete)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete book?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
                // R24: Stack header
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [scheme.primary, scheme.primary.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(book.category.icon, size: 100, color: scheme.onPrimary.withOpacity(0.3)),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Column(
            children: [
              // Тақырып пен Таймер
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(label: Text(book.category.label)),
                        const SizedBox(width: 8),
                        Text(_formatCountdown(_countdown), style: TextStyle(color: scheme.error, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              // R29: TabBar
              const TabBar(
                tabs: [
                  Tab(text: 'About'),
                  Tab(text: 'Readers'),
                ],
              ),
              // TabBarView
              Expanded(
                child: TabBarView(
                  children: [
                    // 1-ші таб: About
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${book.when.day}.${book.when.month}.${book.when.year}'),
                          const SizedBox(height: 8),
                          Text('Places: ${book.places.taken} / ${book.limit}'),
                          const SizedBox(height: 8),
                          // R6: Optional text shown with collection if
                          if (book.description != null) ...[
                            const SizedBox(height: 16),
                            Text('Description: ${book.description}', style: const TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                    ),
                    // 2-ші таб: Readers
                    ListView.builder(
                      itemCount: book.readers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(book.readers[index]),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // R15, R16: Төмендегі "Borrow" батырмасы
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: book.isFull || widget.isBorrowed
                  ? null // R16: Егер толы болса немесе қазірдің өзінде алған болса
                  : widget.onBorrow,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.isBorrowed
                    ? 'Already Borrowed'
                    : (book.isFull ? 'Full' : 'Borrow'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}