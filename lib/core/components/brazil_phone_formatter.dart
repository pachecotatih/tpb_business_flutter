import 'package:flutter/services.dart';

class BrazilPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Remove o 55 caso o usuário tente digitá-lo
    if (digits.startsWith('55')) {
      digits = digits.substring(2);
    }

    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    final buffer = StringBuffer('+55');

    if (digits.isNotEmpty) {
      buffer.write(' ');
    }

    // DDD
    if (digits.length >= 2) {
      buffer.write(digits.substring(0, 2));
    } else {
      buffer.write(digits);
    }

    // Primeira parte do telefone
    if (digits.length > 2) {
      buffer.write(' ');
      if (digits.length >= 7) {
        buffer.write(digits.substring(2, 7));
      } else {
        buffer.write(digits.substring(2));
      }
    }

    // Última parte
    if (digits.length > 7) {
      buffer.write(' ');
      buffer.write(digits.substring(7));
    }

    final text = buffer.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
