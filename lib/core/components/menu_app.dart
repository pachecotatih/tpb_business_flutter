import 'package:flutter/material.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';

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
      iconTheme: IconThemeData(color: Cores.colorLogo),
      centerTitle: true,
      actions: [],
      title: TextButton(
        onPressed: () => appRouter.go('/'),
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
  final void Function() onLogout;
  const MenuDrawer({super.key, required this.onLogout});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Cores.attentionColor),
            child: Text(
              'Olá, ${Preferences.instance.name}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () => appRouter.go('/configuracoes'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                        Navigator.pop(context);
                        widget.onLogout();
                      },
                      child: const Text('Sim'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
