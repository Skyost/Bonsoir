import 'package:bonsoir_example/models/app_service.dart';
import 'package:flutter/material.dart';

/// A dialog that allows to prompt for a type to discover on the network.
class DiscoveryPromptDialog extends StatefulWidget {
  /// Creates a new discovery prompt dialog.
  const DiscoveryPromptDialog({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _DiscoveryPromptDialogState();

  /// Prompts for a type to discover on the network.
  static Future<String?> prompt(BuildContext context) => showDialog(
    context: context,
    builder: (context) => const DiscoveryPromptDialog(),
  );
}

/// The dialog state.
class _DiscoveryPromptDialogState extends State<DiscoveryPromptDialog> {
  /// Corresponds to _<this>_._tcp.
  TextEditingController type = TextEditingController(text: DefaultAppService.type);

  /// Corresponds to _type_._<this>.
  String protocol = DefaultAppService.protocol;

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    content: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
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
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, '_${type.text}._$protocol'),
        child: Text('Ok'),
      ),
    ],
  );

  @override
  void dispose() {
    super.dispose();
    type.dispose();
  }
}
