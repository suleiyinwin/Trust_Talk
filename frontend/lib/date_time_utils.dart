import 'package:intl/intl.dart';

String formatTime(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);
  return DateFormat('hh:mm a').format(dateTime);
}

String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd MMM, HH:mm a').format(date);
  }