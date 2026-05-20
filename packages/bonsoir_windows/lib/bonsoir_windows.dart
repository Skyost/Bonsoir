import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';

/// Class for the Windows implementation of Bonsoir.
class BonsoirWindows extends MethodChannelBonsoir {
  /// Attaches Bonsoir for Windows to the Bonsoir platform interface.
  static void registerWith() => BonsoirPlatformInterface.instance = BonsoirWindows();
}
