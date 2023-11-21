import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appPageProvider = StateProvider<AppPage>((_) => AppPage.discoveries);

/// An app page.
enum AppPage {
  /// "Discoveries" page.
  discoveries(
    icon: Icons.search,
    label: 'Discoveries',
  ),

  /// "Broadcasts" page.
  broadcasts(
    icon: Icons.wifi_tethering,
    label: 'Broadcasts',
  );

  /// The page icon.
  final IconData icon;

  /// The page label.
  final String label;

  /// Creates a new app page instance.
  const AppPage({
    required this.icon,
    required this.label,
  });
}
