bool isDifferentDay(DateTime timestamp, DateTime other) {
  return (timestamp.year != other.year) ||
      (timestamp.month != other.month) ||
      (timestamp.day != other.day);
}
