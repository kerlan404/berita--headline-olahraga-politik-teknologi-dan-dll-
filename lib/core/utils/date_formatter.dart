import 'package:intl/intl.dart';

class DateFormatter {
  static String getRelativeTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    
    try {
      final DateTime parsedDate = DateTime.parse(dateStr).toLocal();
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(parsedDate);

      if (difference.inSeconds < 60) {
        return 'baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else {
        return DateFormat('dd MMM yyyy').format(parsedDate);
      }
    } catch (e) {
      return dateStr;
    }
  }
}
