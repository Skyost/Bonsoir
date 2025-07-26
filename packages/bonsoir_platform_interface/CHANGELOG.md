## 6.0.1

 - **REFACTOR**: Finished renaming branch `master` into `main`. ([5c832e56](https://github.com/Skyost/Bonsoir/commit/5c832e56273eb90c19b502d1c53af71e1e9e085a))

## 6.0.0

> Note: This release has breaking changes.

 - **REFACTOR**: Renamed `ready` into `initialize()` and moved the meta query constant in a separate file. ([cc4d0e27](https://github.com/Skyost/Bonsoir/commit/cc4d0e27122c6c2af5ff188f6b8bac6b2e709bf0))
 - **FEAT**: Added a `BonsoirDiscoveryServiceUpdatedEvent` event. ([75d3ee9d](https://github.com/Skyost/Bonsoir/commit/75d3ee9dbb49b7e1ea7167a4479a862c9184a931))
 - **BREAKING** **REFACTOR**: Rewrote some parts of the project. ([e984f552](https://github.com/Skyost/Bonsoir/commit/e984f552b301de73b88cc577175b426de0618143))

## 5.1.3

 - **FIX**: Fixed some issues triggered by the analyzer. ([db62bd06](https://github.com/Skyost/Bonsoir/commit/db62bd06b6bc4b1714d623a23b836fbac0f188b5))

## 5.1.2

- **CHORE**(platform_interface): Added a warning for services name ending with a dot. ([0a30efc2](https://github.com/Skyost/Bonsoir/commit/0a30efc2144428641aa0c8d97ae180e6c76249cb))

## 5.1.1

- **CHORE**(platform_interface): Attributes keys are no longer limited to 9 characters by default. ([421fe695](https://github.com/Skyost/Bonsoir/commit/421fe6959ed0a1039dffc19ede8246416b16a2f0))

## 5.1.0

 - **REFACTOR**: Removed `AutoStopBonsoirAction`. ([441063ae](https://github.com/Skyost/Bonsoir/commit/441063ae5ee2a4bd9b3f8779ab05fd6f9b3d83bd))
 - **FEAT**: Now generating constants for platform implementations. ([3b0834d6](https://github.com/Skyost/Bonsoir/commit/3b0834d61c4b4b1a420a1b728808450fc410393d))

## 5.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: Added a normalizer to conform to RFC 6335 and RFC 6763. ([f8c0487f](https://github.com/Skyost/Bonsoir/commit/f8c0487fee440eab02013e33ba5ba5e0daccc918))

## 4.1.2

 - **FIX**: Fixed all links to the Github repository. ([9449e318](https://github.com/Skyost/Bonsoir/commit/9449e3185016d9531c4dfd8e46cc7bdbdbe563d0))

## 4.1.1

 - **REFACTOR**: Now using `melos` to handle the `bonsoir` packages. ([9c10a0c5](https://github.com/Skyost/Bonsoir/commit/9c10a0c588e407d80f7551ebb992e9b70b05da92))

## 4.1.0

* First implementation of Bonsoir for Windows.
* First implementation of Bonsoir for Linux.
* Added a `broadcastNameAlreadyExists` event.
* Various other fixes and improvements.

## 4.0.0

* `service.ip` is now `service.host`.

## 3.0.0

* Added a `ServiceResolver` class.

## 2.2.0

* Updated SDK constraints.

## 2.0.0+1

* Fixed bugs with services types.
* Fixed bugs with events id.

## 2.0.0

* Splitting the project into separate packages.
* Updated libraries.

## 1.1.0+1

* Updated libraries.

## 1.1.0

* Did some refactoring (according to [#10](https://github.com/Skyost/Bonsoir/issues/10)).

## 1.0.0+2

* Removed the Bonsoir dependency.

## 1.0.0+1

* Less constraints for Bonsoir.

## 1.0.0

* Initial implementation of this platform interface.
