## 5.1.10

 - **FIX**: Fixed some issues triggered by the analyzer. ([db62bd06](https://github.com/Skyost/Bonsoir/commit/db62bd06b6bc4b1714d623a23b836fbac0f188b5))

## 5.1.9

 - **FIX**(bonsoir): "Fixed" some errors that were occurring while trying to discover an invalid type. ([d24cc1d6](https://github.com/Skyost/Bonsoir/commit/d24cc1d6ec92424184559f970cae054efb845043))

## 5.1.8

 - Update a dependency to the latest release.

## 5.1.7

 - Update a dependency to the latest release.

## 5.1.6

 - Update a dependency to the latest release.

## 5.1.5

 - Update a dependency to the latest release.

## 5.1.4

 - **REFACTOR**(bonsoir): Ran `dart format`. ([41360b61](https://github.com/Skyost/Bonsoir/commit/41360b61326e134e44f391cc70725cb8e1b4f6e9))

## 5.1.3

 - Update a dependency to the latest release.

## 5.1.2

 - Update a dependency to the latest release.

## 5.1.1

 - **REFACTOR**: Removed `AutoStopBonsoirAction`. ([441063ae](https://github.com/Skyost/Bonsoir/commit/441063ae5ee2a4bd9b3f8779ab05fd6f9b3d83bd))
 - **FEAT**: Now generating constants for platform implementations. ([3b0834d6](https://github.com/Skyost/Bonsoir/commit/3b0834d61c4b4b1a420a1b728808450fc410393d))

## 5.1.0

 - **REFACTOR**(docs): Removed trailing slashes. ([34c349bd](https://github.com/Skyost/Bonsoir/commit/34c349bdf5913828dfb82cfa8322df4ac459b435))
 - **FIX**(bonsoir): Now checking if discovery types are valid. ([e67f6984](https://github.com/Skyost/Bonsoir/commit/e67f6984f537be976c979d8c56ee3f620cf8dce9))
 - **FEAT**(example): Now displaying discoveries with empty service lists. ([5b6952b2](https://github.com/Skyost/Bonsoir/commit/5b6952b26c54af550bfbbc67a1932b622dd292f5))

## 5.0.3

 - **FIX**(example): Fixed some text fields not being disposed. ([612785d1](https://github.com/Skyost/Bonsoir/commit/612785d160e7d119d96e3c821221cede88a20f3e))

## 5.0.2

 - Update a dependency to the latest release.

## 5.0.1

 - Update a dependency to the latest release.

## 5.0.0

 - Bumped dependencies to `5.0.0`.

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
