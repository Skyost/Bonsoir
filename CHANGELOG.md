# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2023-11-20

### Changes

---

Packages with breaking changes:

 - [`bonsoir_linux` - `v5.0.0`](#bonsoir_linux---v500)
 - [`bonsoir_platform_interface` - `v5.0.0`](#bonsoir_platform_interface---v500)

Packages with other changes:

 - [`bonsoir` - `v5.0.0`](#bonsoir---v500)
 - [`bonsoir_darwin` - `v5.0.0`](#bonsoir_darwin---v500)
 - [`bonsoir_windows` - `v5.0.0`](#bonsoir_windows---v500)
 - [`bonsoir_android` - `v5.0.0`](#bonsoir_android---v500)

---

#### `bonsoir_linux` - `v5.0.0`

 - **FIX**(linux): Parsing TXT record now closely follow RFC 6763. ([f2e7d5b5](https://github.com/Skyost/Bonsoir/commit/f2e7d5b56ed0b418d3102bc3fbdf09162988f51c))
 - **FIX**(linux): Fixed how we handle FQDN and TXT records on Linux. ([f1e4fde5](https://github.com/Skyost/Bonsoir/commit/f1e4fde5ad6a5c9428dae488d77ed6c278cb5246))
 - **BREAKING** **REFACTOR**(linux): Now following Dart's convention regarding the `src` folder. ([80216578](https://github.com/Skyost/Bonsoir/commit/80216578502650e6a24535d257d42dc3aa04a864))

#### `bonsoir_platform_interface` - `v5.0.0`

 - **BREAKING** **FEAT**: Added a normalizer to conform to RFC 6335 and RFC 6763. ([f8c0487f](https://github.com/Skyost/Bonsoir/commit/f8c0487fee440eab02013e33ba5ba5e0daccc918))

#### `bonsoir` - `v5.0.0`

 - Bump "bonsoir" to `5.0.0`.

#### `bonsoir_darwin` - `v5.0.0`

 - **FIX**(darwin): Fixed how we handle FQDN on Darwin. ([158f0138](https://github.com/Skyost/Bonsoir/commit/158f0138e344f016875c3ee0aa2bbc7009ed46c8))

#### `bonsoir_windows` - `v5.0.0`

 - **FIX**(windows): Fixed how we handle FQDN and TXT records on Windows. ([1e7d5451](https://github.com/Skyost/Bonsoir/commit/1e7d545197f2806d46d1923e5987aef64437fc19))

#### `bonsoir_android` - `v5.0.0`

 - **FIX**(android): Fixed a crash occurring when a service TXT record could not be resolved. ([a9387d9d](https://github.com/Skyost/Bonsoir/commit/a9387d9d9514d2e8936ff7afd7c848615cbb8233))
 - **FIX**(android): Fixed some problems occurring with types ending with a dot. ([556aed80](https://github.com/Skyost/Bonsoir/commit/556aed80ca1e9899c49ea2c91c9fb91f1ec6aba1))

aggrgatez

## 4.1.4

 - **FIX**: Fixed all links to the Github repository. ([9449e318](https://github.com/Skyost/Bonsoir/commit/9449e3185016d9531c4dfd8e46cc7bdbdbe563d0))

## 4.1.3

 - **FIX**(bonsoir): Updated `pubspec.yaml`. ([c35c9f7b](https://github.com/Skyost/Bonsoir/commit/c35c9f7bf3ec6b4b91f6c040b90a9d97157ae62e))

## 4.1.2

 - **REFACTOR**: Now using `melos` to handle the `bonsoir` packages. ([9c10a0c5](https://github.com/Skyost/Bonsoir/commit/9c10a0c588e407d80f7551ebb992e9b70b05da92))

## 4.1.1

* Fixed `bonsoir_linux` not being added to the plugin's _pubspec.yaml_.

## 4.1.0

* First implementation of Bonsoir for Windows.
* First implementation of Bonsoir for Linux.
* Added a `broadcastNameAlreadyExists` event.
* Removed the `fromJson` constructor of `BonsoirBroadcast` and `BonsoirDiscovery`.
* Various other fixes and improvements.

## 4.0.0

* Removed the dependence on the native `NetService` library.
* `service.ip` is now `service.host`.

## 3.0.0+1

* Fixed the README examples.
* Fixed every package changelog date.

## 3.0.0

* Now, services are not directly resolved by default.

## 2.2.0+1

* Fixed the badges links in the README.

## 2.2.0

* Updated SDK constraints.

## 2.1.0

* Added support of namespace property to support Android Gradle Plugin (AGP) 8. Projects with AGP < 4.2 are not supported anymore. It is highly recommended to update at least to AGP 7.0 or newer.

## 2.0.0

* Splitting the project into separate packages.
* Updated libraries.

## 1.0.1+2

* Fixed a build error on iOS.

## 1.0.1+1

* Fixed a build error on Android.

## 1.0.1

* Now checks if listener is registered in `NSDService` (thanks [victorkifer](https://github.com/victorkifer)).
* Fixed attributes value is covered to `Optional()` on iOS (thanks [RyoheiTomiyama](https://github.com/RyoheiTomiyama)).
* Fixed Bonjour Service Decoder (thanks [woody-LWD](https://github.com/woody-LWD)).
* Added null check around getAttributes result. (thanks [kultivator-consulting](https://github.com/kultivator-consulting)).
* Fixed a null pointer exception in `SuccessObject`.

## 1.0.0+1

* Updated README (thanks [lsegal](https://github.com/lsegal)).

## 1.0.0

* Transitioned to federated plugin (thanks [Piero512](https://github.com/Piero512)).

## 0.1.3+2

* Fixed a problem with symlinks on macOS and iOS.

## 0.1.3+1

* Ran `dartfmt` (in order to improve pub.dev score 🙄).

## 0.1.3

* Added support for services attributes.
* Added tests for service discovery (thanks [DominikStarke](https://github.com/DominikStarke)).

## 0.1.2+2

* Fixed symlinks error for iOS and macOS.
* improved an error message.

## 0.1.2+1

* Formatted the code using `dartfmt`.
* Updated README.

## 0.1.2

* Fixed a bug that was occurring with Pixel devices.
* Improved service resolution.
* Added a link into the README for using the library on iOS 14.

## 0.1.1

* Added support for macOS.
* Updated README.

## 0.1.0

* First public version.
