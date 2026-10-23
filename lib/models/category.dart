import 'package:flutter/material.dart';

enum BookCategory {
  fantasy('Fantasy', Icons.auto_stories),
  sciFi('Sci-Fi', Icons.rocket_launch),
  classic('Classic', Icons.history_edu),
  business('Business', Icons.business_center),
  psychology('Psychology', Icons.psychology);

  final String label;
  final IconData icon;

  const BookCategory(this.label, this.icon);

  Color color(ColorScheme scheme) => switch (this) {
    BookCategory.fantasy => scheme.primary,
    BookCategory.sciFi => scheme.secondary,
    BookCategory.classic => scheme.tertiary,
    BookCategory.business => scheme.error,
    BookCategory.psychology => scheme.surfaceTint,
  };
}