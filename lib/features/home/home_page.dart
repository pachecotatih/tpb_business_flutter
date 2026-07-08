import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpb_business_flutter/core/components/textos.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dataFormatada = DateFormat(
    "EEEE, dd 'de' MMMM 'de' yyyy",
    "pt_BR",
  ).format(DateTime.now());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ThemePage(
      children: [
        Card(
          margin: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            children: [
              TituloH1(text: "Bem vindo, ${Preferences.instance.name}!"),
              TituloH2(
                text:
                    dataFormatada[0].toUpperCase() + dataFormatada.substring(1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
