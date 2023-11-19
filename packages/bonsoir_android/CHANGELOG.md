## 4.1.1

 - **REFACTOR**(android): Added an internal list that tracks already discovered services. ([7e8faac1](https://github.com/Skyost/Bonsoir/commit/7e8faac155540aa29020ebcefc3905009ce5477e))
 - **REFACTOR**: Now using `melos` to handle the `bonsoir` packages. ([9c10a0c5](https://github.com/Skyost/Bonsoir/commit/9c10a0c588e407d80f7551ebb992e9b70b05da92))
 - **FEAT**(android): Added the ability to get services attributes before resolving them. ([a1f75f91](https://github.com/Skyost/Bonsoir/commit/a1f75f91865bc374e41f50f4eebf7ce8af38dbdb))

## [4.1.0]

* Added a `broadcastNameAlreadyExists` event.
* Various other fixes and improvements.

## [4.0.1]

* Fixed a bug where a given broadcast was able to start more than one time.

## [4.0.0]

* `service.ip` is now `service.host`.

## [3.0.0+1]

* Bumped `bonsoir_platform_interface` version, it was causing an error in `bonsoir`.

## [3.0.0]

* Now, services are not directly resolved by default.

## [2.2.0]

* Updated SDK constraints.

## [2.1.0]

* Added support of namespace property to support Android Gradle Plugin (AGP) 8. Projects with AGP < 4.2 are not supported anymore. It is highly recommended to update at least to AGP 7.0 or newer.

## [2.0.0+1]

* Fixed bugs with services types.
* Fixed bugs with events id.

## [2.0.0]

* Splitting the project into separate packages.
* Updated libraries.