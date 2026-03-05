import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/cotizacion.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../widgets/widgets.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _storage = StorageService();
  List<Cotizacion> _all = [];
  String _filtroMes = 'Todas';

  final _fmt =
      NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
  final _dateFmt = DateFormat('dd/MM/yyyy HH:mm', 'es_CO');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _storage.loadCotizaciones();
    setState(() => _all = list);
  }

  List<String> get _meses {
    final s = <String>{};
    for (final c in _all) {
      s.add(DateFormat('MMMM yyyy', 'es_CO').format(c.fecha));
    }
    return ['Todas', ...s.toList()];
  }

  List<Cotizacion> get _filtered {
    if (_filtroMes == 'Todas') return _all;
    return _all.where((c) {
      return DateFormat('MMMM yyyy', 'es_CO').format(c.fecha) == _filtroMes;
    }).toList();
  }

  Future<void> _eliminar(Cotizacion c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar cotización',
            style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: Text('¿Eliminar cotización #${c.numero}? Esta acción no se puede deshacer.',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar',
                  style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (ok == true) {
      await _storage.deleteCotizacion(c.id);
      _load();
    }
  }

  void _verDetalle(Cotizacion c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => _DetalleSheet(c: c, fmt: _fmt, dateFmt: _dateFmt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      children: [
        // ── FILTROS ───────────────────────────────────────
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _meses.length,
            itemBuilder: (_, i) {
              final m = _meses[i];
              final active = m == _filtroMes;
              return Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _filtroMes = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.primary : AppTheme.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color:
                              active ? AppTheme.primary : AppTheme.border),
                    ),
                    child: Text(
                      m,
                      style: GoogleFonts.syne(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.black : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── LISTA ─────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📭', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 16),
                      Text('Sin cotizaciones',
                          style: GoogleFonts.syne(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text(
                        'Crea tu primera cotización\nen la pestaña Cotizar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _CotizacionTile(
                    c: filtered[i],
                    fmt: _fmt,
                    onTap: () => _verDetalle(filtered[i]),
                    onDelete: () => _eliminar(filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── TILE ─────────────────────────────────────────────────────────────────────
class _CotizacionTile extends StatelessWidget {
  final Cotizacion c;
  final NumberFormat fmt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CotizacionTile(
      {required this.c,
      required this.fmt,
      required this.onTap,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Cotización #${c.numero}',
                          style: GoogleFonts.syne(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yy').format(c.fecha),
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fmt.format(c.total),
                    style: GoogleFonts.syne(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (c.m2 > 0) '${c.m2} m²',
                      if (c.m3Calculado > 0)
                        '≈ ${c.m3Calculado.toStringAsFixed(2)} m³',
                      if (c.notas.isNotEmpty)
                        c.notas.length > 30
                            ? '${c.notas.substring(0, 30)}...'
                            : c.notas,
                    ].join('  ·  '),
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DETALLE BOTTOM SHEET ─────────────────────────────────────────────────────
class _DetalleSheet extends StatelessWidget {
  final Cotizacion c;
  final NumberFormat fmt;
  final DateFormat dateFmt;

  const _DetalleSheet(
      {required this.c, required this.fmt, required this.dateFmt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2))),
          ),

          Text('Cotización #${c.numero}',
              style: GoogleFonts.syne(
                  fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(dateFmt.format(c.fecha),
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),

          // Visualización m³
          if (c.m2 > 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoBox('Área', '${c.m2} m²'),
                  const Text('×',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 18)),
                  _infoBox('Grosor',
                      '${(c.alturaPoron * 100).toStringAsFixed(0)} cm'),
                  const Text('=',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 18)),
                  _infoBox('Volumen',
                      '${c.m3Calculado.toStringAsFixed(2)} m³',
                      highlight: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Rows
          TmCard(
            child: Column(
              children: [
                if (c.m2 > 0)
                  ResultRow(
                    label: '${c.m2} m²  ×  ${fmt.format(c.precioM2)}',
                    value: fmt.format(c.subTotalM2),
                  ),
                if (c.m3 > 0)
                  ResultRow(
                    label: '${c.m3} m³  ×  ${fmt.format(c.precioM3)}',
                    value: fmt.format(c.subTotalM3),
                  ),
                const Divider(color: AppTheme.border, height: 16),
                ResultRow(
                    label: 'TOTAL',
                    value: fmt.format(c.total),
                    isTotal: true),
              ],
            ),
          ),

          if (c.notas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Notas',
                style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Text(c.notas,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textPrimary)),
          ],

          const SizedBox(height: 20),
          TmButton(
            label: '🖨️  Imprimir / Compartir PDF',
            onPressed: () => PdfService.printCotizacion(c),
          ),
          const SizedBox(height: 10),
          TmButton(
            label: 'Cerrar',
            secondary: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value, {bool highlight = false}) =>
      Column(
        children: [
          Text(value,
              style: GoogleFonts.syne(
                fontSize: highlight ? 15 : 13,
                fontWeight: FontWeight.w800,
                color:
                    highlight ? AppTheme.primary : AppTheme.textPrimary,
              )),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary)),
        ],
      );
}
