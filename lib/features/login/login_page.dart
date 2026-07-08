import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/login_screen.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/login/login_controller.dart';
import 'package:tpb_business_flutter/features/login/login_model.dart';

class LoginPage extends StatefulWidget {
  final bool userCadastrado;
  const LoginPage({super.key, this.userCadastrado = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.principalBackground,
      body: BlocConsumer<LoginController, StateBloc<LoginModel>>(
        builder: (context, state) {
          return LoginScreen(
            child: state.isLoading
                ? Center(child: const CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Image.asset('assets/img/tpb_logo1.png'),
                      ),
                      if (widget.userCadastrado)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Cores.positiveColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Usuário cadastrado com sucesso!\nFaça login para continuar",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      TextfieldComponent(
                        label: "Email",
                        text: state.data?.email,
                        onChange: (value) {
                          state.data?.email = value;
                        },
                      ),
                      TextfieldComponent(
                        label: "Senha",
                        obscureText: true,
                        text: state.data?.password,
                        onChange: (value) {
                          state.data?.password = value;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Cores.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            bool result = await context
                                .read<LoginController>()
                                .login();
                            if (result) {
                              appRouter.go('/');
                            }
                          },
                          child: const Text('Entrar'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Ainda não tem uma conta?',
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Cores.primaryColor,
                              ),
                              onPressed: () {
                                appRouter.go('/cadastrar');
                              },
                              child: const Text('Criar conta'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
        listener: (context, state) {
          if (Preferences.instance.token.isNotEmpty) {
            appRouter.go('/');
          }
          if (state.hasError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.hasError.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}
