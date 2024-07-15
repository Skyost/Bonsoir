## 5.1.3

 - **FIX**: Fixed some issues triggered by the analyzer. ([db62bd06](https://github.com/Skyost/Bonsoir/commit/db62bd06b6bc4b1714d623a23b836fbac0f188b5))
 - **FIX**: support unascii character for TxtRecord on darwin. ([f89e3c06](https://github.com/Skyost/Bonsoir/commit/f89e3c06dbd0b5540c2baca1fe9cccc4cb0e200e))

## 5.1.2

 - Update a dependency to the latest release.

## 5.1.1

 - Update a dependency to the latest release.

## 5.1.0

 - **REFACTOR**(darwin): Now using `Generated` on Darwin. ([46603be1](https://github.com/Skyost/Bonsoir/commit/46603be19ec128092bb074158dae1197d1f4c028))
 - **FIX**(darwin): Fixed discovery errors not being detailed on macOS. ([8b2d075b](https://github.com/Skyost/Bonsoir/commit/8b2d075b2276ce16b8fa13dd030bedb80793d0a1))
 - **FEAT**: Now generating constants for platform implementations. ([3b0834d6](https://github.com/Skyost/Bonsoir/commit/3b0834d61c4b4b1a420a1b728808450fc410393d))

## 5.0.2

 - **FIX**(darwin): Fixed discovery errors causing app crashes. ([661f1bbf](https://github.com/Skyost/Bonsoir/commit/661f1bbf7d1f3094149b516549769298ddb1dc56))
 - **FIX**(darwin,linux): Fixed `unescapeAscii` functions. ([314df41e](https://github.com/Skyost/Bonsoir/commit/314df41ef9da5e23837ea21a44b61ab9a4722e36))

## 5.0.1

 - **REFACTOR**(darwin): Formatted Swift files. ([2a7f093a](https://github.com/Skyost/Bonsoir/commit/2a7f093a3be5e6aee26d395785d3973d967d9ffc))

## 5.0.0

 - **REFACTOR**(darwin): Formatted Swift files. ([2a7f093a](https://github.com/Skyost/Bonsoir/commit/2a7f093a3be5e6aee26d395785d3973d967d9ffc))
 - **FIX**(darwin): Fixed how we handle FQDN on Darwin. ([158f0138](https://github.com/Skyost/Bonsoir/commit/158f0138e344f016875c3ee0aa2bbc7009ed46c8))

## 4.1.2

 - **FIX**: Fixed all links to the Github repository. ([9449e318](https://github.com/Skyost/Bonsoir/commit/9449e3185016d9531c4dfd8e46cc7bdbdbe563d0))

## 4.1.1

 - **REFACTOR**(darwin): Improved Darwin code quality. ([531e4bab](https://github.com/Skyost/Bonsoir/commit/531e4babd940823d998cccd57a61c4532f0ad395))
 - **REFACTOR**: Now using `melos` to handle the `bonsoir` packages. ([9c10a0c5](https://github.com/Skyost/Bonsoir/commit/9c10a0c588e407d80f7551ebb992e9b70b05da92))

## 4.1.0

* Added a `broadcastNameAlreadyExists` event.
* Various other fixes and improvements.

## 4.0.1

* Fixed wrong ports number.

## 4.0.0

* Removed the dependence on the native `NetService` library.
* `service.ip` is now `service.host`.

## 3.0.0

* Now, services are not directly resolved by default.

## 2.2.0+1

* Fixed a compilation error in the Darwin package (thanks [Nico Spencer](https://github.com/nicholasspencer)).

## 2.2.0

* Updated SDK constraints.

## 2.0.0+3

* Fixed a compilation error in the Darwin package.

## 2.0.0+2

* Fixed bugs with services types.
* Fixed bugs with events id.

## 2.0.0+1

* Fixed a problem with the README file.

## 2.0.0

* Splitting the project into separate packages.
* Updated libraries.