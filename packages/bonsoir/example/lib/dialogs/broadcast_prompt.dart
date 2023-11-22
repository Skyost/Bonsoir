import 'package:bonsoir/bonsoir.dart';
import 'package:bonsoir_example/models/app_service.dart';
import 'package:flutter/material.dart';

/// A dialog that allows to prompt for a service to broadcast on the network.
class BroadcastPromptDialog extends StatefulWidget {
  /// Creates a new Broadcast prompt dialog.
  const BroadcastPromptDialog({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _BroadcastPromptDialogState();

  /// Prompts for a service to broadcast on the network.
  static Future<BonsoirService?> prompt(BuildContext context) => showDialog(
        context: context,
        builder: (context) => const BroadcastPromptDialog(),
      );
}

/// The dialog state.
class _BroadcastPromptDialogState extends State<BroadcastPromptDialog> {
  /// Corresponds to the service name.
  TextEditingController name = TextEditingController(text: DefaultAppService.service.name);

  /// Corresponds to _<this>_._tcp.
  TextEditingController type = TextEditingController(text: DefaultAppService.type);

  /// Corresponds to _type_._<this>.
  String protocol = DefaultAppService.protocol;

  /// Corresponds to the service port.
  TextEditingController port = TextEditingController(text: DefaultAppService.port.toString());

  /// Corresponds to the service attributes.
  Map<TextEditingController, TextEditingController> attributes =
      DefaultAppService.service.attributes.map((key, value) => MapEntry(TextEditingController(text: key), TextEditingController(text: value)));

  @override
  Widget build(BuildContext context) => AlertDialog(
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24).copyWith(top: 16),
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: type,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              DropdownButtonFormField<String>(
                value: protocol,
                items: [
                  for (String protocol in ['tcp', 'udp'])
                    DropdownMenuItem<String>(
                      value: protocol,
                      child: Text(protocol.toUpperCase()),
                    ),
                ],
                onChanged: (newProtocol) {
                  if (newProtocol != null) {
                    setState(() => protocol = newProtocol);
                  }
                },
                decoration: const InputDecoration(labelText: 'Protocol'),
              ),
              TextField(
                controller: port,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
              ),
              for (MapEntry<TextEditingController, TextEditingController> entry in attributes.entries)
                Row(
                  children: [
                    Flexible(
                      flex: 10,
                      child: TextField(
                        controller: entry.key,
                        decoration: const InputDecoration(labelText: 'Key'),
                      ),
                    ),
                    const Spacer(flex: 1),
                    Flexible(
                      flex: 10,
                      child: TextField(
                        controller: entry.value,
                        decoration: const InputDecoration(labelText: 'Value'),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          attributes.remove(entry.key);
                          entry.key.dispose();
                          entry.value.dispose();
                        });
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() => attributes[TextEditingController()] = TextEditingController());
                  },
                  label: Text('Add new attribute'.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              BonsoirService(
                name: name.text,
                type: '_${type.text}._$protocol',
                port: int.tryParse(port.text) ?? DefaultAppService.service.port,
                attributes: attributes.map((key, value) => MapEntry(key.text, value.text)),
              ),
            ),
            child: Text('Ok'.toUpperCase()),
          ),
        ],
      );

  @override
  void dispose() {
    super.dispose();
    name.dispose();
    type.dispose();
    port.dispose();
    for (MapEntry<TextEditingController, TextEditingController> entry in attributes.entries) {
      entry.key.dispose();
      entry.value.dispose();
    }
  }
}
