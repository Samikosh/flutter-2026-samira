import 'package:flutter/material.dart';
import '../models/book.dart';

class BookCard extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onFavouriteToggle;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onFavouriteToggle,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final book = widget.book;

    final showBadge = book.isFull || book.freePlaces <= 5;
    final badgeText = book.isFull ? 'FULL' : '${book.freePlaces} left';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            splashColor: scheme.primary.withValues(alpha: 0.1),
            highlightColor: scheme.primary.withValues(alpha: 0.05),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: book.category.color(scheme).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          book.category.icon,
                          color: book.category.color(scheme),
                          size: 24,
                        ),
                      ),
                      if (showBadge)
                        Positioned(
                          bottom: 0,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: book.isFull ? scheme.error : scheme.primary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: scheme.surface, width: 2),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: scheme.onError,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: scheme.onSurface,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              '${book.when.day}.${book.when.month}.${book.when.year}',
                              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                                book.mode ? Icons.videocam : Icons.location_on,
                                size: 12,
                                color: scheme.onSurfaceVariant
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.mode ? "Online" : "Offline",
                              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      book.favourite ? Icons.favorite : Icons.favorite_border,
                      color: book.favourite ? scheme.error : scheme.outlineVariant,
                    ),
                    onPressed: widget.onFavouriteToggle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}