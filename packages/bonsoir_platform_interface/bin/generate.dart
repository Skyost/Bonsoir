import 'dart:io';

import 'package:bonsoir_platform_interface/src/log_messages.dart';

// ignore_for_file: avoid_print

/// Headers in all generated files.
const String header = 'Generated file that contains some variables used by the platform channel.';

/// Header of broadcast messages.
const String broadcastMessagesHeader = 'Contains the broadcast messages.';

/// Header of discovery messages.
const String discoveryMessagesHeader = 'Contains the discovery messages.';

/// Generates log messages for all implementations.
/// Usage : `dart run bonsoir_platform_interface:generate`.
void main() {
  exitCode = 0;

  for (Implementation implementation in Implementation.values) {
    implementation.generateMessages();
  }
}

/// Generates the Android messages.
void generateAndroidMessages([String package = 'fr/skyost/bonsoir']) {
  String fileTemplate = '''package fr.skyost.bonsoir

/*
 * $header
 */ 
class Generated {
    companion object {
        /**
         * $broadcastMessagesHeader
         */
        public final var broadcastMessages: Map<String, String> = mapOf({broadcastEntries})

{broadcastVariables}

        /**
         * $discoveryMessagesHeader
         */
        public final var discoveryMessages: Map<String, String> = mapOf({discoveryEntries})

{discoveryVariables}
    }
}
''';
  generateMessages(
    file: '../${Implementation.android.packageName}/android/src/main/kotlin/$package/Generated.kt',
    generateMapEntry: (entry) => '"${entry.key}" to "${entry.value}"',
    generateVariable: (entry) => '''
        /**
         * ${entry.key}
         */
         public final const val ${entry.key} = "${entry.key}";
''',
    fileTemplate: fileTemplate,
  );
}

/// Generates the Darwin messages.
void generateDarwinMessages() {
  String fileTemplate = '''/// $header

class Generated {
  /// $broadcastMessagesHeader
  static let broadcastMessages: [String: String] = [{broadcastEntries}]

{broadcastVariables}

  /// $discoveryMessagesHeader
  static let discoveryMessages: [String: String] = [{discoveryEntries}]

{discoveryVariables}
}
''';
  generateMessages(
    file: '../${Implementation.darwin.packageName}/darwin/Classes/Generated.swift',
    generateMapEntry: (entry) => '"${entry.key}": "${entry.value}"',
    generateVariable: (entry) => '''
  /// ${entry.key}
  static let ${entry.key}: String = "${entry.key}"
''',
    fileTemplate: fileTemplate,
  );
}

/// Generates the Windows messages.
void generateWindowsMessages() {
  String headerTemplate = '''// $header

#pragma once

#include <map>
#include <string>

namespace bonsoir_windows {
  class Generated {
    public:
      // $broadcastMessagesHeader
      static const std::map<std::string, std::string> broadcastMessages;

{broadcastVariables}

      // $discoveryMessagesHeader
      static const std::map<std::string, std::string> discoveryMessages;

{discoveryVariables}
  };
}
''';
  generateMessages(
    file: '../${Implementation.windows.packageName}/windows/generated.h',
    generateMapEntry: (entry) => '',
    generateVariable: (entry) => '''
      // ${entry.key}
      static const std::string ${entry.key};
''',
    fileTemplate: headerTemplate,
  );

  String fileTemplate = '''// $header

#pragma once

#include "generated.h"

namespace bonsoir_windows {
  const std::map<std::string, std::string> Generated::broadcastMessages = { {broadcastEntries} };

{broadcastVariables}

  const std::map<std::string, std::string> Generated::discoveryMessages = { {discoveryEntries} };

{discoveryVariables}
}
''';
  generateMessages(
    file: '../${Implementation.windows.packageName}/windows/generated.cpp',
    generateMapEntry: (entry) => '{ "${entry.key}", "${entry.value}" }',
    generateVariable: (entry) => '  const std::string Generated::${entry.key} = "${entry.key}";\n',
    fileTemplate: fileTemplate,
  );
}

/// Generates the messages thanks to [generateMapEntry] and writes the contents into a [file] thanks to the provided [fileTemplate].
void generateMessages({
  required String file,
  required String Function(MapEntry<String, String>) generateMapEntry,
  String entrySeparator = ', ',
  required String Function(MapEntry<String, String>) generateVariable,
  required String fileTemplate,
}) {
  print('Generating "$file"...');
  String content = fileTemplate;
  for ((String, Map<String, String>) messages in [
    ('broadcast', BonsoirPlatformInterfaceLogMessages.broadcastMessages),
    ('discovery', BonsoirPlatformInterfaceLogMessages.discoveryMessages),
  ]) {
    String generatedEntries = '';
    String generatedVariables = '';
    for (MapEntry<String, String> entry in messages.$2.entries) {
      generatedEntries += (generateMapEntry(entry) + entrySeparator);
      generatedVariables += generateVariable(entry);
    }
    generatedEntries = generatedEntries.substring(0, generatedEntries.length - entrySeparator.length);
    content = content.replaceAll('{${messages.$1}Entries}', generatedEntries).replaceAll('{${messages.$1}Variables}', generatedVariables);
  }
  File(file)
    ..createSync(recursive: true)
    ..writeAsStringSync(content);
  print('Done !');
}

/// Contains the list of implementations.
enum Implementation {
  /// The Android implementation.
  android(generateMessages: generateAndroidMessages),

  /// The Darwin implementation.
  darwin(generateMessages: generateDarwinMessages),

  /// The Windows implementation.
  windows(generateMessages: generateWindowsMessages);

  /// The function that generates the Bonsoir messages.
  final Function() generateMessages;

  /// Creates a new implementation instance.
  const Implementation({
    required this.generateMessages,
  });

  /// Returns the Bonsoir package name.
  String get packageName {
    String name = toString().split('.').last;
    return 'bonsoir_$name';
  }
}
