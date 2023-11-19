## 4.1.1

 - **REFACTOR**: Now using `melos` to handle the `bonsoir` packages. ([9c10a0c5](https://github.com/Skyost/Bonsoir/commit/9c10a0c588e407d80f7551ebb992e9b70b05da92))
 - **FIX**(linux): Fixed a bug occurring with some services name on Linux. ([1464df2c](https://github.com/Skyost/Bonsoir/commit/1464df2c359b406a518e1e929ffd5bda3aca33f8))
 - **FIX**(linux): When resolving a service's TXT record, Bonsoir triggers `discoveryServiceLost` BEFORE updating the attributes map. ([e480faa1](https://github.com/Skyost/Bonsoir/commit/e480faa1da20195e5a6c55da967f32fbc96f07c6))

## 4.1.0

* First implementation of Bonsoir for Linux.
