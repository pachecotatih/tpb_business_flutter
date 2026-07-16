import 'package:flutter/material.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/dialog/confirm_dialog.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    BuildContext contextScreen = context;
    return ThemePage(
      children: [
        ListTile(
          title: const Text('Informações pessoais'),
          onTap: () => appRouter.pushReplacement('/user'),
        ),
        ListTile(
          title: Text(
            'Sair da conta',
            style: TextStyle(color: Cores.negativeColor),
          ),
          onTap: () async {
            ConfirmDialog(
              onConfirm: () async {
                await Util.logoutUser(contextScreen);
              }
              ,
              title: 'Sair da conta',
              textContent: 'Deseja realmente sair da conta?',
            ).show(contextScreen);
            
          },
        ),
      ],
    );
  }
}
