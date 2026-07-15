import 'package:dio/dio.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/base_controller.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';
import 'package:tpb_business_flutter/features/home/home_model.dart';

class HomeController extends BaseController<HomeModel> {
  final Repository repository;
  HomeController(this.repository)
    : super(StateBloc<HomeModel>(data: HomeModel()));

  Future<void> getHome() async {
    emit(state.copyWith(isLoading: true));
    try {
      Response response;
      try {
        response = await repository.get("${Globals.urlApi}/home");
      } on DioException catch (e) {
        throw Exception("Erro ao obter dados da home. ${e.message}");
      }
      switch (response.statusCode) {
        case 200:
          emit(
            state.copyWith(
              data: HomeModel.fromJson(response.data),
              isLoading: false,
            ),
          );
          break;
        case 500:
          emit(
            state.copyWith(
              hasError: "Erro interno ao obter dados da home",
              isLoading: false,
            ),
          );
          break;
        default:
          emit(
            state.copyWith(
              hasError: "Erro ao obter dados da home",
              isLoading: false,
            ),
          );
          break;
      }
    } catch (e) {
      emit(state.copyWith(hasError: e, isLoading: false));
    }
  }
}
