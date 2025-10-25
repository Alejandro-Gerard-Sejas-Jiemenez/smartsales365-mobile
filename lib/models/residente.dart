class Residente {
  final int? id;
  final String nombre;
  final String apellidos;
  final DateTime? fechaNacimiento;
  final String? telefono;
  final String? correo;
  final String dni;
  final String sexo; // 'M' o 'F'
  final String tipo; // 'PROPIETARIO', 'INQUILINO', etc.
  final int? residenciaId; // Solo el ID, no el objeto
  final bool activo;
  final DateTime? fechaCreacion;
  final DateTime? actualizado;

  Residente({
    this.id,
    required this.nombre,
    required this.apellidos,
    this.fechaNacimiento,
    this.telefono,
    this.correo,
    required this.dni,
    required this.sexo,
    required this.tipo,
    this.residenciaId,
    this.activo = true,
    this.fechaCreacion,
    this.actualizado,
  });

  factory Residente.fromJson(Map<String, dynamic> json) {
    return Residente(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] != null 
        ? DateTime.parse(json['fecha_nacimiento']) 
        : null,
      telefono: json['telefono'],
      correo: json['correo'],
      dni: json['dni'] ?? '',
      sexo: json['sexo'] ?? 'M',
      tipo: json['tipo'] ?? 'PROPIETARIO',
      residenciaId: json['residencia'], // Solo el ID
      activo: json['activo'] ?? true,
      fechaCreacion: json['fecha_creacion'] != null 
        ? DateTime.parse(json['fecha_creacion']) 
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
      'apellidos': apellidos,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String().split('T')[0],
      'telefono': telefono,
      'correo': correo,
      'dni': dni,
      'sexo': sexo,
      'tipo': tipo,
      'residencia': residenciaId,
      'activo': activo,
    };
  }

  Residente copyWith({
    int? id,
    String? nombre,
    String? apellidos,
    DateTime? fechaNacimiento,
    String? telefono,
    String? correo,
    String? dni,
    String? sexo,
    String? tipo,
    int? residenciaId,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? actualizado,
  }) {
    return Residente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      dni: dni ?? this.dni,
      sexo: sexo ?? this.sexo,
      tipo: tipo ?? this.tipo,
      residenciaId: residenciaId ?? this.residenciaId,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      actualizado: actualizado ?? this.actualizado,
    );
  }

  // Propiedades de conveniencia
  String get nombreCompleto => '$nombre $apellidos';
  
  String get sexoTexto => sexo == 'M' ? 'Masculino' : 'Femenino';
  
  String get tipoTexto {
    switch (tipo) {
      case 'PROPIETARIO': return 'Propietario';
      case 'INQUILINO': return 'Inquilino';
      case 'FAMILIAR_PROPIETARIO': return 'Familiar Propietario';
      case 'FAMILIAR_INQUILINO': return 'Familiar Inquilino';
      case 'OTRO': return 'Otro';
      default: return tipo;
    }
  }

  @override
  String toString() => nombreCompleto;
}