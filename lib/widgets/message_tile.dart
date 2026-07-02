import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageTile extends StatelessWidget {
  final MessageRepresentation messageRepr;

  const MessageTile({super.key, required this.messageRepr});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(top: 1.0, bottom: 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (messageRepr.isFirstOfDay) _DayMarker(messageRepr.dayMarker),
          if (messageRepr.showSenderHeader)
            _SenderHeader(sender: messageRepr.senderName),
          _MessageRow(
            formattedTime: messageRepr.formattedTime,
            messageText: messageRepr.messageText,
          ),
        ],
      ),
    );
  }
}

class _DayMarker extends StatelessWidget {
  final String? dayMarker;

  const _DayMarker(this.dayMarker);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          dayMarker!,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          textScaler: TextScaler.linear(1.1),
        ),
      ),
    );
  }
}

class _SenderHeader extends StatelessWidget {
  final String sender;

  const _SenderHeader({required this.sender});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(top: 4.0),
      child: Text(
        sender,
        textScaler: TextScaler.linear(1),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  final String formattedTime;
  final String messageText;

  const _MessageRow({required this.formattedTime, required this.messageText});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            formattedTime,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(200),
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            messageText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
