import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoneyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter;

  MoneyInputFormatter({
    required String locale,
    required String symbol,
    int decimalDigits = 2,
  }) : _formatter = NumberFormat.currency(
         locale: locale,
         symbol: symbol,
         decimalDigits: decimalDigits,
       );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      digits = '0';
    }

    final value = int.parse(digits) / 100;

    final text = _formatter.format(value);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
