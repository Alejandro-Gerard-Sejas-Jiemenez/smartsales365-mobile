class Reserva {
  final int? id;
  final int residenteId;
  final int areaId;
  final String? descripcion;
  final DateTime? fechaReserva;
  final String? horaInicio;
  final String? horaFin;
  final String? estado;
  final double? montoTotal;

  // Para mostrar datos relacionados
  final String? residenteNombre;
  final String? areaNombre;

  Reserva({
    this.id,
    required this.residenteId,
    required this.areaId,
    this.descripcion,
    this.fechaReserva,
    this.horaInicio,
    this.horaFin,
    this.estado,
    this.montoTotal,
    this.residenteNombre,
    this.areaNombre,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    double? parseMonto(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Reserva(
      id: json['id'],
      residenteId: json['residente_id'] ?? json['residente']?['id'] ?? 0,
      areaId: json['area_id'] ?? json['area']?['id'] ?? 0,
      descripcion: json['descripcion'],
      fechaReserva: json['fecha_reserva'] != null
          ? DateTime.parse(json['fecha_reserva'])
          : null,
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      estado: json['estado'] ?? 'pendiente',
      montoTotal: parseMonto(json['monto_total']),
      residenteNombre: json['residente']?['nombre'],
      areaNombre: json['area']?['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'residente_id': residenteId,
      'area_id': areaId,
      'descripcion': descripcion ?? '',
      'fecha_reserva': fechaReserva?.toIso8601String().split('T')[0],
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'estado': estado ?? 'pendiente',
      'monto_total': montoTotal ?? 0.0,
    };
  }

  bool get puedeSerCancelada => estado == 'pendiente' || estado == 'confirmada';
}
