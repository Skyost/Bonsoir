# bonsoir_windows

The Windows implementation of [`bonsoir`](https://pub.dev/packages/bonsoir).

## Usage

This package
is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `bonsoir` normally. This package will be automatically included in
your app when you do.

## Thanks

I tried various things before arriving at the current implementation :

* Dart FFI : thanks to [Piero512](https://github.com/Piero512/bonjour_ffi).
* `<dns-hd.h>` : thanks
  to [Bennik2000](https://github.com/Bennik2000/Bonsoir/tree/bonsoir_windows/bonsoir_windows).
* `<WinDNS.h>` : (current implementation): thanks
  to [sebastianhaberey](https://github.com/sebastianhaberey/nsd).
