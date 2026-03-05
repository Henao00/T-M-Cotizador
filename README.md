# 📱 T&M — Cotizador de Porones
**App móvil para Android & iOS** | Flutter

---

## 🚀 Cómo instalar y correr

### Requisitos
- Flutter SDK 3.x → https://flutter.dev/docs/get-started/install
- Android Studio o VS Code con extensión Flutter
- Para iOS: macOS + Xcode

### Pasos

```bash
# 1. Clona o descomprime el proyecto
cd tm_porones

# 2. Instala dependencias
flutter pub get

# 3. Corre en dispositivo/emulador
flutter run

# 4. Compilar APK para Android
flutter build apk --release

# 5. Compilar para iOS
flutter build ios --release
```

El APK queda en: `build/app/outputs/flutter-apk/app-release.apk`

---

## ✨ Funcionalidades

| Módulo | Descripción |
|--------|-------------|
| 🏠 Inicio | Panel con precios actuales y acceso rápido |
| 📋 Cotizar | Ingresa m², grosor del porón → calcula m³ automáticamente |
| 📦 Conversión m² → m³ | `m³ = m² × grosor del porón` con chips de selección rápida |
| 📁 Historial | Lista todas las cotizaciones con filtros por mes |
| 🖨️ PDF | Genera e imprime/comparte cotización profesional |
| ⚙️ Config | Precios editables, grosor por defecto, estadísticas |

---

## 📐 Fórmula de conversión

```
Volumen (m³) = Área de plancha (m²) × Grosor del porón (m)

Ejemplo:
  Plancha de 50 m²
  Porón de 25 cm (0.25 m)
  → 50 × 0.25 = 12.5 m³ de porones
```

El grosor es configurable por cotización (chips: 20, 25, 30, 35, 40 cm)
y también tiene un valor por defecto editable en Configuración.

---

## 📦 Dependencias principales

```yaml
shared_preferences   # almacenamiento local offline
google_fonts         # tipografías Syne + DM Sans
pdf + printing       # generación y compartir PDF
intl                 # formato de moneda COP
uuid                 # IDs únicos por cotización
share_plus           # compartir por WhatsApp, email, etc.
```

---

## 🔮 Expansión futura a la nube

El servicio `lib/services/storage_service.dart` está diseñado para ser
reemplazado o extendido con Firebase Firestore o Supabase sin tocar
las pantallas. Solo se cambia la implementación del servicio.

---

## 🏗️ Estructura del proyecto

```
lib/
  main.dart                  ← entrada y navegación principal
  theme/app_theme.dart       ← colores y estilos T&M
  models/cotizacion.dart     ← modelos de datos
  services/
    storage_service.dart     ← persistencia local (SharedPreferences)
    pdf_service.dart         ← generación de PDF profesional
  widgets/widgets.dart       ← componentes reutilizables
  screens/
    home_screen.dart         ← pantalla de inicio
    cotizador_screen.dart    ← módulo de cotización
    historial_screen.dart    ← historial con filtros
    config_screen.dart       ← configuración de precios
```
