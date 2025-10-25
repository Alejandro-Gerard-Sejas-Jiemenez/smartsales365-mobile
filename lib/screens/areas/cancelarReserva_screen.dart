import 'package:flutter/material.dart';
import '../../models/reserva.dart';
import '../../services/reserva_service.dart';

class CancelarReservaScreen extends StatefulWidget {
  @override
  _CancelarReservaScreenState createState() => _CancelarReservaScreenState();
}

class _CancelarReservaScreenState extends State<CancelarReservaScreen> {
  late Future<List<Reserva>> _reservasFuture;
  final ReservaService _reservaService = ReservaService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReservas();
  }

  void _loadReservas() {
    setState(() {
      _reservasFuture = _reservaService.fetchReservas();
    });
  }

  Future<void> _cancelarReserva(Reserva reserva) async {
    // Mostrar diálogo de confirmación
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Cancelación'),
          content: Text(
            '¿Estás seguro de que deseas cancelar la reserva de "${reserva.areaNombre ?? 'Área'}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Sí, Cancelar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    try {
      await _reservaService.cancelarReserva(reserva.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva cancelada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadReservas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar la reserva'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cancelar Reservas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[50]!, Colors.red[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Reserva>>(
          future: _reservasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error al cargar reservas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('${snapshot.error}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadReservas,
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No tienes reservas activas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Filtrar solo reservas que pueden ser canceladas
            final reservasCancelables = snapshot.data!
                .where((r) => r.puedeSerCancelada)
                .toList();

            if (reservasCancelables.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      'No tienes reservas cancelables',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: reservasCancelables.length,
              itemBuilder: (context, index) {
                final reserva = reservasCancelables[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                reserva.areaNombre ?? 'Área no disponible',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getEstadoColor(reserva.estado ?? ''),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                reserva.estado?.toUpperCase() ?? 'SIN ESTADO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${reserva.fechaReserva?.day ?? '-'}/${reserva.fechaReserva?.month ?? '-'}/${reserva.fechaReserva?.year ?? '-'}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        if (reserva.horaInicio != null &&
                            reserva.horaFin != null) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${reserva.horaInicio} - ${reserva.horaFin}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                        if (reserva.descripcion != null &&
                            reserva.descripcion!.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  reserva.descripcion!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: _isLoading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(Icons.cancel, color: Colors.white),
                            label: Text(
                              _isLoading ? 'Cancelando...' : 'Cancelar Reserva',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () => _cancelarReserva(reserva),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'finalizada':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
