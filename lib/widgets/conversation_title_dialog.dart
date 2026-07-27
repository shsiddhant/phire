import 'package:flutter/material.dart';

import '../exceptions/conversation_already_exists.dart';

class ConversationTitleDialog extends StatefulWidget {
  final String title;
  final String defaultConversationTitle;
  final String actionName;
  final Future<void> Function(String title) onSubmit;
  final void Function(Object error)? onError;

  const ConversationTitleDialog({
    super.key,
    required this.title,
    required this.defaultConversationTitle,
    required this.actionName,
    required this.onSubmit,
    this.onError,
  });

  @override
  State<StatefulWidget> createState() => _ConversationTitleDialogState();
}

class _ConversationTitleDialogState extends State<ConversationTitleDialog> {
  late final TextEditingController _titleController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.defaultConversationTitle,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length <= 2) {
      return 'Minimum characters: 3';
    }
    if (value.length > 50) {
      return 'Maximum characters: 50';
    }
    return null;
  }

  void _onChanged(String value) {
    // Nullify forceErrorText if the input changed.
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _submit() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      await widget.onSubmit(_titleController.text.trim());
      if (mounted) {
        Navigator.pop(context);
      }
    } on ConversationAlreadyExistsException {
      setState(() {
        _errorMessage = 'Title already exists';
      });
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      widget.onError?.call(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          forceErrorText: _errorMessage,
          controller: _titleController,
          autofocus: true,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Conversation Title',
            border: OutlineInputBorder(),
          ),
          validator: _validator,
          onChanged: _onChanged,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: Text(widget.actionName)),
      ],
    );
  }
}
