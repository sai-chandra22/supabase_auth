import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Remove all non-digit characters (including hyphens)
    text = text.replaceAll(RegExp(r'\D'), '');

    // Insert hyphens to format as 000-000-0000
    String newText = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        newText += '-';
      }
      newText += text[i];
    }

    // Limit to 12 characters (including hyphens: 000-000-0000)
    if (newText.length > 12) {
      newText = newText.substring(0, 12);
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
