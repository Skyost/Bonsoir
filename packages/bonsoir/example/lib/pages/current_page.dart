import 'package:bonsoir_example/pages/broadcasts.dart';
import 'package:bonsoir_example/pages/discoveries.dart';
import 'package:bonsoir_example/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentPageWidget extends ConsumerWidget {
  const CurrentPageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppPage currentPage = ref.watch(appPageProvider);
    switch (currentPage) {
      case AppPage.broadcasts:
        return const BroadcastsPageWidget();
      case AppPage.discoveries:
        return const DiscoveriesPageWidget();
    }
  }
}
