import 'package:flutter/material.dart';
import '../../models/factura.dart';
import '../../services/factura_service.dart';
import '../../services/login_services.dart';

class GenerarServiciosScreen extends StatefulWidget {
  @override
  _GenerarServiciosScreenState createState() => _GenerarServiciosScreenState();
}

class _GenerarServiciosScreenState extends State<GenerarServiciosScreen> {
  final FacturaService _facturaService = FacturaService();
  final LoginService _loginService = LoginService();

  // Controladores para el formulario
  final _descripcionController = TextEditingController();
  final _fechaLimiteController = TextEditingController();

  // Variables de estado
  bool _isLoading = true;
  bool _isCreating = false;
  String _mensaje = '';

  // Datos
  List<ConceptoPago> _conceptos = [];
  Factura? _facturaActual;
  List<DetalleFactura> _detalles = [];
  int? _residenteId;

  // Para agregar detalles
  int? _conceptoSeleccionado;
  bool _agregandoDetalle = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);

    try {
      // Obtener usuario actual
      final userData = await _loginService.getCurrentUser();
      if (userData != null) {
        _residenteId = userData['residente'] ?? 1;
      }

      // Cargar conceptos de pago
      await _cargarConceptos();
    } catch (e) {
      _showError('Error al inicializar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarConceptos() async {
    try {
      final conceptos = await _facturaService.fetchConceptos();
      setState(() => _conceptos = conceptos);
    } catch (e) {
      _showError('Error al cargar conceptos: $e');
    }
  }

  Future<void> _crearFactura() async {
    if (_descripcionController.text.trim().isEmpty) {
      _showError('La descripción es obligatoria');
      return;
    }

    setState(() => _isCreating = true);

    try {
      final nuevaFactura = Factura(
        residenteId: _residenteId ?? 1,
        descripcion: _descripcionController.text.trim(),
        montoTotal: 0.0, // El backend lo actualizará, no se envía en toJson()
        estado: 'pendiente', // Siempre pendiente
        tipoFactura: 'servicio',
        fechaLimite: _fechaLimiteController.text.isNotEmpty
            ? _fechaLimiteController.text
            : null,
      );

      final facturaCreada = await _facturaService.crearFactura(nuevaFactura);

      setState(() {
        _facturaActual = facturaCreada;
        _mensaje = '✅ Factura #${facturaCreada.id} creada exitosamente';
      });

      await _cargarDetalles();
    } catch (e) {
      _showError('Error al crear factura: $e');
    } finally {
      setState(() => _isCreating = false);
    }
  }

  Future<void> _agregarDetalle() async {
    if (_conceptoSeleccionado == null || _facturaActual == null) return;

    setState(() => _agregandoDetalle = true);

    try {
      await _facturaService.agregarDetalle(
        facturaId: _facturaActual!.id!,
        conceptoId: _conceptoSeleccionado!,
        reservaId: null, // Siempre null
      );

      setState(() {
        _conceptoSeleccionado = null;
        _mensaje = '✅ Servicio agregado exitosamente';
      });

      await _cargarDetalles();
    } catch (e) {
      _showError('Error al agregar servicio: $e');
    } finally {
      setState(() => _agregandoDetalle = false);
    }
  }

  Future<void> _eliminarDetalle(int detalleId) async {
    try {
      await _facturaService.eliminarDetalle(detalleId);
      setState(() => _mensaje = '✅ Servicio eliminado');
      await _cargarDetalles();
    } catch (e) {
      _showError('Error al eliminar servicio: $e');
    }
  }

  Future<void> _cargarDetalles() async {
    if (_facturaActual?.id == null) return;

    try {
      final detalles = await _facturaService.fetchDetalles(_facturaActual!.id!);
      final facturaActualizada = await _facturaService.getFactura(
        _facturaActual!.id!,
      );

      setState(() {
        _detalles = detalles;
        _facturaActual = facturaActualizada;
      });
    } catch (e) {
      _showError('Error al cargar detalles: $e');
    }
  }

  void _nuevaFactura() {
    setState(() {
      _facturaActual = null;
      _detalles = [];
      _descripcionController.clear();
      _fechaLimiteController.clear();
      _conceptoSeleccionado = null;
      _mensaje = '';
    });
  }

  void _showError(String error) {
    setState(() => _mensaje = '❌ $error');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (fecha != null) {
      _fechaLimiteController.text =
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Generar Factura'),
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _facturaActual != null
              ? 'Factura #${_facturaActual!.id}'
              : 'Nueva Factura',
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          if (_facturaActual != null)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _nuevaFactura,
              tooltip: 'Nueva Factura',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_mensaje.isNotEmpty) _buildMensaje(),
            _buildFormularioFactura(),
            if (_facturaActual != null) ...[
              SizedBox(height: 20),
              _buildAgregarServicios(),
              SizedBox(height: 20),
              _buildDetallesFactura(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMensaje() {
    final isError = _mensaje.contains('❌');
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red[200]! : Colors.green[200]!,
        ),
      ),
      child: Text(
        _mensaje,
        style: TextStyle(
          color: isError ? Colors.red[700] : Colors.green[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFormularioFactura() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _facturaActual != null
                  ? 'Información de la Factura'
                  : 'Crear Nueva Factura',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Descripción
            TextField(
              controller: _descripcionController,
              enabled: _facturaActual == null,
              decoration: InputDecoration(
                labelText: 'Descripción *',
                border: OutlineInputBorder(),
                hintText: 'Ej: Servicios del mes de Enero 2024',
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16),

            // Fecha límite
            TextField(
              controller: _fechaLimiteController,
              enabled: _facturaActual == null,
              decoration: InputDecoration(
                labelText: 'Fecha límite de pago',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: _facturaActual == null ? _seleccionarFecha : null,
                ),
              ),
              readOnly: true,
              onTap: _facturaActual == null ? _seleccionarFecha : null,
            ),

            // Mostrar total si existe la factura
            if (_facturaActual != null) ...[
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MONTO TOTAL:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Bs ${_facturaActual!.montoTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 20),

            // Botón crear
            if (_facturaActual == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _crearFactura,
                  child: _isCreating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Creando...'),
                          ],
                        )
                      : Text('Crear Factura', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgregarServicios() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agregar Servicios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: _conceptoSeleccionado,
              decoration: InputDecoration(
                labelText: 'Seleccionar concepto de pago',
                border: OutlineInputBorder(),
              ),
              hint: Text('Seleccione un concepto...'),
              items: _conceptos.map((concepto) {
                return DropdownMenuItem<int>(
                  value: concepto.id,
                  child: Text(
                    '${concepto.nombre} - Bs ${concepto.monto.toStringAsFixed(2)}',
                  ),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _conceptoSeleccionado = value),
            ),
            SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _conceptoSeleccionado != null && !_agregandoDetalle
                    ? _agregarDetalle
                    : null,
                child: _agregandoDetalle
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Agregando...'),
                        ],
                      )
                    : Text('Agregar Servicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetallesFactura() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Servicios en la Factura',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  '(${_detalles.length} servicios)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 16),

            if (_detalles.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No hay servicios agregados',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _detalles.map((detalle) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Icon(Icons.receipt, color: Colors.blue[700]),
                      ),
                      title: Text(detalle.conceptoNombre ?? 'Servicio'),
                      subtitle: Text('Concepto de pago'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bs ${detalle.monto.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirmar eliminación'),
                                  content: Text(
                                    '¿Está seguro de eliminar este servicio?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _eliminarDetalle(detalle.id!);
                                      },
                                      child: Text('Eliminar'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _fechaLimiteController.dispose();
    super.dispose();
  }
}
