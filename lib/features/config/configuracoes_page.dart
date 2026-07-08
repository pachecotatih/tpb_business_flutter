import 'package:flutter/material.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
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
          onTap: () => appRouter.go('/user'),
        ),
        ListTile(
          title: const Text(
            'Sair da conta',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sair'),
                content: const Text('Deseja realmente sair?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Não'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Util.logoutUser(contextScreen);
                    },
                    child: const Text('Sim'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
