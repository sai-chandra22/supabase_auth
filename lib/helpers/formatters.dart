import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String formatDates(String dateStr) {
  try {
    // Try to parse the input string into a DateTime object
    DateTime date = DateTime.parse(dateStr);

    // Format the date as "MMM d" (e.g., "Oct 4")
    String formattedDate = DateFormat('MMM d').format(date);

    return formattedDate
        .toUpperCase(); // Return the formatted date in uppercase
  } catch (e) {
    // If there's an exception (invalid date format), return the default value 'OCT 21'
    return '';
  }
}

String timeAgo(String isoDateStr) {
  // Parse the input ISO 8601 string into a DateTime object
  DateTime dateTime = DateTime.parse(isoDateStr);

  // Get the current date and time
  DateTime now = DateTime.now();

  // Calculate the difference between the current date and the parsed date
  Duration diff = now.difference(dateTime);

  // Get the total number of days from the duration
  int days = diff.inDays;

  // Convert into relative time string
  if (days >= 365) {
    int years = (days / 365).floor();
    return years == 1 ? '1yr' : '$years yrs';
  } else if (days >= 30) {
    int months = (days / 30).floor();
    return months == 1 ? '1mo' : '$months mo';
  } else if (days >= 7) {
    int weeks = (days / 7).floor();
    return weeks == 1 ? '1wk' : '$weeks wks';
  } else if (days > 0) {
    return days == 1 ? '1d' : '$days days';
  } else {
    // If it's within the same day, return 'Today'
    return 'Today';
  }
}

String formatAbsNumber(num number) {
  final numberFormat = NumberFormat.decimalPattern('en_US');
  final isNegative = number < 0;
  final absNumber = number.abs();

  String formatted;

  if (absNumber < 1000) {
    formatted = absNumber.toStringAsFixed(0);
  } else if (absNumber < 100000) {
    formatted = numberFormat.format(absNumber);
  } else if (absNumber < 1000000000) {
    double result = absNumber / 1000000;
    formatted = result == result.toInt()
        ? '${result.toInt()}M'
        : '${result.toStringAsFixed(1)}M';
  } else if (absNumber < 1000000000000) {
    double result = absNumber / 1000000000;
    formatted = result == result.toInt()
        ? '${result.toInt()}B'
        : '${result.toStringAsFixed(1)}B';
  } else {
    double result = absNumber / 1000000000000;
    formatted = result == result.toInt()
        ? '${result.toInt()}T'
        : '${result.toStringAsFixed(1)}T';
  }

  return isNegative ? '-$formatted' : '+$formatted';
}

String formatNumber(num number) {
  final numberFormat =
      NumberFormat.decimalPattern('en_US'); // For US-style commas

  if (number < 1000) {
    // If the number is less than 1000, return it as is
    return number.toStringAsFixed(0);
  } else if (number < 1000000) {
    // If the number is in the thousands (1K to 999K)
    return numberFormat.format(number);
  } else if (number < 1000000000) {
    // If the number is in the millions (1M to 999M)
    double result = number / 1000000;
    return result == result.toInt()
        ? '${result.toInt()}M'
        : '${result.toStringAsFixed(1)}M';
  } else if (number < 1000000000000) {
    // If the number is in the billions (1B to 999B)
    double result = number / 1000000000;
    return result == result.toInt()
        ? '${result.toInt()}B'
        : '${result.toStringAsFixed(1)}B';
  } else {
    // If the number is in the trillions (1T+)
    double result = number / 1000000000000;
    return result == result.toInt()
        ? '${result.toInt()}T'
        : '${result.toStringAsFixed(1)}T';
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only numbers and a single decimal point
    final numericValue = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Ensure only one decimal point exists
    if (numericValue.contains('.')) {
      final parts = numericValue.split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '';
      return TextEditingValue(
        text: '\$$integerPart.$decimalPart',
        selection: TextSelection.collapsed(
            offset: '\$$integerPart.$decimalPart'.length),
      );
    }

    // Prefix with '$'
    final formattedValue = numericValue.isEmpty ? '' : '\$$numericValue';

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}

class UsNumberInputFormatter extends TextInputFormatter {
  final NumberFormat _numberFormat = NumberFormat.decimalPattern('en_US');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If the input is empty, return it as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove commas and parse the number
    String newText = newValue.text.replaceAll(',', '');
    double? value = double.tryParse(newText);

    if (value == null) {
      // If parsing fails, keep the old value
      return oldValue;
    }

    // Format the number with commas
    String formattedText = _numberFormat.format(value);

    // Calculate the new cursor position
    int newCursorPosition =
        formattedText.length - (newValue.text.length - newValue.selection.end);

    // Return the updated value
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
