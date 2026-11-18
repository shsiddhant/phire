/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:material_ui/material_ui.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required Future<void> Function() onConfirm,
  String confirmActionName = 'Yes',
  String Function(Object error)? errorMessageBuilder,
}) async {
  final bool? isConfirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => _ConfirmDialog(
      title: title,
      message: message,
      onConfirm: onConfirm,
      confirmActionName: confirmActionName,
      errorMessageBuilder: errorMessageBuilder,
    ),
    barrierDismissible: false,
  );
  return isConfirmed ?? false;
}

class _ConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmActionName;
  final Future<void> Function() onConfirm;
  final String Function(Object error)? errorMessageBuilder;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.confirmActionName,
    this.errorMessageBuilder,
  });

  @override
  State<StatefulWidget> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _confirm() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm();

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _errorMessage =
            widget.errorMessageBuilder?.call(e) ??
            'Unable to complete this action.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: AlertDialog(
        title: Text(widget.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            if (_isSubmitting) ...[
              const SizedBox(height: 20),
              const LinearProgressIndicator(),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _isSubmitting ? null : _confirm,
            child: Text(widget.confirmActionName),
          ),
        ],
      ),
    );
  }
}
