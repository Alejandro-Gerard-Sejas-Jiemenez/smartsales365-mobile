class Vehiculo {
  final int? id;
  final String marca;
  final String? modelo;
  final String? matricula;
  final String? color;
  final String tipo; // 'COCHE', 'MOTO', 'BICICLETA', 'OTRO'
  final String? imagenVehiculo;
  final int residenteId; // Solo ID, no objeto

  // Campos adicionales para IA (CU20)
  final DateTime? ultimaDeteccion;
  final String? estadoAcceso; // 'autorizado', 'no_autorizado', 'desconocido'

  Vehiculo({
    this.id,
    required this.marca,
    this.modelo,
    this.matricula,
    this.color,
    required this.tipo,
    this.imagenVehiculo,
    required this.residenteId,
    this.ultimaDeteccion,
    this.estadoAcceso,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      marca: json['marca'] ?? '',
      modelo: json['modelo'],
      matricula: json['matricula'],
      color: json['color'],
      tipo: json['tipo'] ?? 'COCHE',
      imagenVehiculo: json['imagen_vehiculo'],
      residenteId: json['residente'], // Solo el ID
      ultimaDeteccion: json['ultima_deteccion'] != null 
        ? DateTime.parse(json['ultima_deteccion']) 
        : null,
      estadoAcceso: json['estado_acceso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'matricula': matricula,
      'color': color,
      'tipo': tipo,
      'imagen_vehiculo': imagenVehiculo,
      'residente': residenteId,
      'ultima_deteccion': ultimaDeteccion?.toIso8601String(),
      'estado_acceso': estadoAcceso,
    };
  }

  Vehiculo copyWith({
    int? id,
    String? marca,
    String? modelo,
    String? matricula,
    String? color,
    String? tipo,
    String? imagenVehiculo,
    int? residenteId,
    DateTime? ultimaDeteccion,
    String? estadoAcceso,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      matricula: matricula ?? this.matricula,
      color: color ?? this.color,
      tipo: tipo ?? this.tipo,
      imagenVehiculo: imagenVehiculo ?? this.imagenVehiculo,
      residenteId: residenteId ?? this.residenteId,
      ultimaDeteccion: ultimaDeteccion ?? this.ultimaDeteccion,
      estadoAcceso: estadoAcceso ?? this.estadoAcceso,
    );
  }

  // Propiedades de conveniencia
  String get tipoTexto {
    switch (tipo) {
      case 'COCHE': return 'Coche';
      case 'MOTO': return 'Moto';
      case 'BICICLETA': return 'Bicicleta';
      case 'OTRO': return 'Otro';
      default: return tipo;
    }
  }

  String get descripcionCompleta {
    final parts = [marca, modelo, matricula].where((p) => p?.isNotEmpty == true);
    return parts.join(' - ');
  }

  String get estadoAccesoTexto {
    switch (estadoAcceso) {
      case 'autorizado': return 'Autorizado';
      case 'no_autorizado': return 'No Autorizado';
      case 'desconocido': return 'Desconocido';
      default: return 'Sin estado';
    }
  }

  @override
  String toString() => descripcionCompleta;
}