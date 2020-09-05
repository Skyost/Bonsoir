<div align="center">
    <img src="https://github.com/Skyost/Bonsoir/raw/master/images/logo.svg" height="200">
</div>

&nbsp;

[![Likes](https://badges.bar/bonsoir/likes)](https://pub.dev/packages/bonsoir/score)
[![Popularity](https://badges.bar/bonsoir/popularity)](https://pub.dev/packages/bonsoir/score)
[![Pub points](https://badges.bar/bonsoir/pub%20points)](https://pub.dev/packages/bonsoir/score)

_Bonsoir_ is a Zeroconf library that allows you to discover network services and to broadcast your own.
It's based on [Android NSD](https://developer.android.com/training/connect-devices-wirelessly/nsd)
and on Apple's popular framework [Bonjour](https://developer.apple.com/documentation/foundation/bonjour).
In fact, <q>Bonsoir</q> can be translated into <q>Good evening</q> (and <q>Bonjour</q> into <q>Good morning</q>
or <q>Good afternoon</q> depending on the current moment of the day).

## Preview

![Bonsoir preview](https://github.com/Skyost/Bonsoir/raw/master/images/preview.gif)

## Code snippets

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
await broadcast.ready;
await broadcast.start();

// ...

// Then if you want to stop the broadcast :
await broadcast.stop();
```

And here is how you can broadcast your service :

```dart
// This is the type of service we're looking for :
String type = '_wonderful-service._tcp';

// Once defined, we can start the discovery :
BonsoirDiscovery discovery = BonsoirDiscovery(type: type);
await discovery.ready;
await discovery.start();

// If you want to listen to the discovery :
discovery.eventStream.listen((event) {
  if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_RESOLVED) {
    print('Service found : ${event.service.toJson()}')
  } else if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_LOST) {
    print('Service lost : ${event.service.toJson()}')
  }
});

// Then if you want to stop the discovery :
await discovery.stop();
```

If you want a <q>full</q> example, don't hesitate to check [this one](https://github.com/Skyost/Bonsoir/tree/master/example) on Github.

## Final notes

This plugin [cannot be tested on an Android emulator](https://stackoverflow.com/a/46926325/3608831)
(well it can, but the only services that you are able to discover are the ones broadcasted by your emulator).

Also, if you're building your app for iOS 14, you may have to edit your `Info.plist` file according to
[this answer](https://developer.apple.com/forums/thread/653316?answerId=619462022#619462022) on Apple Developer Forums.

The hand icon has been created by [Vitaly Gorbachev](https://www.flaticon.com/authors/vitaly-gorbachev).

## Contributions

You have a lot of options to contribute to this project ! You can :

* [Fork it](https://github.com/Skyost/Bonsoir/fork) on Github.
* [Submit](https://github.com/Skyost/Bonsoir/issues/new/choose) a feature request or a bug report.
* [Donate](https://paypal.me/Skyost) to the developer.
* [Watch a little ad](https://www.clipeee.com/creator/skyost) on Clipeee.
