/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'message.dart';

class ConversationPage {
  final int pageNumber;
  final List<MessageRepresentation> messages;

  ConversationPage({required this.pageNumber, required this.messages});
}
