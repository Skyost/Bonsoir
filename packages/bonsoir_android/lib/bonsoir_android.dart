import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';

/// Class for the Android implementation of Bonsoir.
class BonsoirAndroid extends MethodChannelBonsoir {
  /// Attaches Bonsoir for Android to the Bonsoir platform interface.
  static void registerWith() => BonsoirPlatformInterface.instance = BonsoirAndroid();
}
