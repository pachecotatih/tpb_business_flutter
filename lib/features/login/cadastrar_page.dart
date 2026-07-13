import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/formatters/brazil_phone_formatter.dart';
import 'package:tpb_business_flutter/core/components/formatters/cpf_cnpj_formatter.dart';
import 'package:tpb_business_flutter/core/components/login_screen.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/login/login_controller.dart';
import 'package:tpb_business_flutter/features/login/login_model.dart';

class CadastrarPage extends StatefulWidget {
  const CadastrarPage({super.key});

  @override
  State<CadastrarPage> createState() => _CadastrarPageState();
}

class _CadastrarPageState extends State<CadastrarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Cores.principalBackground,
      body: BlocConsumer<LoginController, StateBloc<LoginModel>>(
        builder: (context, state) {
          return LoginScreen(
            child: state.isLoading
                ? Center(child: const CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        spacing: 20.0,
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: TextButton(
                              onPressed: () {
                                appRouter.pushReplacement('/login');
                              },
                              child: Icon(Icons.arrow_back),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topCenter,
                            width: 120,
                            child: Image.asset('assets/img/tpb_logo1.png'),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            TextfieldComponent(
                              label: "Nome",
                              text: state.data?.name,
                              onChange: (value) {
                                state.data?.name = value;
                              },
                            ),
                            TextfieldComponent(
                              label: "Email",
                              text: state.data?.email,
                              keyboardType: TextInputType.emailAddress,
                              onChange: (value) {
                                state.data?.email = value;
                              },
                            ),
                            TextfieldComponent(
                              label: 'Senha',
                              obscureText: true,
                              text: state.data?.password,
                              onChange: (value) {
                                state.data?.password = value;
                              },
                            ),
                            TextfieldComponent(
                              label: "CPF/CNPJ",
                              text: state.data?.documento,
                              onChange: (value) {
                                state.data?.documento = value;
                              },
                              formatters: [CpfCnpjFormatter()],
                              keyboardType: TextInputType.text,
                            ),
                            TextfieldComponent(
                              label: "Telefone",
                              text: state.data?.telefone,
                              onChange: (value) {
                                state.data?.telefone = value;
                              },
                              formatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                BrazilPhoneFormatter(),
                              ],
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
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
                                .cadastrar();
                            if (result) {
                              appRouter.pushReplacement('/login', extra: true);
                            }
                          },
                          child: const Text('Criar Conta'),
                        ),
                      ),
                    ],
                  ),
          );
        },
        listener: (context, state) {
          if (Preferences.instance.token.isNotEmpty) {
            GoRouter.of(context).pushReplacement('/');
          }
          if (state.hasError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.hasError.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Cores.negativeColor,
              ),
            );
          }
        },
      ),
    );
  }
}
