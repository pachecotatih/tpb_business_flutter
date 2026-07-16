import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/dialog/confirm_dialog.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';

class MenuApp extends StatefulWidget implements PreferredSizeWidget {
  const MenuApp({super.key});

  @override
  State<MenuApp> createState() => _MenuAppState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MenuAppState extends State<MenuApp> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) {
          final bool temDrawer = Scaffold.of(context).hasDrawer;
          if (temDrawer) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      iconTheme: IconThemeData(color: Cores.primaryColor),
      centerTitle: true,
      actions: [],
      title: TextButton(
        onPressed: () => appRouter.pushReplacement('/'),
        child: Container(
          width: 120,
          margin: const EdgeInsets.all(10),
          child: Image.asset('assets/img/tpb_logo2.png'),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }
}

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String caminhoMapeado = '';
  @override
  Widget build(BuildContext context) {
    caminhoMapeado = GoRouterState.of(context).uri.toString();
    return SizedBox(
      width: 300,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Cores.attentionColor),
            child: Column(
              spacing: 10,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Image.asset('assets/img/tpb_logo1.png', height: 80),
                ),
                Text(
                  'Olá, ${Preferences.instance.name.split(" ")[0]}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ListTile(
            selected: (caminhoMapeado == '/'),
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => appRouter.pushReplacement('/'),
          ),
          Divider(),
          ListTile(
            selected: (caminhoMapeado.startsWith('/cliente')),
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () => appRouter.pushReplacement('/cliente'),
          ),
          ListTile(
            selected: (caminhoMapeado.startsWith('/servico')),
            leading: const Icon(Icons.work),
            title: const Text('Serviços'),
            onTap: () => appRouter.pushReplacement('/servico'),
          ),
          Divider(),
          ListTile(
            selected: (caminhoMapeado.startsWith('/agendamento')),
            leading: const Icon(Icons.calendar_month),
            title: const Text('Agendamentos'),
            onTap: () => appRouter.pushReplacement('/agendamento'),
          ),
          ListTile(
            selected: (caminhoMapeado.startsWith('/fluxocaixa')),
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Fluxo de Caixa'),
            onTap: () => appRouter.pushReplacement('/fluxocaixa'),
          ),
          Divider(),
          ListTile(
            selected: (caminhoMapeado.startsWith('/configuracoes')),
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () => appRouter.pushReplacement('/configuracoes'),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Cores.negativeColor),
            title: Text(
              'Sair',
              style: TextStyle(
                color: Cores.negativeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              ConfirmDialog(
                onConfirm: () async {
                  await Util.logoutUser(context);
                },
                title: 'Sair da conta',
                textContent: 'Deseja realmente sair da conta?',
              ).show(context);
            },
          ),
        ],
      ),
    );
  }
}
