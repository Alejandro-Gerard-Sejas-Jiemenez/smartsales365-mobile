class Visitor {
  final int? id;
  final int residenteId;
  final String nombre;
  final String apellido;
  final String dni;
  final String genero; // 'M' o 'F'
  final DateTime? fechaLlegada;

  Visitor({
    this.id,
    required this.residenteId,
    required this.nombre,
    required this.apellido,
    required this.dni,
    required this.genero,
    this.fechaLlegada,
  });
}
