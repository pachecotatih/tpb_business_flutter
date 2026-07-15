import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tpb_business_flutter/core/app/app_router.dart';
import 'package:tpb_business_flutter/core/constants/globals.dart';
import 'package:tpb_business_flutter/core/services/preferences.dart';
import 'package:tpb_business_flutter/core/services/repository.dart';
import 'package:tpb_business_flutter/core/utils/util.dart';

class DioRepository implements Repository {
  Dio dio = Dio();
  Completer<Map<String, dynamic>>? _refreshCompleter;

  Future<void> setHeaders() async {
    String jwtToken = Preferences.instance.token;
    String deviceName = Util.getDeviceName();
    String deviceId = Preferences.instance.deviceId;
    dio.options = BaseOptions(
      headers: {
        "Authorization": "Bearer $jwtToken",
        "Accept": "application/json",
        "Content-Type": "application/json",
        "user": Preferences.instance.user,
        "device": deviceName,
        "device_id": deviceId,
      },
      validateStatus: (status) {
        return (status != null &&
                status >= 200 &&
                status < 300 &&
                status != 401) ||
            status == 422;
      },
    );
  }

  Future<dynamic> _verifyErrorStatus(DioException e) async {
    if (_refreshCompleter == null) {
      Map mapToken = await _completerRefreshToken();
      if (mapToken['sucesso'] == true && mapToken['token'] != null) {
        return true;
      } else if (mapToken['sucesso'] == false) {
        await _redirecionarParaLoginSeguro();
        throw e;
      }
    }
    return _refreshCompleter;
  }

  Future<Map<String, dynamic>> _completerRefreshToken() async {
    _refreshCompleter = Completer<Map<String, dynamic>>();
    try {
      Response response;
      if (Preferences.instance.token.isNotEmpty) {
        response = await _refreshToken({
          "refresh_token": Preferences.instance.refreshToken,
          "device_id": Preferences.instance.deviceId,
        });
      } else {
        final erro = {
          'sucesso': false,
          'erro': 'Credenciais insuficientes para obter token.',
        };
        _refreshCompleter!.complete(erro);
        return erro;
      }

      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data.containsKey('access_token') &&
          response.data.containsKey('refresh_token')) {
        bool alterJwtToken = await Preferences.instance.setToken(
          response.data['access_token'],
        );
        bool atlereRefreshToken = await Preferences.instance.setRefreshToken(
          response.data['refresh_token'],
        );
        if (alterJwtToken && atlereRefreshToken) {
          if (kDebugMode) {
            print("JWT Token atualizado com sucesso.");
          }
          _refreshCompleter!.complete({
            'sucesso': true,
            'token': response.data['access_token'],
          });
          return {'sucesso': true, 'token': response.data['access_token']};
        } else {
          if (kDebugMode) {
            print("JWT Token não foi atualizado.");
          }
          _refreshCompleter!.complete({'sucesso': false});
          return {'sucesso': false};
        }
      } else {
        if (kDebugMode) {
          print(
            "JWT Token inválido: ${response.statusCode}. Redirecionando para login.",
          );
        }
        if (!_refreshCompleter!.isCompleted) {
          _refreshCompleter!.complete({'sucesso': false});
        }
        return {'sucesso': false};
      }
    } catch (e) {
      if (!_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete({'sucesso': false});
      }
      return {'sucesso': false};
    } finally {
      _refreshCompleter = null; // ← ESSENCIAL!
    }
  }

  Future<void> _redirecionarParaLoginSeguro() async {
    await Preferences.clear();
    appRouter.pushReplacement('/login');
  }

  @override
  Future<dynamic> delete(String link) async {
    await setHeaders();
    Response response;
    try {
      response = await dio.delete(link);
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        await _verifyErrorStatus(e);
        response = await delete(link);
      } else {
        rethrow;
      }
    }
    return response;
  }

  @override
  Future<dynamic> get(String url) async {
    await setHeaders();
    Response response;
    try {
      response = await dio.get(url);
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        await _verifyErrorStatus(e);
        response = await get(url);
      } else {
        rethrow;
      }
    }
    return response;
  }

  @override
  Future<dynamic> post(String url, Map<String, dynamic> data) async {
    await setHeaders();
    Response response;
    try {
      response = await dio.post(url, data: data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        await _verifyErrorStatus(e);
        response = await post(url, data);
      } else {
        rethrow;
      }
    }
    return response;
  }

  @override
  Future<dynamic> put(String url, Map<String, dynamic> data) async {
    await setHeaders();
    Response response;
    try {
      response = await dio.put(url, data: data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        await _verifyErrorStatus(e);
        response = await put(url, data);
      } else {
        rethrow;
      }
    }
    return response;
  }

  Future<dynamic> _refreshToken(Map<String, dynamic> data) async {
    await setHeaders();
    dio.options.validateStatus = (status) {
      return status != null;
    };
    return dio.post('${Globals.urlApi}/refresh', data: data);
  }
}
