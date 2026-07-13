import 'package:flutter/services.dart';

class CpfCnpjFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Limpa o texto mantendo apenas o que interessa e joga para Maiúsculo
    String rawText = newValue.text
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toUpperCase();
    final bufferCleaned = StringBuffer();

    // Aplica a regra de filtragem caractere por caractere enquanto o usuário digita
    for (int i = 0; i < rawText.length; i++) {
      final char = rawText[i];
      final currentLength = bufferCleaned.length;

      if (currentLength < 11) {
        // Até o caractere 11, aceita letras e números (pode virar CPF ou CNPJ)
        if (RegExp(r'[A-Z0-9]').hasMatch(char)) {
          bufferCleaned.write(char);
        }
      } else if (currentLength == 11) {
        // O 12º caractere decide se é CNPJ alfanumérico ou a continuação de um CPF.
        // Se contiver letras antes, é CNPJ obrigatoriamente, então aceita letra ou número.
        // Se só tinha números antes, o 12º caractere força a virar CNPJ, aceitando letra ou número.
        if (RegExp(r'[A-Z0-9]').hasMatch(char)) {
          bufferCleaned.write(char);
        }
      } else if (currentLength >= 12 && currentLength < 14) {
        // Baseado no seu _CNPJValidator: "last 2 must be digits" (^[A-Z0-9]{12}[0-9]{2}$)
        // Os caracteres das posições 13 e 14 SÓ podem ser números de 0 a 9.
        if (RegExp(r'[0-9]').hasMatch(char)) {
          bufferCleaned.write(char);
        }
      }
    }

    String cleaned = bufferCleaned.toString();

    // Limita o tamanho máximo absoluto a 14 caracteres válidos
    if (cleaned.length > 14) {
      cleaned = cleaned.substring(0, 14);
    }

    // 2. Decide a máscara baseando-se nas regras dos seus validadores
    // Se tiver QUALQUER letra no meio ou se passar de 11 caracteres, aplica máscara de CNPJ
    bool isCnpj = cleaned.length > 11 || RegExp(r'[A-Z]').hasMatch(cleaned);

    final bufferFormatted = StringBuffer();

    if (!isCnpj) {
      // Formatação idêntica ao padrão limpo do seu _CPFValidator (000.000.000-00)
      for (int i = 0; i < cleaned.length; i++) {
        if (i == 3 || i == 6) bufferFormatted.write('.');
        if (i == 9) bufferFormatted.write('-');
        bufferFormatted.write(cleaned[i]);
      }
    } else {
      // Formatação idêntica ao padrão limpo do seu _CNPJValidator (AA.AAA.AAA/AAAA-00)
      for (int i = 0; i < cleaned.length; i++) {
        if (i == 2 || i == 5) bufferFormatted.write('.');
        if (i == 8) bufferFormatted.write('/');
        if (i == 12) bufferFormatted.write('-');
        bufferFormatted.write(cleaned[i]);
      }
    }

    final text = bufferFormatted.toString();

    // 3. Retorna o texto formatado reposicionando o cursor no final
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
