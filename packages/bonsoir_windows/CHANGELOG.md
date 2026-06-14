## 7.1.1

 - **FIX**(windows): Clean up resolving services with a mutex to prevent race conditions. ([53ace1e1](https://github.com/Skyost/Bonsoir/commit/53ace1e1ecef5eaa2b719eefa8599d2f61f28c36))

## 7.1.0

 - **FEAT**: Prioritizing host addresses over hostname during service broadcast. ([ff6b78d3](https://github.com/Skyost/Bonsoir/commit/ff6b78d352e2af022cc13635e35ba296e9f40ec7))

## 7.0.0

> Note: This release has breaking changes.

 - **FIX**(windows): Implemented safe asynchronous disposal for broadcast and discovery. ([97555473](https://github.com/Skyost/Bonsoir/commit/97555473ba18546c37fa41cf23ce4ec0370b0aa9))
 - **FIX**(windows): Fixed a compilation error on Windows. ([21d3e827](https://github.com/Skyost/Bonsoir/commit/21d3e827af96614c9fd3ded8ceddf442d68a5e83))
 - **FEAT**: Support multiple host addresses for services. ([abb9d22f](https://github.com/Skyost/Bonsoir/commit/abb9d22fd512e637482c958e46938af2af3bde5d))
 - **FEAT**: Added `hostname` property to `BonsoirService`. ([8e43270b](https://github.com/Skyost/Bonsoir/commit/8e43270b862bef8527da9e436bfeed8d333cda35))
 - **BREAKING** **REFACTOR**: Renamed `host` into `hostAddress` in remaining implementations. ([45776c9b](https://github.com/Skyost/Bonsoir/commit/45776c9bda71bd6c9002ee31ee5e63d3980df097))
 - **BREAKING** **FEAT**: Added mDNS hostname support check and renamed service host field. ([b374678b](https://github.com/Skyost/Bonsoir/commit/b374678bdc1578cf7bbfae1055251cff5a3a24c3))

## 6.0.3

 - Update a dependency to the latest release.

## 6.0.2

 - **FIX**: Properly clean up service resolve queries on Windows. ([19c47050](https://github.com/Skyost/Bonsoir/commit/19c470503e64fcd971a276fa02c267a7eecdd7cc))

## 6.0.1

 - **REFACTOR**: Finished renaming branch `master` into `main`. ([5c832e56](https://github.com/Skyost/Bonsoir/commit/5c832e56273eb90c19b502d1c53af71e1e9e085a))

## 6.0.0

> Note: This release has breaking changes.

 - **FEAT**(windows): Implemented `BonsoirDiscoveryServiceUpdatedEvent` on Windows. ([8cb0b1dd](https://github.com/Skyost/Bonsoir/commit/8cb0b1ddc75bdaf0a56c9be60fe9c819ac591d26))
 - **FEAT**: Added a `BonsoirDiscoveryServiceUpdatedEvent` event. ([75d3ee9d](https://github.com/Skyost/Bonsoir/commit/75d3ee9dbb49b7e1ea7167a4479a862c9184a931))
 - **BREAKING** **REFACTOR**: Rewrote some parts of the project. ([e984f552](https://github.com/Skyost/Bonsoir/commit/e984f552b301de73b88cc577175b426de0618143))

## 5.1.5

- **FIX**(windows): Fixed a crash when DNS client is stopping on Windows. ([5941f71](https://github.com/Skyost/Bonsoir/commit/5941f71cc275fe86b23f309e1c0e1dcfa6dd4d38))
 - Update a dependency to the latest release.

## 5.1.4

 - Update a dependency to the latest release.

## 5.1.3

 - **FIX**(windows): Fixed broadcast hostnames not being used. ([57c8c9a6](https://github.com/Skyost/Bonsoir/commit/57c8c9a6e8d5412a2f6a62b88583a1150689473d))

## 5.1.2

 - Update a dependency to the latest release.

## 5.1.1

 - **FIX**(windows): Fixed some thread safety problems. ([28ff2a44](https://github.com/Skyost/Bonsoir/commit/28ff2a448333e382f5d3672b6f851246152be8e3))

## 5.1.0

 - **FEAT**: Now generating constants for platform implementations. ([3b0834d6](https://github.com/Skyost/Bonsoir/commit/3b0834d61c4b4b1a420a1b728808450fc410393d))

## 5.0.1

 - **FIX**(windows): Fixed a bug occurring when listening to the `eventStream` AFTER starting the action. ([a4e788d7](https://github.com/Skyost/Bonsoir/commit/a4e788d7b71dd256b336b9edd5804892b48d4169))

## 5.0.0

 - **FIX**(windows): Fixed how we handle FQDN and TXT records on Windows. ([1e7d5451](https://github.com/Skyost/Bonsoir/commit/1e7d545197f2806d46d1923e5987aef64437fc19))

## 4.1.2

 - **FIX**: Fixed all links to the Github repository. ([9449e318](https://github.com/Skyost/Bonsoir/commit/9449e3185016d9531c4dfd8e46cc7bdbdbe563d0))

## 4.1.1

 - **REFACTOR**: Now using `melos` to handle the `bonsoir` packages. ([9c10a0c5](https://github.com/Skyost/Bonsoir/commit/9c10a0c588e407d80f7551ebb992e9b70b05da92))
 - **FIX**(windows): Fixed a `discovery.stop()` bug on Windows. ([6a6284cc](https://github.com/Skyost/Bonsoir/commit/6a6284cca0c5e6d9235a02108f2e48b5ceefb2d8))

## 4.1.0

* First implementation of Bonsoir for Windows.
