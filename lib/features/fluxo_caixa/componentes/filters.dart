import 'package:flutter/material.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';

class MovimentacaoFilter extends StatelessWidget {
  final Function() onFilterTodos;
  final Function() onFilterEntrada;
  final Function() onFilterSaida;
  final String movimentacaoEscolhida;
  const MovimentacaoFilter({
    super.key,
    required this.onFilterTodos,
    required this.onFilterEntrada,
    required this.onFilterSaida, required this.movimentacaoEscolhida,
  });

  @override
  Widget build(BuildContext context) {
    return Bloco(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          _textButton(
            onPressed: () {
              onFilterTodos();
            },
            text: "Todos",
          ),
          _textButton(
            onPressed: () {
              onFilterEntrada();
            },
            text: "Entrada",
          ),
          _textButton(
            onPressed: () {
              onFilterSaida();
            },
            text: "Saída",
          ),
        ],
      ),
    );
  }

  Widget _textButton({String text = '', Function()? onPressed}) =>
      Expanded(
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor:movimentacaoEscolhida == text ? Cores.primaryColor : Cores.principalText,
            side: BorderSide(color: movimentacaoEscolhida == text ? Cores.primaryColor : Cores.principalText.withValues(alpha: 0.2)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            fixedSize: const Size.fromHeight(50),
          ),
          onPressed: onPressed,
          child: Text(text),
        ),
      );
}

class DataFilter extends StatelessWidget {
  final String dataInicio;
  final String dataFim;
  final Function onFilterInicio;
  final Function onFilterFim;
  const DataFilter({super.key, required this.onFilterInicio, required this.onFilterFim, required this.dataInicio, required this.dataFim});

  @override
  Widget build(BuildContext context) {
    return Bloco(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: TextfieldComponent(
              label: "Data Inicial",
              readOnly: true,
              text: Util.dateFormatString(dataInicio),
              onClick: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(dataInicio),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.parse(dataFim),
                ).then((value){
                  if(value != null) onFilterInicio.call(value);
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: TextfieldComponent(
              label: "Data Final",
              readOnly: true,
              text: Util.dateFormatString(dataFim),
              onClick: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(dataFim),
                  firstDate: DateTime.parse(dataInicio),
                  lastDate: DateTime(3000),
                ).then((value){
                  if(value != null) onFilterFim.call(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}