import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'models/cotizacion.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/cotizador_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/config_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_CO', null);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const TmApp());
}

class TmApp extends StatelessWidget {
  const TmApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'T&M Cotizador',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const MainShell(),
      );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _storage = StorageService();
  int _tab = 0;
  AppPrecios _precios = const AppPrecios();
  int _refreshKey = 0; // sube cada vez que se guarda una cotización

  @override
  void initState() {
    super.initState();
    _loadPrecios();
  }

  Future<void> _loadPrecios() async {
    final p = await _storage.loadPrecios();
    setState(() => _precios = p);
  }

  void _onPreciosUpdated(AppPrecios p) {
    setState(() => _precios = p);
  }

  void _onGuardado() {
    setState(() {
      _refreshKey++; // dispara didUpdateWidget en HomeScreen → recarga stats
      _tab = 2;      // va al historial
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['Inicio', 'Cotizar', 'Historial', 'Config'];
    final icons = [
      Icons.home_rounded,
      Icons.calculate_rounded,
      Icons.folder_rounded,
      Icons.settings_rounded,
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'T&M',
              style: GoogleFonts.syne(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              ['Inicio', 'Nueva Cotización', 'Historial', 'Configuración'][_tab],
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          HomeScreen(
            precios: _precios,
            onCotizar: () => setState(() => _tab = 1),
            onHistorial: () => setState(() => _tab = 2),
            refreshKey: _refreshKey, // ← pasa el contador
          ),
          CotizadorScreen(
            precios: _precios,
            onGuardado: _onGuardado,
          ),
          HistorialScreen(key: ValueKey(_refreshKey)),
          ConfigScreen(
            precios: _precios,
            onSaved: _onPreciosUpdated,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          items: List.generate(
            4,
            (i) => BottomNavigationBarItem(
              icon: Icon(icons[i]),
              label: labels[i],
            ),
          ),
        ),
      ),
    );
  }
}
