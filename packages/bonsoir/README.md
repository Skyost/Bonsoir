<div align="center">
    <img src="https://github.com/Skyost/Bonsoir/raw/main/packages/bonsoir/images/logo.svg" height="200">
</div>

&nbsp;

_Bonsoir_ is a Zeroconf library that allows you to discover network services and to broadcast your own.
It's based on [Android NSD](https://developer.android.com/training/connect-devices-wirelessly/nsd)
and on Apple's popular framework [Bonjour](https://developer.apple.com/documentation/foundation/bonjour).
In fact, <q>Bonsoir</q> can be translated into <q>Good evening</q> (and <q>Bonjour</q> into <q>Good morning</q>
or <q>Good afternoon</q> depending on the current moment of the day).

[![Pub Likes](https://img.shields.io/pub/likes/bonsoir?style=flat-square)](https://pub.dev/packages/bonsoir/score)
[![Pub Monthly Downloads](https://img.shields.io/pub/dm/bonsoir?style=flat-square)](https://pub.dev/packages/bonsoir/score)
[![Pub Points](https://img.shields.io/pub/points/bonsoir?style=flat-square)](https://pub.dev/packages/bonsoir/score)
[![Maintained with Melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

## Preview

![Bonsoir preview](https://github.com/Skyost/Bonsoir/raw/main/packages/bonsoir/images/preview.gif)

## Installation

See [how to install](https://bonsoir.skyost.eu/docs#installation) on the Bonsoir website.

## Code snippet

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

And here is how you can search for a broadcasted service :

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

If you want a <q>full</q> example, don't hesitate to check [this one](https://github.com/Skyost/Bonsoir/tree/main/packages/bonsoir/example) on Github.

## Contributions

You have a lot of options to contribute to this project ! You can :

* [Fork it](https://github.com/Skyost/Bonsoir/fork) on Github.
* [Submit](https://github.com/Skyost/Bonsoir/issues/new/choose) a feature request or a bug report.
* [Donate](https://paypal.me/Skyost) to the developer.
