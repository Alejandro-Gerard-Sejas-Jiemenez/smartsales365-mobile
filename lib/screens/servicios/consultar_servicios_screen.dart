import 'package:flutter/material.dart';
import '../../models/factura.dart';
import '../../services/factura_service.dart';
import 'detalle_factura_screen.dart';
import 'pagar_factura_screen.dart';

class ConsultarServiciosScreen extends StatefulWidget {
  @override
  _ConsultarServiciosScreenState createState() =>
      _ConsultarServiciosScreenState();
}

class _ConsultarServiciosScreenState extends State<ConsultarServiciosScreen> {
  final FacturaService _facturaService = FacturaService();
  List<Factura> _facturas = [];
  bool _isLoading = true;
  String? _error;
  String _filtroEstado = 'todas';

  @override
  void initState() {
    super.initState();
    _cargarFacturas();
  }

  Future<void> _cargarFacturas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final facturas = await _facturaService.fetchFacturas();
      setState(() => _facturas = facturas);
    } catch (e) {
      setState(() => _error = e.toString());
      if (e.toString().contains('Token expirado')) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Factura> get _facturasFiltradas {
    if (_filtroEstado == 'todas') return _facturas;
    return _facturas.where((f) => f.estado == _filtroEstado).toList();
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagada':
        return Colors.green;
      case 'vencida':
        return Colors.red;
      case 'cancelada':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagada':
        return Icons.check_circle;
      case 'vencida':
        return Icons.error;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Facturas'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _cargarFacturas),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/generar-servicios',
              ).then((_) => _cargarFacturas());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltros(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildError()
                : _facturasFiltradas.isEmpty
                ? _buildEstadoVacio()
                : _buildListaFacturas(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Text('Filtrar por: ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filtroEstado,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                DropdownMenuItem(value: 'todas', child: Text('Todas')),
                DropdownMenuItem(value: 'pendiente', child: Text('Pendientes')),
                DropdownMenuItem(value: 'pagada', child: Text('Pagadas')),
                DropdownMenuItem(value: 'vencida', child: Text('Vencidas')),
                DropdownMenuItem(value: 'cancelada', child: Text('Canceladas')),
              ],
              onChanged: (value) => setState(() => _filtroEstado = value!),
            ),
          ),
          SizedBox(width: 12),
          Text(
            '(${_facturasFiltradas.length})',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error al cargar facturas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(onPressed: _cargarFacturas, child: Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            _filtroEstado == 'todas'
                ? 'No tienes facturas'
                : 'No hay facturas ${_filtroEstado}s',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Las facturas aparecerán aquí cuando sean generadas'),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/generar-servicios',
              ).then((_) => _cargarFacturas());
            },
            icon: Icon(Icons.add),
            label: Text('Generar Factura'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildListaFacturas() {
    return RefreshIndicator(
      onRefresh: _cargarFacturas,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _facturasFiltradas.length,
        itemBuilder: (context, index) {
          final factura = _facturasFiltradas[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 4,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetalleFacturaScreen(factura: factura),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Factura #${factura.id}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEstadoColor(factura.estado),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getEstadoIcon(factura.estado),
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                factura.estado.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (factura.descripcion != null &&
                        factura.descripcion!.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          factura.descripcion!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (factura.fechaEmision != null &&
                                  factura.fechaEmision!.isNotEmpty) ...[
                                Text(
                                  'Emisión:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  factura.fechaEmision!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              if (factura.fechaLimite != null &&
                                  factura.fechaLimite!.isNotEmpty) ...[
                                SizedBox(height: 4),
                                Text(
                                  'Vence:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  factura.fechaLimite!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            'Bs ${factura.montoTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.visibility, size: 16),
                            label: Text('Ver Detalle'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetalleFacturaScreen(factura: factura),
                                ),
                              );
                            },
                          ),
                        ),
                        if (factura.estado.toLowerCase() == 'pendiente') ...[
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.payment, size: 16),
                              label: Text('Pagar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PagarFacturaScreen(factura: factura),
                                  ),
                                );
                                // Si el pago fue exitoso, recarga la lista
                                if (result == true) {
                                  _cargarFacturas();
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
