import 'package:flutter/material.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';

class TituloH1 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  const TituloH1({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return TextoPadrao(
      text: text,
      color: color ?? Cores.principalText,
      textAlign: textAlign ?? TextAlign.center,
      fontSize: fontSize ?? 20,
    );
  }
}

class TituloH2 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  const TituloH2({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return TextoPadrao(
      text: text,
      color: color ?? Cores.principalText,
      textAlign: textAlign ?? TextAlign.center,
      fontSize: fontSize ?? 18,
    );
  }
}

class TextoPadrao extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  const TextoPadrao({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 14,
        color: color ?? Cores.secondaryText,
      ),
      textAlign: textAlign,
    );
  }
}
