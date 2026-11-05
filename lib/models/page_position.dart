/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

class PagePosition {
  final int pageIndex;
  final int itemIndex;

  const PagePosition._({required this.pageIndex, required this.itemIndex});

  factory PagePosition.fromOffset({
    required int offset,
    required int pageSize,
  }) {
    assert(offset >= 0, 'offset must be non-negative ($offset)');
    assert(pageSize > 0, 'pageSize must be greater than zero ($pageSize)');

    return PagePosition._(
      pageIndex: offset ~/ pageSize,
      itemIndex: offset % pageSize,
    );
  }
}
