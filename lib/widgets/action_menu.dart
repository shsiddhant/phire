/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:material_ui/material_ui.dart';

class ActionMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const ActionMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class ActionMenuButton extends StatelessWidget {
  final List<ActionMenuItem> actions;
  final IconData icon;
  final String tooltip;
  final PopupMenuPosition? position;

  const ActionMenuButton({
    super.key,
    required this.actions,
    this.icon = Icons.more_vert,
    this.tooltip = 'More options',
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton<int>(
      icon: Icon(icon),
      tooltip: tooltip,
      enabled: actions.isNotEmpty,
      color: colorScheme.surfaceContainerHigh,
      position: position,
      onSelected: (int value) => actions[value].onTap(),
      itemBuilder: (context) {
        return List<PopupMenuEntry<int>>.generate(actions.length, (int index) {
          final action = actions[index];
          return PopupMenuItem<int>(
            value: index,
            child: Row(
              children: [
                Icon(action.icon),
                const SizedBox(width: 12),
                Text(action.label),
              ],
            ),
          );
        });
      },
    );
  }
}
