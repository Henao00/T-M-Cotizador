import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../models/cotizacion.dart';
import '../services/storage_service.dart';
import '../widgets/widgets.dart';

class CotizadorScreen extends StatefulWidget {
  final AppPrecios precios;
  final VoidCallback onGuardado;

  const CotizadorScreen(
      {super.key, required this.precios, required this.onGuardado});

  @override
  State<CotizadorScreen> createState() => _CotizadorScreenState();
}

class _CotizadorScreenState extends State<CotizadorScreen> {
  final _m2Ctrl = TextEditingController();
  final _m3Ctrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();
  final _storage = StorageService();

  double _alturaPoron = 0.25;
  bool _guardando = false;

  final _fmt =
      NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _alturaPoron = widget.precios.alturaDefault;
    _alturaCtrl.text = _alturaPoron.toString();
  }

  @override
  void dispose() {
    _m2Ctrl.dispose();
    _m3Ctrl.dispose();
    _notasCtrl.dispose();
    _alturaCtrl.dispose();
    super.dispose();
  }

  double get _m2 => double.tryParse(_m2Ctrl.text) ?? 0;
  double get _m3 => double.tryParse(_m3Ctrl.text) ?? 0;
  double get _m3Calculado => _m2 * _alturaPoron;
  double get _subM2 => _m2 * widget.precios.precioM2;
  double get _subM3 => _m3 * widget.precios.precioM3;
  double get _total => _subM2 + _subM3;

  void _onAlturaChanged(String v) {
    setState(() {
      _alturaPoron = double.tryParse(v) ?? _alturaPoron;
    });
  }

  Future<void> _guardar() async {
    if (_m2 == 0 && _m3 == 0) {
      _showSnack('⚠️  Ingresa al menos una cantidad', error: true);
      return;
    }
    setState(() => _guardando = true);
    final num = await _storage.nextNumero();
    final cot = Cotizacion(
      id: const Uuid().v4(),
      fecha: DateTime.now(),
      numero: num,
      m2: _m2,
      m3: _m3,
      alturaPoron: _alturaPoron,
      m3Calculado: _m3Calculado,
      precioM2: widget.precios.precioM2,
      precioM3: widget.precios.precioM3,
      subTotalM2: _subM2,
      subTotalM3: _subM3,
      total: _total,
      notas: _notasCtrl.text.trim(),
    );
    await _storage.saveCotizacion(cot);
    setState(() => _guardando = false);
    _limpiar();
    widget.onGuardado();
    _showSnack('✅  Cotización #$num guardada');
  }

  void _limpiar() {
    _m2Ctrl.clear();
    _m3Ctrl.clear();
    _notasCtrl.clear();
    setState(() {});
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.syne(fontWeight: FontWeight.w600)),
      backgroundColor:
          error ? AppTheme.danger : AppTheme.success,
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
          // ── FECHA ─────────────────────────────────────────
          Text(
            DateFormat("EEEE, d 'de' MMMM yyyy", 'es_CO')
                .format(DateTime.now()),
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),

          // ── SECCIÓN m² + CONVERSIÓN ───────────────────────
          const SectionLabel('📏  Metro cuadrado (m²)'),
          TmInput(
            label: 'Área de la plancha',
            prefix: 'm²',
            hint: '0.00',
            controller: _m2Ctrl,
            onChanged: (_) => setState(() {}),
          ),

          // Grosor del porón
          const SectionLabel('📐  Grosor del porón'),
          TmInput(
            label: 'Alto del porón en metros (ej: 0.25 = 25 cm)',
            prefix: 'm',
            hint: '0.25',
            controller: _alturaCtrl,
            onChanged: _onAlturaChanged,
          ),

          // Chips de acceso rápido de altura
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [0.20, 0.25, 0.30, 0.35, 0.40]
                .map((h) => _heightChip(h))
                .toList(),
          ),
          const SizedBox(height: 20),

          // ── VISUALIZACIÓN m³ CALCULADO ────────────────────
          if (_m2 > 0) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.12),
                    AppTheme.primaryDark.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📦  Volumen estimado de porón',
                      style: GoogleFonts.syne(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                          letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _calcRow('Área', '${_m2} m²'),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('×',
                            style: TextStyle(
                                fontSize: 20,
                                color: AppTheme.textSecondary)),
                      ),
                      Expanded(
                        child: _calcRow(
                            'Grosor',
                            '${_alturaPoron} m\n'
                                '(${(_alturaPoron * 100).toStringAsFixed(0)} cm)'),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('=',
                            style: TextStyle(
                                fontSize: 20,
                                color: AppTheme.textSecondary)),
                      ),
                      Expanded(
                        child: _calcRow(
                          'Volumen',
                          '${_m3Calculado.toStringAsFixed(2)} m³',
                          highlight: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: AppTheme.border, height: 1),
                  const SizedBox(height: 10),
                  Text(
                    'Esta plancha de $_m2 m² con porón de '
                    '${(_alturaPoron * 100).toStringAsFixed(0)} cm de grosor '
                    'requiere aproximadamente '
                    '${_m3Calculado.toStringAsFixed(2)} m³ de porones.',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── SECCIÓN m³ ADICIONAL ──────────────────────────
          const SectionLabel('📦  Metro cúbico adicional (m³)'),
          TmInput(
            label: 'Cantidad de m³ extra (opcional)',
            prefix: 'm³',
            hint: '0.00',
            controller: _m3Ctrl,
            onChanged: (_) => setState(() {}),
          ),

          // ── NOTAS ─────────────────────────────────────────
          const SectionLabel('📝  Notas'),
          TmInput(
            label: 'Cliente, dirección, observaciones...',
            controller: _notasCtrl,
            keyboardType: TextInputType.text,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 4),

          // ── RESUMEN ───────────────────────────────────────
          TmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Resumen',
                        style: GoogleFonts.syne(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('COP',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppTheme.border, height: 1),
                if (_m2 > 0)
                  ResultRow(
                    label: '${_m2} m²  ×  ${_fmt.format(widget.precios.precioM2)}',
                    value: _fmt.format(_subM2),
                  ),
                if (_m3 > 0)
                  ResultRow(
                    label: '${_m3} m³  ×  ${_fmt.format(widget.precios.precioM3)}',
                    value: _fmt.format(_subM3),
                  ),
                if (_m2 == 0 && _m3 == 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Ingresa cantidades para ver el total',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary)),
                  ),
                const Divider(color: AppTheme.border, height: 1),
                ResultRow(
                  label: 'TOTAL A PAGAR',
                  value: _fmt.format(_total),
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          TmButton(
            label: _guardando ? 'Guardando...' : '💾  Guardar Cotización',
            onPressed: _guardando ? null : _guardar,
          ),
          const SizedBox(height: 10),
          TmButton(
            label: '🗑️  Limpiar formulario',
            secondary: true,
            onPressed: _limpiar,
          ),
        ],
      ),
    );
  }

  Widget _heightChip(double h) {
    final selected = _alturaPoron == h;
    return GestureDetector(
      onTap: () {
        setState(() {
          _alturaPoron = h;
          _alturaCtrl.text = h.toString();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.border),
        ),
        child: Text(
          '${(h * 100).toStringAsFixed(0)} cm',
          style: GoogleFonts.syne(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.black : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _calcRow(String label, String value,
      {bool highlight = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.syne(
              fontSize: highlight ? 17 : 14,
              fontWeight: FontWeight.w800,
              color: highlight ? AppTheme.primary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary)),
        ],
      );
}
