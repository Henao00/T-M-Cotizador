import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cotizacion.dart';

class StorageService {
  static const _keyCotizaciones = 'cotizaciones_v1';
  static const _keyPrecios = 'precios_v1';
  static const _keyContador = 'contador_v1';

  // ─── PRECIOS ───────────────────────────────────────────
  Future<AppPrecios> loadPrecios() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPrecios);
    if (raw == null) return const AppPrecios();
    return AppPrecios.fromJson(jsonDecode(raw));
  }

  Future<void> savePrecios(AppPrecios precios) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPrecios, jsonEncode(precios.toJson()));
  }

  // ─── COTIZACIONES ──────────────────────────────────────
  Future<List<Cotizacion>> loadCotizaciones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCotizaciones);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Cotizacion.fromJson(e)).toList();
  }

  Future<void> saveCotizacion(Cotizacion c) async {
    final list = await loadCotizaciones();
    list.insert(0, c);
    await _persistList(list);
  }

  Future<void> deleteCotizacion(String id) async {
    final list = await loadCotizaciones();
    list.removeWhere((c) => c.id == id);
    await _persistList(list);
  }

  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCotizaciones);
    await prefs.remove(_keyContador);
  }

  Future<void> _persistList(List<Cotizacion> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyCotizaciones, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  // ─── CONTADOR ─────────────────────────────────────────
  Future<int> nextNumero() async {
    final prefs = await SharedPreferences.getInstance();
    final n = (prefs.getInt(_keyContador) ?? 0) + 1;
    await prefs.setInt(_keyContador, n);
    return n;
  }
}
