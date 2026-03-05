import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/cotizacion.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final AppPrecios precios;
  final VoidCallback onCotizar;
  final VoidCallback onHistorial;
  // Clave de refresco: cuando cambia, se recargan las stats
  final int refreshKey;

  const HomeScreen({
    super.key,
    required this.precios,
    required this.onCotizar,
    required this.onHistorial,
    required this.refreshKey,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  int _totalCotizaciones = 0;
  double _totalFacturado = 0;

  final _fmt =
      NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // Se llama también cuando el padre actualiza refreshKey
  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    final list = await _storage.loadCotizaciones();
    if (!mounted) return;
    setState(() {
      _totalCotizaciones = list.length;
      _totalFacturado = list.fold(0, (a, c) => a + c.total);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HERO ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo T&M
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/icon/logo.png',
                              width: 56,
                              height: 56,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox(
                                width: 56,
                                height: 56,
                                child: Center(
                                  child: Text('🏗️',
                                      style: TextStyle(fontSize: 40)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('T&M',
                                  style: GoogleFonts.syne(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                    height: 1,
                                  )),
                              Text('Cotizador de Porones',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Construcción · Colombia',
                            style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ── PRECIOS ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _priceCard(
                    'Precio m²', _fmt.format(widget.precios.precioM2), 'm²'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _priceCard(
                    'Precio m³', _fmt.format(widget.precios.precioM3), 'm³'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Altura default
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Text('📏', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Grosor de porón por defecto',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                    Text(
                      '${widget.precios.alturaDefault} m  '
                      '(${(widget.precios.alturaDefault * 100).toStringAsFixed(0)} cm)',
                      style: GoogleFonts.syne(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── ACCIONES ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  icon: '📋',
                  title: 'Nueva\nCotización',
                  subtitle: 'Calcular precios',
                  accentLeft: AppTheme.primary,
                  onTap: widget.onCotizar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  icon: '📁',
                  title: 'Ver\nHistorial',
                  subtitle: '$_totalCotizaciones guardadas',
                  accentLeft: AppTheme.success,
                  onTap: widget.onHistorial,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── ESTADÍSTICA ───────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumen general',
                    style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                        child: _statItem(
                            '📄', 'Cotizaciones', '$_totalCotizaciones')),
                    Container(
                        width: 1, height: 40, color: AppTheme.border),
                    Expanded(
                        child: _statItem('💰', 'Total facturado',
                            _fmt.format(_totalFacturado))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard(String label, String value, String unit) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.syne(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary)),
            Text('por $unit',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      );

  Widget _actionCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color accentLeft,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
            gradient: LinearGradient(
              colors: [accentLeft.withOpacity(0.05), Colors.transparent],
              begin: Alignment.centerLeft,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 10),
              Text(title,
                  style: GoogleFonts.syne(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );

  Widget _statItem(String icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.syne(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      );
}
