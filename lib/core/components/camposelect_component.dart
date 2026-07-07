import 'package:flutter/material.dart';


class CampoSelectItem<T> {
  final String label;
  final T value;
  CampoSelectItem({required this.label, required this.value});
}
class CampoSelectComponent<T> extends StatefulWidget {
  final List<CampoSelectItem<T>> items;
  final Function(T)? onChange;
  final String label;
  final T? value;
  const CampoSelectComponent({super.key, required this.items, this.onChange, required this.label, this.value});

  @override
  State<CampoSelectComponent<T>> createState() => _CampoSelectComponentState<T>();
}

class _CampoSelectComponentState<T> extends State<CampoSelectComponent<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant CampoSelectComponent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _selectedValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
      child: DropdownButtonFormField<T>(
        initialValue: _selectedValue,
        isExpanded: true,
         decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        elevation: 16,
        selectedItemBuilder: (context) => widget.items.map((e) => Text(e.label)).toList(),
        items: widget.items.map((e) =>
          DropdownMenuItem<T>(
            value: e.value,
            child: Text(e.label),
          )).toList(),
        onChanged: (T? value) {
          if (value == null) {
            return;
          }
      
          setState(() {
            _selectedValue = value;
          });
      
          widget.onChange?.call(value);
        },
      ),
    );
  }
}