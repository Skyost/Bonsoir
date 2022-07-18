# bonsoir_platform_interface
  
A common platform interface for the [`bonsoir`](https://github.com/Skyost/Bonsoir) plugin.

This interface allows platform-specific implementations of the `bonsoir` plugin, as well as the plugin itself, to ensure they are supporting the same interface.

# Usage

To implement a new platform-specific implementation of `bonsoir`, extend [`BonsoirPlatformInterface`](https://github.com/Skyost/Bonsoir/blob/master/bonsoir_platform_interface/lib/src/platform_interface.dart) with an implementation that performs the platform-specific behavior, 
and when you register your plugin, you need to set a default factory function in `BonsoirPlatformInterface` by calling `BonsoirPlatformInterface.instance = <Your factory function>`. 

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface) over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion on why a less-clean interface is preferable to a breaking change.
