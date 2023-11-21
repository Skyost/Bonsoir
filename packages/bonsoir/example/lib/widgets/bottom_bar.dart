import 'package:bonsoir_example/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows to navigate through the app.
class BottomBar extends ConsumerWidget {
  /// Creates a new bottom bar instance.
  const BottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(appPageProvider);
    return BottomNavigationBar(
      currentIndex: AppPage.values.indexOf(currentPage),
      items: [
        for (AppPage page in AppPage.values)
          BottomNavigationBarItem(
            icon: Icon(page.icon),
            label: page.label,
          ),
      ],
      onTap: (index) => ref.read(appPageProvider.notifier).update((state) => AppPage.values[index]),
    );
  }
}
