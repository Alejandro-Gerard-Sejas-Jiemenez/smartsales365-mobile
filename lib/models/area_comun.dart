class AreaComun {
  final int? id;
  final String nombre;
  final String? descripcion;
  final bool requiereReserva;
  final int? capacidadMaxima;
  final double? costoReserva;
  final int? tiempoReservaMinima;
  final int? tiempoReservaMaxima;
  final String estado;
  final List<int>? reglasIds;
  final List<dynamic>? reglas;
  final List<dynamic>? horarios;
  final bool activo;
  final DateTime? creado;
  final DateTime? actualizado;

  AreaComun({
    this.id,
    required this.nombre,
    this.descripcion,
    this.requiereReserva = false,
    this.capacidadMaxima,
    this.costoReserva,
    this.tiempoReservaMinima,
    this.tiempoReservaMaxima,
    this.estado = 'disponible',
    this.reglasIds,
    this.reglas,
    this.horarios,
    this.activo = true,
    this.creado,
    this.actualizado,
  });

  factory AreaComun.fromJson(Map<String, dynamic> json) {
    return AreaComun(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      requiereReserva: json['requiere_reserva'] ?? false,
      capacidadMaxima: json['capacidad_maxima'],
      costoReserva: json['costo_reserva'] != null
          ? double.parse(json['costo_reserva'].toString())
          : null,
      tiempoReservaMinima: json['tiempo_reserva_minima'],
      tiempoReservaMaxima: json['tiempo_reserva_maxima'],
      estado: json['estado'] ?? 'disponible',
      reglasIds: (json['reglas_ids'] as List?)?.map((e) => e as int).toList(),
      reglas: json['reglas'] as List?,
      horarios: json['horarios'] as List?,
      activo: json['activo'] ?? true,
      creado: json['creado'] != null
          ? DateTime.parse(json['creado'])
          : null,
      actualizado: json['actualizado'] != null
          ? DateTime.parse(json['actualizado'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'requiere_reserva': requiereReserva,
      'capacidad_maxima': capacidadMaxima,
      'costo_reserva': costoReserva,
      'tiempo_reserva_minima': tiempoReservaMinima,
      'tiempo_reserva_maxima': tiempoReservaMaxima,
      'estado': estado,
      'reglas_ids': reglasIds,
      'activo': activo,
    };
  }

  AreaComun copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    bool? requiereReserva,
    int? capacidadMaxima,
    double? costoReserva,
    int? tiempoReservaMinima,
    int? tiempoReservaMaxima,
    String? estado,
    List<int>? reglasIds,
    List<dynamic>? reglas,
    List<dynamic>? horarios,
    bool? activo,
    DateTime? creado,
    DateTime? actualizado,
  }) {
    return AreaComun(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      requiereReserva: requiereReserva ?? this.requiereReserva,
      capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
      costoReserva: costoReserva ?? this.costoReserva,
      tiempoReservaMinima: tiempoReservaMinima ?? this.tiempoReservaMinima,
      tiempoReservaMaxima: tiempoReservaMaxima ?? this.tiempoReservaMaxima,
      estado: estado ?? this.estado,
      reglasIds: reglasIds ?? this.reglasIds,
      reglas: reglas ?? this.reglas,
      horarios: horarios ?? this.horarios,
      activo: activo ?? this.activo,
      creado: creado ?? this.creado,
      actualizado: actualizado ?? this.actualizado,
    );
  }

  // Propiedades de conveniencia
  String get estadoTexto {
    switch (estado) {
      case 'disponible':
        return 'Disponible';
      case 'mantenimiento':
        return 'En Mantenimiento';
      case 'cerrado':
        return 'Cerrado';
      default:
        return estado;
    }
  }

  bool get estaDisponible => estado == 'disponible' && activo;

  String get costoTexto => costoReserva != null
      ? 'Bs. ${costoReserva!.toStringAsFixed(2)}'
      : 'Gratis';

  String get tiempoReservaTexto {
    if (tiempoReservaMinima != null && tiempoReservaMaxima != null) {
      final minHoras = (tiempoReservaMinima! / 60).toStringAsFixed(1);
      final maxHoras = (tiempoReservaMaxima! / 60).toStringAsFixed(1);
      return '$minHoras - $maxHoras horas';
    }
    return 'Sin restricciones';
  }

  @override
  String toString() => nombre;
}
