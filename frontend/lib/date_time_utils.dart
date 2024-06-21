import 'package:intl/intl.dart';

String formatTime(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);
  return DateFormat('hh:mm a').format(dateTime);
}

String formatDateTime(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy, hh:mm a').format(date);
}

String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy, HH').format(date);
}
