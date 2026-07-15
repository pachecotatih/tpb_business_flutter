import 'package:flutter/material.dart';

class CampoSelectItem<T> {
  final String label;
  final T value;
  final bool disabled;
  CampoSelectItem({required this.label, required this.value, this.disabled = false});
}

class CampoSelectComponent<T> extends StatefulWidget {
  final List<CampoSelectItem<T>> items;
  final Function(T)? onChange;
  final String label;
  final T? value;
  const CampoSelectComponent({
    super.key,
    required this.items,
    this.onChange,
    required this.label,
    this.value,
  });

  @override
  State<CampoSelectComponent<T>> createState() =>
      _CampoSelectComponentState<T>();
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
        elevation: 16,
        selectedItemBuilder: (context) =>
            widget.items.map((e) => Text(e.label)).toList(),
        items: widget.items
            .map(
              (e) => DropdownMenuItem<T>(value: e.value,enabled: !e.disabled, child: Text(e.label)),
            )
            .toList(),
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

class CampoSelectPesquisaComponent<T> extends StatefulWidget {
  final List<CampoSelectItem<T>> items;
  final Function(T)? onChange;
  final String label;
  final T? value;

  const CampoSelectPesquisaComponent({
    super.key,
    required this.items,
    required this.label,
    this.onChange,
    this.value,
  });

  @override
  State<CampoSelectPesquisaComponent<T>> createState() =>
      _CampoSelectPesquisaComponentState<T>();
}

class _CampoSelectPesquisaComponentState<T>
    extends State<CampoSelectPesquisaComponent<T>> {
  late final TextEditingController _controller;
  T? _selectedValue;

  @override
  void initState() {
    super.initState();

    _selectedValue = widget.value;

    _controller = TextEditingController(
      text: widget.items
          .where((e) => e.value == widget.value)
          .map((e) => e.label)
          .firstOrNull,
    );
  }

  @override
  void didUpdateWidget(covariant CampoSelectPesquisaComponent<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

     if (oldWidget.items != widget.items) {
      _controller.text =
          widget.items
              .where((e) => e.value == widget.value)
              .map((e) => e.label)
              .firstOrNull ??
          '';
    }

    if (oldWidget.value != widget.value) {
      _selectedValue = widget.value;

      _controller.text =
          widget.items
              .where((e) => e.value == widget.value)
              .map((e) => e.label)
              .firstOrNull ??
          '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: DropdownMenu<T>(
        controller: _controller,
        width: double.infinity,
        initialSelection: _selectedValue,
        enableSearch: true,
        enableFilter: true,
        requestFocusOnTap: true,
        label: Text(widget.label),
        menuHeight: 300,
        dropdownMenuEntries: widget.items
            .map((e) => DropdownMenuEntry<T>(value: e.value,enabled: !e.disabled, label: e.label))
            .toList(),
        onSelected: (value) {
          if (value == null) return;

          setState(() {
            _selectedValue = value;
          });

          widget.onChange?.call(value);
        },
      ),
    );
  }
}
