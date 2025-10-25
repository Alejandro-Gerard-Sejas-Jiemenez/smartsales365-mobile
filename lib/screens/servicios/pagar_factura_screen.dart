import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/factura.dart';

import '../../services/pago_service.dart';

class PagarFacturaScreen extends StatefulWidget {
  final Factura factura;

  const PagarFacturaScreen({Key? key, required this.factura}) : super(key: key);

  @override
  _PagarFacturaScreenState createState() => _PagarFacturaScreenState();
}

class _PagarFacturaScreenState extends State<PagarFacturaScreen> {
  final PagoService _pagoService = PagoService();
  bool _isProcessing = false;
  String _mensaje = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pagar Factura #${widget.factura.id}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFacturaResumen(),
            SizedBox(height: 24),
            _buildMetodoPago(),
            SizedBox(height: 24),
            _buildPagarButton(),
            if (_mensaje.isNotEmpty) _buildMensaje(),
          ],
        ),
      ),
    );
  }

  Widget _buildFacturaResumen() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue[700], size: 32),
                SizedBox(width: 12),
                Text(
                  'Resumen de Factura',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 24),
            _buildInfoRow('Factura #:', '${widget.factura.id}'),
            _buildInfoRow('Estado:', widget.factura.estado.toUpperCase()),
            if (widget.factura.descripcion != null &&
                widget.factura.descripcion!.isNotEmpty)
              _buildInfoRow('Descripción:', widget.factura.descripcion!),
            if (widget.factura.fechaLimite != null)
              _buildInfoRow('Vence:', widget.factura.fechaLimite!),
            SizedBox(height: 16),
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
                    'TOTAL A PAGAR:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Bs ${widget.factura.montoTotal}',
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
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetodoPago() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.blue[700], size: 32),
                SizedBox(width: 12),
                Text(
                  'Método de Pago',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kIsWeb ? Colors.orange[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: kIsWeb ? Colors.orange[200]! : Colors.blue[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    kIsWeb ? Icons.info : Icons.credit_card,
                    color: kIsWeb ? Colors.orange[700] : Colors.blue[700],
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kIsWeb
                            ? 'Pagos no disponibles en Web'
                            : 'Tarjeta de Crédito/Débito',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        kIsWeb
                            ? 'Use un dispositivo móvil para pagar'
                            : 'Procesado por Stripe (Modo Prueba)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!kIsWeb) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Modo de prueba: Use la tarjeta 4242 4242 4242 4242',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPagarButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: kIsWeb ? null : (_isProcessing ? null : _procesarPago),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Procesando...'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(kIsWeb ? Icons.phone_android : Icons.lock, size: 20),
                  SizedBox(width: 8),
                  Text(
                    kIsWeb
                        ? 'Usar dispositivo móvil'
                        : 'Pagar Bs ${widget.factura.montoTotal}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kIsWeb ? Colors.grey : Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildMensaje() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _mensaje.contains('Error') || _mensaje.contains('falló')
            ? Colors.red[50]
            : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _mensaje.contains('Error') || _mensaje.contains('falló')
              ? Colors.red[200]!
              : Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _mensaje.contains('Error') || _mensaje.contains('falló')
                ? Icons.error
                : Icons.check_circle,
            color: _mensaje.contains('Error') || _mensaje.contains('falló')
                ? Colors.red[700]
                : Colors.green[700],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _mensaje,
              style: TextStyle(
                color: _mensaje.contains('Error') || _mensaje.contains('falló')
                    ? Colors.red[800]
                    : Colors.green[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarPago() async {
    setState(() {
      _isProcessing = true;
      _mensaje = '';
    });

    try {
      setState(() => _mensaje = 'Procesando pago en el servidor...');
      // Aquí solo llamas al backend para procesar el pago
      await _pagoService.confirmarPagoFacturaBackend(widget.factura.id!);

      setState(() => _mensaje = '¡Pago realizado exitosamente!');
      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _mensaje = 'Error al procesar pago: ${e.toString()}';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
