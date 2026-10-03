import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/errors/failure.dart';
import 'package:tenant_tracker/core/utils/failure_message.dart';
import 'package:tenant_tracker/core/widgets/big_button.dart';
import 'package:tenant_tracker/core/widgets/form_parts.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

/// Asks for a group name: used to add a group (Home) and to rename one (group
/// screen). Pops with the saved name, or null when cancelled. A failed save
/// (an empty or taken name) is shown inside the dialog.
class GroupNameDialog extends StatefulWidget {
  final String title;
  final String initialName;

  /// Saves the name; returns the failure, or null when it worked.
  final Future<Failure?> Function(String name) onSave;

  const GroupNameDialog({
    super.key,
    required this.title,
    required this.onSave,
    this.initialName = '',
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required Future<Failure?> Function(String name) onSave,
    String initialName = '',
  }) => showDialog<String>(
    context: context,
    builder: (_) => GroupNameDialog(
      title: title,
      initialName: initialName,
      onSave: onSave,
    ),
  );

  @override
  State<GroupNameDialog> createState() => _GroupNameDialogState();
}

class _GroupNameDialogState extends State<GroupNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );
  Failure? _failure;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return; // blocking rule: ignore re-entry
    final name = _controller.text.trim();
    setState(() => _saving = true);
    final failure = await widget.onSave(name);
    if (!mounted) return;
    if (failure == null) {
      Navigator.pop(context, name);
    } else {
      setState(() {
        _saving = false;
        _failure = failure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormLabel(label: l.fGroupName, hint: l.fGroupNameHint),
          TextField(
            key: const Key('groupNameField'),
            controller: _controller,
            enabled: !_saving,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          if (_failure != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                failureMessage(l, _failure!),
                style: const TextStyle(color: Color(0xFFB3261E)),
              ),
            ),
        ],
      ),
      actions: [
        BigButton(
          label: l.cancel,
          kind: BigButtonKind.secondary,
          onPressed: _saving ? null : () => Navigator.pop(context),
        ),
        BigButton(label: l.save, busy: _saving, onPressed: _save),
      ],
    );
  }
}
