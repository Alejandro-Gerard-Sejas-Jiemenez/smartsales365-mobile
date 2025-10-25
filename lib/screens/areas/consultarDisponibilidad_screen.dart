import 'package:flutter/material.dart';
import '../../models/area_comun.dart';
import '../../services/area_comun_service.dart';

class ConsultarDisponibilidadScreen extends StatefulWidget {
  @override
  _ConsultarDisponibilidadScreenState createState() => _ConsultarDisponibilidadScreenState();
}

class _ConsultarDisponibilidadScreenState extends State<ConsultarDisponibilidadScreen> {
  late Future<List<AreaComun>> _areasFuture;
  final AreaComunService _areaService = AreaComunService();

  String search = '';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _areasFuture = _areaService.fetchAreas();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        title: Text('Consultar Disponibilidad', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF2196F3),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white, size: 28),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe3f2fd), Color(0xFFbbdefb)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar área...',
                  hintStyle: TextStyle(fontFamily: 'Montserrat', color: Colors.grey[700]),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF2196F3)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                  ),
                ),
                style: TextStyle(fontFamily: 'Montserrat'),
                onChanged: (value) => setState(() => search = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? 'Seleccione una fecha'
                          : 'Fecha: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today),
                    label: Text('Elegir Fecha'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(Duration(days: 1)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<AreaComun>>(
                future: _areasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar áreas'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay áreas disponibles'));
                  }
          List<AreaComun> filtered = snapshot.data!
            .where((a) =>
              (a.nombre.toLowerCase().contains(search.toLowerCase()) ||
                (a.descripcion ?? '').toLowerCase().contains(search.toLowerCase())) &&
              (a.estado ?? '').toLowerCase() == 'disponible')
            .toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final area = filtered[index];
                      // Aquí podrías consultar disponibilidad real si tu backend lo soporta
                      bool disponible = true;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: ListTile(
                          title: Text(area.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(area.descripcion ?? ''),
                              SizedBox(height: 4),
                              Text('Capacidad máxima: ${area.capacidadMaxima ?? '-'}', style: TextStyle(fontSize: 13)),
                              Text('Costo reserva: ${(area.costoReserva ?? 0) > 0 ? "Bs ${area.costoReserva}" : "Sin costo"}', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(disponible ? 'Disponible' : 'No disponible', style: TextStyle(color: Colors.white)),
                            backgroundColor: disponible ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned(
              left: 24,
              bottom: 0,
              child: FloatingActionButton.extended(
                heroTag: 'verReservas',
                onPressed: () {
                  Navigator.pushNamed(context, '/cancelarReservaArea');
                },
                icon: Icon(Icons.list_alt),
                label: Text('Mis Reservas', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.white)),
                backgroundColor: Color(0xFF283593),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: FloatingActionButton.extended(
                heroTag: 'crearReserva',
                onPressed: () {
                  Navigator.pushNamed(context, '/reservarArea');
                },
                icon: Icon(Icons.add),
                label: Text('Crear Reserva', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.white)),
                backgroundColor: Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      ),


    );
  }
}
