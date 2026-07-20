import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/bloco.dart';
import 'package:tpb_business_flutter/core/components/camposelect_component.dart';
import 'package:tpb_business_flutter/core/components/formatters/brazil_phone_formatter.dart';
import 'package:tpb_business_flutter/core/components/formatters/cpf_cnpj_formatter.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/config/user/user_controller.dart';
import 'package:tpb_business_flutter/features/config/user/user_model.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    context.read<UserController>().getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemePage(
      title: "Dados pessoais",
      children: [
        Bloco(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: BlocConsumer<UserController, StateBloc<UserModel>>(
              listener: (context, state) {
                if (state.hasError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.hasError.toString()),
                      backgroundColor: Cores.negativeColor,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
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
                    CampoSelectComponent<String>(
                      value: state.data?.moeda,
                      items: [
                        CampoSelectItem<String>(
                          label: 'Real: R\$',
                          value: 'R\$',
                        ),
                        CampoSelectItem<String>(
                          label: 'Dólar: \$',
                          value: '\$',
                        ),
                        CampoSelectItem<String>(label: 'Euro: €', value: '€'),
                      ],
                      label: 'Moeda',
                      onChange: (value) {
                        state.data?.moeda = value;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Cores.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Alterar senha"),
                        onPressed: () async {
                          _dialogAlterarSenha(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Cores.positiveColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Salvar alterações"),
                        onPressed: () async {
                          bool result = await context
                              .read<UserController>()
                              .updateUser();
                          if (result && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Alterações salvas com sucesso"),
                                backgroundColor: Cores.positiveColor,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Cores.negativeColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Deletar conta"),
                        onPressed: () async {
                          _deleteUser(context);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _dialogAlterarSenha(BuildContext contextScreen) async {
    showDialog(
      barrierDismissible: false,
      context: contextScreen,
      builder: (context) => BlocProvider.value(
        value: contextScreen.read<UserController>(),
        child: BlocBuilder<UserController, StateBloc<UserModel>>(
          builder: (context, stateUser) {
            return AlertDialog(
              title: Text(
                'Alterar senha',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Cores.primaryColor,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: (stateUser.isLoading)
                    ? [const Center(child: CircularProgressIndicator())]
                    : [
                        TextfieldComponent(
                          label: "Nova senha",
                          text: stateUser.data?.password,
                          obscureText: true,
                          onChange: (value) {
                            stateUser.data?.password = value;
                          },
                        ),
                        TextfieldComponent(
                          label: "Confirmar senha",
                          text: stateUser.data?.confirmPassword,
                          obscureText: true,
                          onChange: (value) {
                            stateUser.data?.confirmPassword = value;
                          },
                        ),
                      ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Cores.secondaryText,
                  ),
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Cores.positiveColor,
                  ),
                  child: const Text('Salvar'),
                  onPressed: () async {
                    bool result = await context
                        .read<UserController>()
                        .changePasswordUser();
                    if (result && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Senha alterada com sucesso"),
                          backgroundColor: Cores.positiveColor,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _deleteUser(BuildContext contextScreen) {
    String deletar = '';
    showDialog<void>(
      context: contextScreen,
      builder: (context) => AlertDialog(
        title: Text(
          'Deletar Conta',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Cores.primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Para deletar sua conta, digite a palavra "DELETAR" no campo de texto abaixo.',
              textAlign: TextAlign.center,
            ),
            TextfieldComponent(
              label: "",
              text: deletar,
              obscureText: false,
              onChange: (value) => {deletar = value},
              keyboardType: TextInputType.text,
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Cores.secondaryText,
            ),
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Cores.negativeColor,
            ),
            child: const Text('Excluir'),
            onPressed: () async {
              if (deletar.toLowerCase() == 'deletar') {
                Navigator.pop(context);
                bool result = await contextScreen
                    .read<UserController>()
                    .deleteUser();
                if (result) {
                  appRouter.pushReplacement('/login');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
