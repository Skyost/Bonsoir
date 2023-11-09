## [4.0.0]

* Removed the dependence on the native `NetService` library.
* `service.ip` is now `service.host`.

## [3.0.0+1] - 2023-08-06

* Fixed the README examples.
* Fixed every package changelog date.

## [3.0.0] - 2023-08-06

* Now, services are not directly resolved by default.

## [2.2.0+1] - 2023-05-13

* Fixed the badges links in the README.

## [2.2.0] - 2023-05-10

* Updated SDK constraints.

## [2.1.0] - 2023-05-10

* Added support of namespace property to support Android Gradle Plugin (AGP) 8. Projects with AGP < 4.2 are not supported anymore. It is highly recommended to update at least to AGP 7.0 or newer.

## [2.0.0] - 2022-07-18

* Splitting the project into separate packages.
* Updated libraries.

## [1.0.1+2] - 2021-11-06

* Fixed a build error on iOS.

## [1.0.1+1] - 2021-10-28

* Fixed a build error on Android.

## [1.0.1] - 2021-10-28

* Now checks if listener is registered in `NSDService` (thanks [victorkifer](https://github.com/victorkifer)).
* Fixed attributes value is covered to `Optional()` on iOS (thanks [RyoheiTomiyama](https://github.com/RyoheiTomiyama)).
* Fixed Bonjour Service Decoder (thanks [woody-LWD](https://github.com/woody-LWD)).
* Added null check around getAttributes result. (thanks [kultivator-consulting](https://github.com/kultivator-consulting)).
* Fixed a null pointer exception in `SuccessObject`.

## [1.0.0+1] - 2021-04-15

* Updated README (thanks [lsegal](https://github.com/lsegal)).

## [1.0.0] - 2021-03-17

* Transitioned to federated plugin (thanks [Piero512](https://github.com/Piero512)).

## [0.1.3+2] - 2021-01-04

* Fixed a problem with symlinks on macOS and iOS.

## [0.1.3+1] - 2021-01-02

* Ran `dartfmt` (in order to improve pub.dev score 🙄).

## [0.1.3] - 2021-01-02

* Added support for services attributes.
* Added tests for service discovery (thanks [DominikStarke](https://github.com/DominikStarke)).

## [0.1.2+2] - 2020-08-18

* Fixed symlinks error for iOS and macOS.
* improved an error message.

## [0.1.2+1] - 2020-08-12

* Formatted the code using `dartfmt`.
* Updated README.

## [0.1.2] - 2020-08-12

* Fixed a bug that was occurring with Pixel devices.
* Improved service resolution.
* Added a link into the README for using the library on iOS 14.

## [0.1.1] - 2020-08-07

* Added support for macOS.
* Updated README.

## [0.1.0] - 2020-08-06

* First public version.
