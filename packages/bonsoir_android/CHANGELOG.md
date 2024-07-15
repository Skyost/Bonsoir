## 5.1.5

 - **FIX**: Fixed some issues triggered by the analyzer. ([db62bd06](https://github.com/Skyost/Bonsoir/commit/db62bd06b6bc4b1714d623a23b836fbac0f188b5))

## 5.1.4

 - Update a dependency to the latest release.

## 5.1.3

 - **FIX**(android): Fixed a crash with services name containing a dot. ([8caf1c75](https://github.com/Skyost/Bonsoir/commit/8caf1c752bf4da6df7946ac0820acde169b50583))

## 5.1.2

 - **FIX**(android): Fixed a crash with empty attributes values. ([87d8d60c](https://github.com/Skyost/Bonsoir/commit/87d8d60ced5e97284a91103c07594dd3fc979789))

## 5.1.1

 - Update a dependency to the latest release.

## 5.1.0

 - **FIX**(android): Fixed `Generated` implementation. ([e15cbb6a](https://github.com/Skyost/Bonsoir/commit/e15cbb6ade2d0a8f2fb8698eb016ec8105e2d89c))
 - **FEAT**: Now generating constants for platform implementations. ([3b0834d6](https://github.com/Skyost/Bonsoir/commit/3b0834d61c4b4b1a420a1b728808450fc410393d))

## 5.0.2

 - **REFACTOR**(android): Formatted some modified files. ([5c4a434a](https://github.com/Skyost/Bonsoir/commit/5c4a434a6f4636515c7c6febe713749170528b36))
 - **FIX**(android): Fixed a bug with querying TXT records on Android emulators. ([16bb251a](https://github.com/Skyost/Bonsoir/commit/16bb251a3f5fdf6dec321e3847d4d8a6d0d63a63))

## 5.0.1

 - **FIX**(android): Fixed a crash on `discovery.stop`. ([6f69efd6](https://github.com/Skyost/Bonsoir/commit/6f69efd670b87bff4f7148ef781a350203a02a97))

## 5.0.0

 - **FIX**(android): Fixed a crash occurring when a service TXT record could not be resolved. ([a9387d9d](https://github.com/Skyost/Bonsoir/commit/a9387d9d9514d2e8936ff7afd7c848615cbb8233))
 - **FIX**(android): Fixed some problems occurring with types ending with a dot. ([556aed80](https://github.com/Skyost/Bonsoir/commit/556aed80ca1e9899c49ea2c91c9fb91f1ec6aba1))

## 4.1.2

 - **FIX**: Fixed all links to the Github repository. ([9449e318](https://github.com/Skyost/Bonsoir/commit/9449e3185016d9531c4dfd8e46cc7bdbdbe563d0))

## 4.1.1

 - **REFACTOR**(android): Added an internal list that tracks already discovered services. ([7e8faac1](https://github.com/Skyost/Bonsoir/commit/7e8faac155540aa29020ebcefc3905009ce5477e))
 - **REFACTOR**: Now using `melos` to handle the `bonsoir` packages. ([9c10a0c5](https://github.com/Skyost/Bonsoir/commit/9c10a0c588e407d80f7551ebb992e9b70b05da92))
 - **FEAT**(android): Added the ability to get services attributes before resolving them. ([a1f75f91](https://github.com/Skyost/Bonsoir/commit/a1f75f91865bc374e41f50f4eebf7ce8af38dbdb))

## 4.1.0

* Added a `broadcastNameAlreadyExists` event.
* Various other fixes and improvements.

## 4.0.1

* Fixed a bug where a given broadcast was able to start more than one time.

## 4.0.0

* `service.ip` is now `service.host`.

## 3.0.0+1

* Bumped `bonsoir_platform_interface` version, it was causing an error in `bonsoir`.

## 3.0.0

* Now, services are not directly resolved by default.

## 2.2.0

* Updated SDK constraints.

## 2.1.0

* Added support of namespace property to support Android Gradle Plugin (AGP) 8. Projects with AGP < 4.2 are not supported anymore. It is highly recommended to update at least to AGP 7.0 or newer.

## 2.0.0+1

* Fixed bugs with services types.
* Fixed bugs with events id.

## 2.0.0

* Splitting the project into separate packages.
* Updated libraries.