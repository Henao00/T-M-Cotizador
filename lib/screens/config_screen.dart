import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/cotizacion.dart';
import '../services/storage_service.dart';
import '../widgets/widgets.dart';

class ConfigScreen extends StatefulWidget {
  final AppPrecios precios;
  final void Function(AppPrecios) onSaved;

  const ConfigScreen({super.key, required this.precios, required this.onSaved});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _storage = StorageService();
  late TextEditingController _m2Ctrl;
  late TextEditingController _m3Ctrl;
  late TextEditingController _alturaCtrl;

  int _totalCots = 0;
  double _totalMonto = 0;

  final _fmt =
      NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _m2Ctrl =
        TextEditingController(text: widget.precios.precioM2.toStringAsFixed(0));
    _m3Ctrl =
        TextEditingController(text: widget.precios.precioM3.toStringAsFixed(0));
    _alturaCtrl = TextEditingController(
        text: widget.precios.alturaDefault.toString());
    _loadStats();
  }

  @override
  void dispose() {
    _m2Ctrl.dispose();
    _m3Ctrl.dispose();
    _alturaCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final list = await _storage.loadCotizaciones();
    setState(() {
      _totalCots = list.length;
      _totalMonto = list.fold(0, (a, c) => a + c.total);
    });
  }

  Future<void> _guardar() async {
    final m2 = double.tryParse(_m2Ctrl.text) ?? 0;
    final m3 = double.tryParse(_m3Ctrl.text) ?? 0;
    final alt = double.tryParse(_alturaCtrl.text) ?? 0.25;

    if (m2 <= 0) {
      _showSnack('⚠️  El precio de m² debe ser mayor a 0', error: true);
      return;
    }
    if (alt <= 0 || alt > 2) {
      _showSnack('⚠️  Altura inválida (ej: 0.25 para 25 cm)', error: true);
      return;
    }

    final nuevo = AppPrecios(precioM2: m2, precioM3: m3, alturaDefault: alt);
    await _storage.savePrecios(nuevo);
    widget.onSaved(nuevo);
    _showSnack('✅  Configuración guardada');
  }

  Future<void> _borrarTodo() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('⚠️  Borrar historial',
            style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: const Text(
            'Se eliminarán TODAS las cotizaciones guardadas.\nEsta acción no se puede deshacer.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Borrar todo',
                  style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (ok == true) {
      await _storage.deleteAll();
      _loadStats();
      _showSnack('🗑️  Historial borrado');
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.syne(fontWeight: FontWeight.w600)),
      backgroundColor: error ? AppTheme.danger : AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── PRECIOS ─────────────────────────────────────
          TmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💰  Precios de venta',
                    style: GoogleFonts.syne(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Modifica los precios base para cotizaciones',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 18),
                TmInput(
                  label: 'Precio por metro cuadrado (m²)',
                  prefix: '\$',
                  suffix: 'COP',
                  controller: _m2Ctrl,
                ),
                TmInput(
                  label: 'Precio por metro cúbico (m³)',
                  prefix: '\$',
                  suffix: 'COP',
                  controller: _m3Ctrl,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── ALTURA DEFAULT ────────────────────────────────
          TmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📐  Grosor de porón por defecto',
                    style: GoogleFonts.syne(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text(
                    'Se usará como valor inicial en cada cotización.\nPuede cambiarse en cada cotización individualmente.',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 18),
                TmInput(
                  label: 'Grosor en metros (ej: 0.25 = 25 cm)',
                  prefix: 'm',
                  controller: _alturaCtrl,
                ),
                // chips rápidos
                Wrap(
                  spacing: 8,
                  children: [0.20, 0.25, 0.30, 0.35, 0.40].map((h) {
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _alturaCtrl.text = h.toString()),
                      child: Chip(
                        label: Text(
                            '${(h * 100).toStringAsFixed(0)} cm',
                            style: GoogleFonts.syne(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                        backgroundColor: AppTheme.surface2,
                        side: const BorderSide(color: AppTheme.border),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          TmButton(
            label: '✅  Guardar configuración',
            onPressed: _guardar,
          ),
          const SizedBox(height: 24),

          // ── ESTADÍSTICAS ──────────────────────────────────
          TmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📊  Estadísticas',
                    style: GoogleFonts.syne(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                ResultRow(label: 'Total cotizaciones', value: '$_totalCots'),
                const Divider(color: AppTheme.border, height: 1),
                ResultRow(
                    label: 'Total facturado',
                    value: _fmt.format(_totalMonto),
                    valueColor: AppTheme.primary),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── ZONA DE PELIGRO ───────────────────────────────
          TmCard(
            borderColor: AppTheme.danger.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🗑️  Zona de peligro',
                    style: GoogleFonts.syne(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.danger)),
                const SizedBox(height: 4),
                const Text(
                    'Eliminar todos los datos guardados de la aplicación.',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                TmButton(
                  label: 'Borrar todo el historial',
                  danger: true,
                  onPressed: _borrarTodo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
