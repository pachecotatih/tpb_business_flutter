import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpb_business_flutter/core/services/state_bloc.dart';

abstract class BaseController<T> extends Cubit<StateBloc<T>> {
  BaseController(super.initialState);

  @override
  void emit(StateBloc<T> state) {
    if (!isClosed) {
      super.emit(state);
    }
  }
}