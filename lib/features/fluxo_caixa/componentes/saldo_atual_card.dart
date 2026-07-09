import 'package:flutter/material.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
import 'package:tpb_business_flutter/features/fluxo_caixa/componentes/arrow_icon.dart';

class SaldoAtualCard extends StatelessWidget {
  final double saldo;
  final double entrada;
  final double saida;
  const SaldoAtualCard({
    super.key,
    required this.saldo,
    required this.entrada,
    required this.saida,
  });

  @override
  Widget build(BuildContext context) {
    return Bloco(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Saldo Atual".toUpperCase(), style: TextStyle(fontSize: 12)),
          Text(
            "${Preferences.instance.moeda}${Util.stringFormatValor(saldo)}",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Cores.primaryColor,
            ),
          ),
          Divider(),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 50,
            runSpacing: 50,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ArrowIcon(
                    icon: Icons.arrow_upward_sharp,
                    color1: Cores.positiveColor,
                    color2: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Column(
                    children: [
                      Text(
                        'Entradas'.toUpperCase(),
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "${Preferences.instance.moeda}${Util.stringFormatValor(entrada)}",
                        style: TextStyle(
                          color: Cores.positiveColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ArrowIcon(
                    icon: Icons.arrow_downward_sharp,
                    color1: Cores.negativeColor,
                    color2: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Column(
                    children: [
                      Text(
                        'Saídas'.toUpperCase(),
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "${Preferences.instance.moeda} ${Util.stringFormatValor(saida)}",
                        style: TextStyle(
                          color: Cores.negativeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
