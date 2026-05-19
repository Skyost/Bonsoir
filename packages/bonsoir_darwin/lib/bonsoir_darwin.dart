import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';

/// Class for the Darwin implementation of Bonsoir.
class BonsoirDarwin extends MethodChannelBonsoir {
  /// Attaches Bonsoir for Darwin to the Bonsoir platform interface.
  static void registerWith() => BonsoirPlatformInterface.instance = BonsoirDarwin();
}