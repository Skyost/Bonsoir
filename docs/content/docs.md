# Installation

## Requirements

Depending on your project targets, you need at least :

* Android : API level 21 (Android 5.0), which corresponds to minimum Android version supported by Flutter.
  Note that attributes don't work on Android 6.0 and below
  (see [this ticket](https://issuetracker.google.com/issues/37020436) for more details).
* iOS : 13.0, because Bonsoir relies on `NWBrowser`.
* macOS : 10.15 (El Capitan), for the same reason as above.
* Windows : Win 10 (19H1/1903) (Mai 2019 Update).
  The [WIN32 DNS-SD API](https://msdn.microsoft.com/en-us/library/windows.networking.servicediscovery.dnssd.aspx)
  has been exposed from, at least, that version.
* Linux : requires [Avahi daemon](https://www.avahi.org/), because Bonsoir uses its D-Bus interface
  for browsing and registering mDNS/DNS-SD services.

This plugin [cannot be tested on an Android emulator](https://stackoverflow.com/a/46926325/3608831)
(well it can, but the only services that you are able to discover are the ones broadcasted by your emulator).

## Depend on it

In your Flutter project directory, run the following commands :

```shell
flutter pub add bonsoir
flutter pub get
```

## Additional instructions

### iOS

If you want to use this plugin on iOS, you must update your deployment target to _at least_ 13.0.
At the top of `ios/Podfile`, add the following :

```shell [ios/Podfile]
platform :ios, '13.0'
```

Also, open your iOS project in Xcode and select Runner, Targets -> Runner and then the "General" tab.
Under the "Minimum Deployments" section, update the iOS version to 13.0 or higher.

If you're building your app for iOS 14 or higher, you have to edit your `Info.plist` file. Just add
the following lines :

```xml [ios/Info.plist]
<key>NSLocalNetworkUsageDescription</key>
<string>Describe here why you want to use Bonsoir.</string>
<key>NSBonjourServices</key>
<array>
	<string>_first-service._tcp</string>
	<string>_second-service._tcp</string>
	<string>_third-service._tcp</string>
	<!-- Add more here -->
</array>
```

Don't forget to edit them according to your needs.

### macOS

If you want to use this plugin on macOS, you must update your deployment target to _at least_ 10.15.
At the top of `macos/Podfile`, add the following :

```shell [macos/Podfile]
platform :ios, '10.15'
```

Also, open your macOS project in Xcode and select Runner, Targets -> Runner and then the "General" tab.
Under the "Minimum Deployments" section, update the macOS version to 10.15 or higher.

### Linux

If you don't have Avahi installed on your system, just install it using :

```shell
sudo apt install -y avahi-daemon avahi-discover avahi-utils libnss-mdns mdns-scan
```

# Getting started

Bonsoir has been made to be as easy to use as possible.

## Broadcast a service

Here is how you can broadcast your service using _Bonsoir_ :

```dart
// Let's create our service !
BonsoirService service = BonsoirService(
  name: 'My wonderful service', // Put your service name here.
  type: '_wonderful-service._tcp', // Put your service type here. Syntax : _ServiceType._TransportProtocolName. (see http://wiki.ros.org/zeroconf/Tutorials/Understanding%20Zeroconf%20Service%20Types).
  port: 3030, // Put your service port here.
);

// And now we can broadcast it :
BonsoirBroadcast broadcast = BonsoirBroadcast(service: service);
await broadcast.initialize();
await broadcast.start();

// ...

// Then if you want to stop the broadcast :
await broadcast.stop();
```

## Discover services

Here is how you can search for a broadcasted service :

```dart
// This is the type of service we're looking for :
String type = '_wonderful-service._tcp';

// Once defined, we can start the discovery :
BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
await discovery.initialize();

// If you want to listen to the discovery :
discovery.eventStream!.listen((event) { // `eventStream` is not null as the discovery instance is "ready" !
  switch (event) {
    case BonsoirDiscoveryServiceFoundEvent():
      print('Service found : ${event.service.toJson()}');
      event.service!.resolve(discovery.serviceResolver); // Should be called when the user wants to connect to this service.
      break;
    case BonsoirDiscoveryServiceResolvedEvent():
      print('Service resolved : ${event.service.toJson()}');
      break;
    case BonsoirDiscoveryServiceUpdatedEvent():
      print('Service updated : ${event.service.toJson()}');
      break;
    case BonsoirDiscoveryServiceLostEvent():
      print('Service lost : ${event.service.toJson()}');
      break;
    default:
      print('Another event occurred : $event.');
      break;
  }
});

// Start the discovery **after** listening to discovery events :
await discovery.start();

// Then if you want to stop the discovery :
await discovery.stop();
```

**Note.** If you're transitioning from `multicast_dns`, note that types don't end with <q>.local</q>.

# In-depth example

If you want a <q>full</q> example, don't hesitate to check
[this one](https://github.com/Skyost/Bonsoir/tree/master/packages/bonsoir/example) on Github.

To run it :

1. [Install Melos](https://melos.invertase.dev/~melos-latest/getting-started#installation).
2. [Clone the repository](https://github.com/Skyost/Bonsoir/archive/refs/heads/master.zip).
3. Run `melos bs`.
4. Go to the `packages/bonsoir/example` directory, and run `flutter run`.

# Contribute

You have a lot of options to contribute to this project ! You can :

* [Fork it](https://github.com/Skyost/Bonsoir/fork) on Github to submit your pull requests.
* [Submit](https://github.com/Skyost/Bonsoir/issues/new/choose) a feature request or a bug report.
* [Donate](https://paypal.me/Skyost) to the developer.

# About

This plugin was initially created to use in my game, [Mobile Werewolf](https://werewolf.skyost.eu).
It is an unofficial mobile version of the famous board game Mafia / Werewolves.
In this game, players can play against each others via Wi-Fi, so Bonsoir allows them to easily broadcast,
discover and join local network parties.

<p style="display-block; text-align: center;">
  <a href="https://apps.apple.com/app/id1504559806" class="mb-1 mb-sm-0" style="display: inline-block; width: 200px; max-width: 90%;">
    <img src="https://werewolf.skyost.eu/images/stores/app_store.svg" alt="App Store" style="width: 100%;" />
  </a>
  <a href="https://play.google.com/store/apps/details?id=fr.skyost.werewolf" style="display: inline-block; width: 200px; max-width: 90%;">
    <img src="https://werewolf.skyost.eu/images/stores/play_store.svg" alt="Play Store" style="width: 100%;" />
  </a>
</p>

The hand icon has been created by [Vitaly Gorbachev](https://www.flaticon.com/authors/vitaly-gorbachev).
