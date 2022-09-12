import 'package:flutter/material.dart';

class AddSstEventDialog extends StatefulWidget {
  const AddSstEventDialog({Key? key}) : super(key: key);

  @override
  State<AddSstEventDialog> createState() => _AddSstEventDialogState();
}

class _AddSstEventDialogState extends State<AddSstEventDialog> {
  final _formKey = GlobalKey<FormState>();

  SstEventType? _eventType;

  void _showInvalidFieldsSnakBar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Assurez vous que tous les champs soient valides")));
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) {
      _showInvalidFieldsSnakBar();
      return;
    }

    _formKey.currentState!.save();
    Navigator.pop(context, _eventType);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Signaler un évènement"),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            RadioListTile(
              title: const Text(
                  "Un accident du travail (il peut s’agir d’une blessure mineure)"),
              value: SstEventType.pastWounds,
              groupValue: _eventType,
              onChanged: (value) =>
                  setState(() => _eventType = SstEventType.pastWounds),
            ),
            RadioListTile(
              title: const Text(
                  "Un incident en stage (ex. agression verbale, harcèlement)"),
              value: SstEventType.pastIncidents,
              groupValue: _eventType,
              onChanged: (value) =>
                  setState(() => _eventType = SstEventType.pastIncidents),
            ),
            RadioListTile(
              title: const Text("Une situation dangereuse"),
              value: SstEventType.dangerousSituations,
              groupValue: _eventType,
              onChanged: (value) =>
                  setState(() => _eventType = SstEventType.dangerousSituations),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _onCancel,
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          child: const Text("Confirmer"),
        ),
      ],
    );
  }
}

enum SstEventType { pastWounds, pastIncidents, dangerousSituations }
