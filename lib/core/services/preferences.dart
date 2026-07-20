import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences instance = Preferences();

  late String token;
  late String refreshToken;
  late String user;
  late String name;
  late String email;
  late String moeda;
  late String deviceId;
  late String urlApi;

  late SharedPreferences prefs;

  Future<void> init() async {
    email = await get("email");
    token = await get("token");
    user = await get("user");
    name = await get("name");
    moeda = await get("moeda", "R\$");
    refreshToken = await get("refreshToken");
    deviceId = await get("deviceId");
    urlApi = const String.fromEnvironment('URL_API');
  }

  Future<bool> setEmail(String v) async {
    email = v;
    return await set("email", email);
  }

  Future<bool> setToken(String v) async {
    token = v;
    return await set("token", token);
  }

  Future<bool> setRefreshToken(String v) async {
    refreshToken = v;
    return await set("refreshToken", refreshToken);
  }

  Future<bool> setUser(String v) async {
    user = v;
    return await set("user", user);
  }

  Future<bool> setName(String v) async {
    name = v;
    return await set("name", name);
  }

  Future<bool> setMoeda(String v) async {
    moeda = v;
    return await set("moeda", moeda);
  }

  Future<bool> setDeviceId(String v) async {
    deviceId = v;
    return await set("deviceId", deviceId);
  }

  static Future<String> get(String name, [String ifEmpty = ""]) async {
    String value = ifEmpty;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      value = prefs.getString(name) ?? ifEmpty;
    } catch (e) {
      return ifEmpty;
    }
    return value;
  }

  static Future<bool> set(String name, String value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(name, value);
    } catch (e) {
      return false;
    }
    return true;
  }

  static Future<bool> clear() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await Preferences.instance.init();
    } catch (e) {
      return false;
    }
    return true;
  }
}
