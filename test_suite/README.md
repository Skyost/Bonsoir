# Tests

To run type ```flutter drive --target=test_driver/app.dart``` within in the test_suite folder.

**The test has to be run on a physical device. Emulators might not work**

The test suite runs rather simple integration tests for the service discovery.  
Service annotation is not tested.

The test will explicitly look for a service of type "_bonsoirdemo._tcp".  
The service has to contain a txt-record "Bonsoir" with value "Salut" or it will fail.
  
  
## Avahi demo config:
For example a valid Avahi configuration looks like this
```
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
   <name replace-wildcards="yes">%h</name>
   <service>
      <type>_bonsoirdemo._tcp</type>
      <txt-record>Bonsoir=Salut</txt-record>
      <port>123</port>
   </service>
</service-group>
```

## iOS:
Edit test_suite/ios/Runner/Info.plist and add
```
<key>NSBonjourServices</key>
<array>
   <string>_bonsoirdemo._tcp</string>
</array>
```
The test will currently "fail" as service.type is formatted different on iOS and Android.
