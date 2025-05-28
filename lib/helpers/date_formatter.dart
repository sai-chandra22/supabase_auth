import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ntp/flutter_ntp.dart';

/// “OCT 28”
String formatDateMMMDD(String dateString) {
  final dt = _parseCustomDate(dateString);
  return DateFormat('MMM d').format(dt).toUpperCase();
}

/// Formats “8/1/2025, 5:00:00 PM” → “5:00 PM”
String formatMeetingTime(String dateString) {
  final dt = _parseCustomDate(dateString);
  // “h:mm a” → no leading zero on hour + minutes + AM/PM
  return DateFormat('h:mm a').format(dt);
}

/// Formats “8/1/2025, 5:00:00 PM” → “AUGUST 01”
String formatDateFullMonthDDWithZero(String dateString) {
  final dt = _parseCustomDate(dateString);
  // “MMMM dd” → full month name + zero-padded day
  return DateFormat('MMMM dd').format(dt).toUpperCase();
}

DateTime _parseCustomDate(String dateString) {
  return DateFormat('M/d/yyyy, h:mm:ss a').parse(dateString);
}

/// “OCT 28, 2024”
String formatDateMMMDDYYYY(String dateString) {
  final dt = _parseCustomDate(dateString);
  return DateFormat('MMM dd, yyyy').format(dt).toUpperCase();
}

/// “WED 15”
String formatDateDayDD(String dateString) {
  final dt = _parseCustomDate(dateString);
  return DateFormat('EEE dd').format(dt).toUpperCase();
}

/// “WED 15” but with zero-pad day: “WED 05”
String formatDateDayDDWithZero(String dateString) {
  final dt = _parseCustomDate(dateString);
  final weekday = DateFormat('EEE').format(dt).toUpperCase();
  final day = dt.day.toString().padLeft(2, '0');
  return '$weekday $day';
}

/// “OCTOBER 28, 2024”
String formatDateFullMonthDDYYYY(String dateString) {
  final dt = _parseCustomDate(dateString);
  return DateFormat('MMMM dd, yyyy').format(dt).toUpperCase();
}

String formatDateMMMDDWithPerfectDateString(String dateString) {
  // Parse the date string into a DateTime object
  DateTime date = DateTime.parse(dateString);

  // Format the date as "MMM d" (e.g., "OCT 28")
  String formattedDate = DateFormat('MMM d').format(date).toUpperCase();

  return formattedDate;
}

String formatDateFullMonthDDWithZeroWithPerfectDateString(String dateString) {
  // Parse the date string into a DateTime object
  DateTime date = DateTime.parse(dateString);

  // Get the full month name
  String month = DateFormat('MMMM').format(date).toUpperCase();

  // Format the day with leading zero for single digits
  String day = date.day.toString().padLeft(2, '0');

  // Combine month and day with leading zero
  String formattedDate = '$month $day';

  return formattedDate;
}

String formatDateMMMDDYYYYWithPerfectDateString(String dateString) {
  // Parse the date string into a DateTime object
  DateTime date = DateTime.parse(dateString);

  // Format the date as "MMM dd, yyyy" (e.g., "OCT 28, 2024")
  String formattedDate = DateFormat('MMM dd, yyyy').format(date).toUpperCase();

  return formattedDate;
}

String formatDateDayDDWithPerfectDateString(String dateString) {
  // Parse the date string into a DateTime object
  DateTime date = DateTime.parse(dateString);

  // Format the date as "EEE dd" (e.g., "WED 15")
  String formattedDate = DateFormat('EEE dd').format(date).toUpperCase();

  return formattedDate;
}

String formatDateDayDDWithZeroWithPerfectDateString(String dateString) {
  // Parse the date string into a DateTime object
  DateTime date = DateTime.parse(dateString);

  // Format the day with leading zero for single digits (01, 02, etc.)
  String day = date.day.toString().padLeft(2, '0');

  // Format the weekday
  String weekday = DateFormat('EEE').format(date).toUpperCase();

  // Combine weekday and day with leading zero
  String formattedDate = '$weekday $day';

  return formattedDate;
}

String formatDateFullMonthDDYYYYWithPerfectDateString(String dateString) {
  // Parse the date string into a DateTime object
  DateTime date = DateTime.parse(dateString);

  // Format the date as "MMMM dd, yyyy" (e.g., "OCTOBER 28, 2024")
  String formattedDate = DateFormat('MMMM dd, yyyy').format(date).toUpperCase();

  return formattedDate;
}

String convertToDMS(String coordInput, bool isLatitude) {
  // Check if the input already contains degree symbol (°) indicating it's already in DMS format
  if (coordInput.contains('°') ||
      coordInput.contains('N') ||
      coordInput.contains('S') ||
      coordInput.contains('E') ||
      coordInput.contains('W')) {
    return coordInput; // Return as is if already in DMS format
  }

  try {
    // Parse the decimal coordinate
    double coord = double.parse(coordInput);

    // Determine if positive or negative (affects the direction indicator)
    bool isNegative = coord < 0;
    coord = coord.abs();

    // Calculate degrees, minutes, and seconds
    int degrees = coord.floor();
    double minutesDecimal = (coord - degrees) * 60;
    int minutes = minutesDecimal.floor();
    double secondsDecimal = (minutesDecimal - minutes) * 60;
    // Round to 1 decimal place for seconds
    double seconds = (secondsDecimal * 10).round() / 10;

    // Determine direction indicator
    String direction = '';
    if (isLatitude) {
      direction = isNegative ? 'S' : 'N';
    } else {
      direction = isNegative ? 'W' : 'E';
    }

    // Format the result: DD°MM'SS.S"D
    return '$degrees°$minutes\'${seconds.toStringAsFixed(1)}"$direction';
  } catch (e) {
    // If parsing fails, return the original input
    return coordInput;
  }
}

Future<bool> isToday(String dateString) async {
  final dt = _parseCustomDate(dateString);
  DateTime now = await FlutterNTP.now();
  debugPrint('Current NTP time: $now $dt');
  return dt.year == now.year && dt.month == now.month && dt.day == now.day;
}

Future<String> formatTimeDiff(String isoDateString) async {
  // 1️⃣ Get NTP‐corrected “now”
  final DateTime now = await FlutterNTP.now();

  // 2️⃣ Parse the input (assumes valid ISO 8601 with Z)
  final DateTime then = DateTime.parse(isoDateString);

  // 3️⃣ Compute absolute day difference
  final int days = then.difference(now).inDays.abs();

  // 4️⃣ Month check (approx 30-day months)
  if (days >= 30 && days % 30 == 0) {
    final int months = days ~/ 30;
    return '$months month${months > 1 ? 's' : ''}';
  }

  // 5️⃣ Week check
  if (days >= 7 && days % 7 == 0) {
    final int weeks = days ~/ 7;
    return '$weeks week${weeks > 1 ? 's' : ''}';
  }

  // 6️⃣ Fallback to days
  return '$days day${days > 1 ? 's' : ''}';
}
