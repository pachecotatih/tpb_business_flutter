import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';
import 'package:tpb_business_flutter/features/login/login_controller.dart';
import 'package:tpb_business_flutter/features/login/login_model.dart';
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
      iconTheme: IconThemeData(color: Cores.colorLogo),
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
    caminhoMapeado = GoRouterState.of(context).matchedLocation;
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
            selected: (caminhoMapeado == '/'),
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => appRouter.pushReplacement('/'),
          ),
          Divider(),
          ListTile(
            selected: (caminhoMapeado == '/cliente'),
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () => appRouter.pushReplacement('/cliente'),
          ),
          Divider(),
          ListTile(
            selected: (caminhoMapeado == '/configuracoes'),
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () => appRouter.pushReplacement('/configuracoes'),
          ),
          ListTile(
            leading:  Icon(Icons.logout, color: Cores.negativeColor),
            title:  Text(
              'Sair',
              style: TextStyle(color: Cores.negativeColor, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              showDialog(
                context: context,
                builder: (dialogContext) => BlocBuilder<LoginController, StateBloc<LoginModel>>(
                  builder: (contextUser, stateUser) {
                    return AlertDialog(
                  title: const Text('Sair'),
                  content: const Text('Deseja realmente sair?'),
                  actions: (stateUser.isLoading)
                    ? [const Center(child: CircularProgressIndicator())]
                    : [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Não'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Util.logoutUser(contextUser);
                      },
                      child: const Text('Sim'),
                    ),
                  ],
               
              );
            },
              ),
              );
            },
          ),
        ],
      ),
    );
  }
}
