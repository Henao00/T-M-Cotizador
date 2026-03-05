class Cotizacion {
  final String id;
  final DateTime fecha;
  final int numero;
  final double m2;
  final double m3;
  final double alturaPoron; // metros
  final double m3Calculado; // m2 * alturaPoron
  final double precioM2;
  final double precioM3;
  final double subTotalM2;
  final double subTotalM3;
  final double total;
  final String notas;

  Cotizacion({
    required this.id,
    required this.fecha,
    required this.numero,
    required this.m2,
    required this.m3,
    required this.alturaPoron,
    required this.m3Calculado,
    required this.precioM2,
    required this.precioM3,
    required this.subTotalM2,
    required this.subTotalM3,
    required this.total,
    required this.notas,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha': fecha.toIso8601String(),
        'numero': numero,
        'm2': m2,
        'm3': m3,
        'alturaPoron': alturaPoron,
        'm3Calculado': m3Calculado,
        'precioM2': precioM2,
        'precioM3': precioM3,
        'subTotalM2': subTotalM2,
        'subTotalM3': subTotalM3,
        'total': total,
        'notas': notas,
      };

  factory Cotizacion.fromJson(Map<String, dynamic> json) => Cotizacion(
        id: json['id'],
        fecha: DateTime.parse(json['fecha']),
        numero: json['numero'],
        m2: (json['m2'] as num).toDouble(),
        m3: (json['m3'] as num).toDouble(),
        alturaPoron: (json['alturaPoron'] as num).toDouble(),
        m3Calculado: (json['m3Calculado'] as num).toDouble(),
        precioM2: (json['precioM2'] as num).toDouble(),
        precioM3: (json['precioM3'] as num).toDouble(),
        subTotalM2: (json['subTotalM2'] as num).toDouble(),
        subTotalM3: (json['subTotalM3'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        notas: json['notas'] ?? '',
      );
}

class AppPrecios {
  final double precioM2;
  final double precioM3;
  final double alturaDefault;

  const AppPrecios({
    this.precioM2 = 22000,
    this.precioM3 = 0,
    this.alturaDefault = 0.25,
  });

  AppPrecios copyWith({double? precioM2, double? precioM3, double? alturaDefault}) =>
      AppPrecios(
        precioM2: precioM2 ?? this.precioM2,
        precioM3: precioM3 ?? this.precioM3,
        alturaDefault: alturaDefault ?? this.alturaDefault,
      );

  Map<String, dynamic> toJson() => {
        'precioM2': precioM2,
        'precioM3': precioM3,
        'alturaDefault': alturaDefault,
      };

  factory AppPrecios.fromJson(Map<String, dynamic> json) => AppPrecios(
        precioM2: (json['precioM2'] as num).toDouble(),
        precioM3: (json['precioM3'] as num).toDouble(),
        alturaDefault: (json['alturaDefault'] as num).toDouble(),
      );
}
