class Venta {
  final int id;
  final String fechaVenta;
  final double totalVenta;

  Venta({
    required this.id,
    required this.fechaVenta,
    required this.totalVenta,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'] ?? 0,
      fechaVenta: json['fecha_venta'] ?? '',
      totalVenta: double.parse(json['total_venta']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha_venta': fechaVenta,
      'total_venta': totalVenta,
    };
  }
}

class DetalleVenta {
  final int id;
  final int ventaId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetalleVenta({
    required this.id,
    required this.ventaId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      id: json['id'] ?? 0,
      ventaId: json['venta'] ?? 0,
      productoId: json['producto'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      precioUnitario: double.parse(json['precio_unitario']?.toString() ?? '0'),
      subtotal: double.parse(json['subtotal']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venta': ventaId,
      'producto': productoId,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
