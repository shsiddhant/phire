/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

abstract class BasePage<T> {
  final int pageNumber;
  final List<T> items;
  final bool hasMore;

  BasePage({
    required this.pageNumber,
    required this.items,
    required this.hasMore,
  });
}
