import 'package:flutter/material.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String textContent;
  final Function onConfirm;
  const ConfirmDialog({
    super.key,
    required this.onConfirm,
    required this.title,
    required this.textContent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color:Cores.primaryColor)),
      content: Text(textContent, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Cores.negativeColor,
          ),
          child: const Text('Sim'),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Cores.secondaryText,
          ),
          child: const Text('Não'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => this,
    );
  }
}
