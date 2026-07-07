import 'package:flutter/services.dart';

class CpfCnpjFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String numbers = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (numbers.length > 14) {
      numbers = numbers.substring(0, 14);
    }

    final buffer = StringBuffer();

    if (numbers.length <= 11) {
      // CPF
      for (int i = 0; i < numbers.length; i++) {
        if (i == 3 || i == 6) buffer.write('.');
        if (i == 9) buffer.write('-');
        buffer.write(numbers[i]);
      }
    } else {
      // CNPJ
      for (int i = 0; i < numbers.length; i++) {
        if (i == 2 || i == 5) buffer.write('.');
        if (i == 8) buffer.write('/');
        if (i == 12) buffer.write('-');
        buffer.write(numbers[i]);
      }
    }

    final text = buffer.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
