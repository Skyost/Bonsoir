## 5.1.3

 - Update a dependency to the latest release.

## 5.1.2

 - Update a dependency to the latest release.

## 5.1.1

 - Update a dependency to the latest release.

## 5.1.0

 - **FEAT**: Now generating constants for platform implementations. ([3b0834d6](https://github.com/Skyost/Bonsoir/commit/3b0834d61c4b4b1a420a1b728808450fc410393d))

## 5.0.1

 - **FIX**(darwin,linux): Fixed `unescapeAscii` functions. ([314df41e](https://github.com/Skyost/Bonsoir/commit/314df41ef9da5e23837ea21a44b61ab9a4722e36))

## 5.0.0

> Note: This release has breaking changes.

 - **FIX**(linux): Parsing TXT record now closely follow RFC 6763. ([f2e7d5b5](https://github.com/Skyost/Bonsoir/commit/f2e7d5b56ed0b418d3102bc3fbdf09162988f51c))
 - **FIX**(linux): Fixed how we handle FQDN and TXT records on Linux. ([f1e4fde5](https://github.com/Skyost/Bonsoir/commit/f1e4fde5ad6a5c9428dae488d77ed6c278cb5246))
 - **BREAKING** **REFACTOR**(linux): Now following Dart's convention regarding the `src` folder. ([80216578](https://github.com/Skyost/Bonsoir/commit/80216578502650e6a24535d257d42dc3aa04a864))

## 4.1.2

 - **FIX**: Fixed all links to the Github repository. ([9449e318](https://github.com/Skyost/Bonsoir/commit/9449e3185016d9531c4dfd8e46cc7bdbdbe563d0))

## 4.1.1

 - **REFACTOR**: Now using `melos` to handle the `bonsoir` packages. ([9c10a0c5](https://github.com/Skyost/Bonsoir/commit/9c10a0c588e407d80f7551ebb992e9b70b05da92))
 - **FIX**(linux): Fixed a bug occurring with some services name on Linux. ([1464df2c](https://github.com/Skyost/Bonsoir/commit/1464df2c359b406a518e1e929ffd5bda3aca33f8))
 - **FIX**(linux): When resolving a service's TXT record, Bonsoir triggers `discoveryServiceLost` BEFORE updating the attributes map. ([e480faa1](https://github.com/Skyost/Bonsoir/commit/e480faa1da20195e5a6c55da967f32fbc96f07c6))

## 4.1.0

* First implementation of Bonsoir for Linux.
