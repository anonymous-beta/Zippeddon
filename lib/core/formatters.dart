
class Formatters {
  static String bytes(int value) {
    if (value < 1024) return '$value B';

    const units = ['KB', 'MB', 'GB', 'TB'];
    double size = value.toDouble();
    var index = -1;

    do {
      size /= 1024;
      index++;
    } while (size >= 1024 && index < units.length - 1);

    return '${size.toStringAsFixed(2)} ${units[index]}';
  }

  static String ratio(double value) {
    return '${value.toStringAsFixed(2)}x';
  }

  static String date(DateTime value) {
    final local = value.toLocal();

    String two(int number) => number.toString().padLeft(2, '0');

    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
