import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/components/brazil_phone_formatter.dart';
import 'package:tpb_business_flutter/core/components/camposelect_component.dart';
import 'package:tpb_business_flutter/core/components/cpf_cnpj_formatter.dart';
import 'package:tpb_business_flutter/core/components/textfield_component.dart';
import 'package:tpb_business_flutter/core/components/theme_page.dart';
import 'package:tpb_business_flutter/core/constants/cores.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/config/user/user_controller.dart';
import 'package:tpb_business_flutter/features/config/user/user_model.dart';
import 'package:tpb_business_flutter/features/login/login_controller.dart';
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    context.read<UserController>().getUser();
    return ThemePage(
      children: [
        Card(
          color: Colors.white,
          margin: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: BlocConsumer<UserController,StateBloc<UserModel>> (
              listener: (context, state) {
                if (state.hasError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.hasError.toString()), backgroundColor: Colors.red,));
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator(),);
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
                              formatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                CpfCnpjFormatter(),
                              ],
                              keyboardType: TextInputType.number,
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
                              CampoSelectItem<String>(label: 'Real: R\$', value: 'R\$'),
                              CampoSelectItem<String>(label: 'Dólar: \$', value: '\$'),
                              CampoSelectItem<String>(label: 'Euro: €', value: '€'),
                            ], 
                            label: 'Moeda',
                            onChange: (value) {
                              state.data?.moeda = value;
                            }
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Cores.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Salvar alterações"),
                                onPressed: () {
                                  context.read<UserController>().updateUser();
                                },
                              ),
                            )
                    ],
                );
              }
            ),
          )),
      ],
      onLogout: () async {
          bool logout = await context.read<LoginController>().logout();
            if (logout) {
              appRouter.go('/login');
            }
        }
    );
  }
}
