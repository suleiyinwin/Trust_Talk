import 'package:intl/intl.dart';

String formatTime(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);
  return DateFormat('hh:mm a').format(dateTime);
}