#!/bin/bash
header="org.freedesktop.Avahi."
extension=".xml"
mkdir -p dart_files;
for service in org.freedesktop.Avahi.*.xml; do
  echo "Converting file to Dart through dbus-generator: $service";
  name=${service##$header};
  name=${name%%$extension};
  snake_case_name=$(echo "$name" | sed 's/\(.\)\([A-Z]\)/\1_\2/g' | tr '[:upper:]' '[:lower:]')
  echo "Extracted name $snake_case_name";
  dart_name="$snake_case_name.dart"
  dart-dbus generate-remote-object --output="dart_files/$dart_name" --class-name="Avahi$name" $service
done;