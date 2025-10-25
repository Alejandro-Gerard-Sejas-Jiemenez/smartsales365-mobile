import '../../models/area_comun.dart';
import '../../models/reserva.dart';
import '../../services/area_comun_service.dart';
import '../../services/reserva_service.dart';
import 'package:flutter/material.dart';

class ReservarAreaScreen extends StatefulWidget {
  final AreaComun? area;
  final DateTime? fecha;
  const ReservarAreaScreen({Key? key, this.area, this.fecha}) : super(key: key);

  @override
  _ReservarAreaScreenState createState() => _ReservarAreaScreenState();
}

class _ReservarAreaScreenState extends State<ReservarAreaScreen> {
  late Future<List<AreaComun>> _areasFuture;
  final AreaComunService _areaService = AreaComunService();
  final ReservaService _reservaService = ReservaService();
  List<AreaComun> areas = [];
  AreaComun? selectedArea;
  DateTime? selectedDate;
  TimeOfDay? selectedHoraInicio;
  TimeOfDay? selectedHoraFin;
  String mensaje = '';
  bool _isLoading = false;
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _areasFuture = _areaService.fetchAreas();
    selectedArea = widget.area;
    selectedDate = widget.fecha;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reservar Área Común',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAreaSelector(),
              SizedBox(height: 16),
              _buildDateSelector(),
              SizedBox(height: 16),
              _buildTimeSelectors(),
              SizedBox(height: 16),
              _buildDescripcionField(),
              SizedBox(height: 24),
              _buildPriceDisplay(),
              SizedBox(height: 16),
              _buildReservarButton(),
              if (mensaje.isNotEmpty) _buildMensaje(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona el área:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        FutureBuilder<List<AreaComun>>(
          future: _areasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error al cargar áreas'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay áreas disponibles'));
            }
            areas = snapshot.data!;
            return DropdownButtonFormField<AreaComun>(
              value: selectedArea,
              items: areas
                  .where((area) => area.estado.toLowerCase() == 'disponible')
                  .map((area) {
                    return DropdownMenuItem<AreaComun>(
                      value: area,
                      child: Text(area.nombre),
                    );
                  })
                  .toList(),
              onChanged: (value) => setState(() => selectedArea = value),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona la fecha:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                selectedDate == null
                    ? 'No seleccionada'
                    : 'Fecha: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                style: TextStyle(fontSize: 15),
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text('Elegir Fecha'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSelectors() {
    return Column(
      children: [
        _buildTimeSelector(
          'Hora de inicio:',
          selectedHoraInicio,
          (time) => setState(() => selectedHoraInicio = time),
        ),
        SizedBox(height: 16),
        _buildTimeSelector(
          'Hora de fin:',
          selectedHoraFin,
          (time) => setState(() => selectedHoraFin = time),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay? selectedTime,
    Function(TimeOfDay) onTimeSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                selectedTime == null
                    ? 'No seleccionada'
                    : selectedTime.format(context),
                style: TextStyle(fontSize: 15),
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.access_time),
              label: Text('Elegir Hora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? TimeOfDay.now(),
                );
                if (picked != null) onTimeSelected(picked);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescripcionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción (opcional):',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Describe el motivo de la reserva...',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPriceDisplay() {
    if (selectedArea == null) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Precio total:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Bs ${selectedArea!.costoReserva}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservarButton() {
    bool canReserve =
        selectedArea != null &&
        selectedDate != null &&
        selectedHoraInicio != null &&
        selectedHoraFin != null &&
        !_isLoading;

    return Center(
      child: ElevatedButton(
        onPressed: canReserve ? _realizarReserva : null,
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text('Reservar', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMensaje() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Text(
          mensaje,
          style: TextStyle(
            color: mensaje.contains('Error') ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _realizarReserva() async {
    setState(() {
      _isLoading = true;
      mensaje = '';
    });

    try {
      // TODO: Reemplaza por el ID del residente logueado
      final int residenteId = 1;

      final reserva = Reserva(
        residenteId: residenteId,
        areaId: selectedArea!.id!,
        descripcion: _descripcionController.text,
        fechaReserva: selectedDate,
        horaInicio: _formatTimeOfDay(selectedHoraInicio!),
        horaFin: _formatTimeOfDay(selectedHoraFin!),
        estado: 'pendiente',
        montoTotal: selectedArea!.costoReserva,
      );

      await _reservaService.createReserva(reserva);

      setState(() {
        mensaje =
            'Reserva realizada exitosamente para ${selectedArea!.nombre} el ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
      });

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => route.isFirst);
      });
    } catch (e) {
      setState(() {
        mensaje = 'Error al realizar la reserva: $e';
      });

      // Si es error de token, redirige al login
      if (e.toString().contains('Token expirado')) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
