import 'package:flutter/material.dart';

class Bloco extends StatelessWidget {
  final Widget child;
  const Bloco({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Material(
        // Substituto do Container interno para habilitar o Material Design
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip
            .antiAlias, // Garante que o hover respeite as bordas arredondadas
        child: Padding(padding: const EdgeInsets.all(10), child: child),
      ),
    );
  }
}
