import 'package:bonsoir_example/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows to navigate through the app.
class BottomBar extends ConsumerWidget {
  /// The current page index.
  final int currentIndex;

  /// Triggered when the page changes.
  final Function(int) onPageChange;

  /// Creates a new bottom bar instance.
  const BottomBar({
    super.key,
    this.currentIndex = 0,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => BottomNavigationBar(
      currentIndex: currentIndex,
      items: [
        for (AppPage page in AppPage.values)
          BottomNavigationBarItem(
            icon: Icon(page.icon),
            label: page.label,
          ),
      ],
      onTap: onPageChange,
    );
}
