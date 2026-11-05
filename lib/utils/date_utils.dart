/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

bool isDifferentDay(DateTime timestamp, DateTime other) {
  return (timestamp.year != other.year) ||
      (timestamp.month != other.month) ||
      (timestamp.day != other.day);
}
