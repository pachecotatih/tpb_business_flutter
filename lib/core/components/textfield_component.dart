import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextfieldComponent extends StatefulWidget {
  final String label;
  final String? text;
  final Function(String value)? onChange;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final String? prefixText;
  final bool? readOnly;
  final Function()? onClick;
  final bool enabledLines;
  const TextfieldComponent({
    super.key,
    required this.label,
    this.text,
    this.onChange,
    this.formatters,
    this.keyboardType,
    this.obscureText,
    this.prefixText,
    this.readOnly,
    this.onClick, this.enabledLines = false,
  });

  @override
  State<TextfieldComponent> createState() => _TextfieldComponentState();
}

class _TextfieldComponentState extends State<TextfieldComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
      child: TextField(
        controller: TextEditingController(text: widget.text),
        obscureText: widget.obscureText ?? false,
        readOnly: widget.readOnly ?? false,
        onTap: widget.onClick,
        maxLines: widget.enabledLines ? null : 1,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.label,
          prefixText: widget.prefixText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 3,
          ),
        ),
        inputFormatters: widget.formatters,
        keyboardType: widget.keyboardType,
        onChanged: (value) => widget.onChange?.call(value),
      ),
    );
  }
}
