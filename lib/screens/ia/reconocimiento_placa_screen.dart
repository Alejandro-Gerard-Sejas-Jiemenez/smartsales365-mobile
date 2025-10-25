import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../utils/config.dart';
import '../../models/log_reconocimiento_placa.dart';

class ReconocimientoPlacaScreen extends StatefulWidget {
  @override
  _ReconocimientoPlacaScreenState createState() =>
      _ReconocimientoPlacaScreenState();
}

class _ReconocimientoPlacaScreenState extends State<ReconocimientoPlacaScreen> {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  File? _imagen;
  String? _resultado;
  bool _procesando = false;
  List<LogReconocimientoPlaca> _logs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cargarLogs();
    });
  }

  Future<void> _seleccionarImagen(ImageSource fuente) async {
    if (_procesando) return;

    try {
      final picker = ImagePicker();
      final archivo = await picker.pickImage(
        source: fuente,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (archivo != null && mounted) {
        setState(() {
          _imagen = File(archivo.path);
          _resultado = null;
          _procesando = true;
        });

        _procesarImagen(_imagen!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _resultado = "Error al seleccionar imagen: $e";
        });
      }
    }
  }

  Future<void> _procesarImagen(File archivo) async {
    try {
      final urlImagen = await _subirACloudinary(archivo);
      if (urlImagen == null) throw Exception("Error al subir imagen");

      final response = await _dio.post(
        "${Config.baseUrl}/vision/reconocer-placa/",
        data: {"foto_url": urlImagen},
      );

      if (!mounted) return;

      final data = response.data;
      final confianza = _formatearConfianza(data["confianza"]);

      setState(() {
        if (data["autorizado"] == true) {
          final vehiculo = data["vehiculo"];
          final propietario = vehiculo["propietario"];
          _resultado =
              "🚗 VEHÍCULO AUTORIZADO\n"
              "Propietario: ${propietario["nombre"]} ${propietario["apellido"]}\n"
              "Vehículo: ${vehiculo["marca"]} ${vehiculo["modelo"]}\n"
              "Placa: ${data["placa_detectada"]}\n"
              "Confianza: $confianza%";
        } else {
          _resultado =
              "🚫 VEHÍCULO NO AUTORIZADO\n"
              "${data["mensaje"]}\n"
              "Placa detectada: ${data["placa_detectada"] ?? 'N/A'}\n"
              "Confianza: $confianza%";
        }
        _procesando = false;
      });

      _cargarLogs();
    } catch (e) {
      if (mounted) {
        setState(() {
          _resultado = "Error en el reconocimiento: ${e.toString()}";
          _procesando = false;
        });
      }
    }
  }

  Future<String?> _subirACloudinary(File archivo) async {
    try {
      const cloudName = "dlhfdfu6l";
      const uploadPreset = "ml_default";
      const folder = "fotoReferenciaCondominium";

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(archivo.path),
        "upload_preset": uploadPreset,
        "folder": folder,
      });

      final response = await _dio.post(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
        data: formData,
      );

      return response.data["secure_url"];
    } catch (e) {
      return null;
    }
  }

  Future<void> _cargarLogs() async {
    try {
      final response = await _dio.get("${Config.baseUrl}/vision/logs-placa/");

      if (!mounted) return;

      setState(() {
        _logs = (response.data as List<dynamic>)
            .map((json) => LogReconocimientoPlaca.fromJson(json))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _logs = [];
        });
      }
    }
  }

  String _formatearConfianza(dynamic confianza) {
    if (confianza == null) return "0.00";
    if (confianza is double) return confianza.toStringAsFixed(2);
    if (confianza is int) return confianza.toDouble().toStringAsFixed(2);
    if (confianza is String) {
      return (double.tryParse(confianza) ?? 0.0).toStringAsFixed(2);
    }
    return "0.00";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Reconocimiento de Placas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_imagen != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imagen!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_procesando) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      const Text(
                        "Analizando placa...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ] else if (_resultado != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _resultado!.contains("AUTORIZADO")
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _resultado!.contains("AUTORIZADO")
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Text(
                          _resultado!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _resultado!.contains("AUTORIZADO")
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.directions_car,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Selecciona una imagen de placa vehicular",
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _procesando
                        ? null
                        : () => _seleccionarImagen(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      "Cámara",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _procesando
                        ? null
                        : () => _seleccionarImagen(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: const Text(
                      "Galería",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              "Historial de Reconocimientos",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            _logs.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No hay registros aún",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: _logs
                        .map((log) => _construirTarjetaLog(log))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _construirTarjetaLog(LogReconocimientoPlaca log) {
    final esAutorizado = log.descripcion?.contains("autorizado") ?? false;
    final confianza = _formatearConfianza(log.confianza);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: esAutorizado ? Colors.green[100] : Colors.red[100],
          child: Icon(
            Icons.directions_car,
            color: esAutorizado ? Colors.green[700] : Colors.red[700],
            size: 32,
          ),
        ),
        title: Text(
          (log.nombrePropietario?.isNotEmpty == true &&
                  log.apellidoPropietario?.isNotEmpty == true)
              ? "${log.nombrePropietario} ${log.apellidoPropietario}"
              : "Vehículo desconocido",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (log.marcaVehiculo?.isNotEmpty == true)
              Text("${log.marcaVehiculo} ${log.modeloVehiculo ?? ''}"),
            Text(
              "Placa: ${log.placaDetectada ?? log.matriculaVehiculo ?? 'N/A'}",
            ),
            Row(
              children: [
                Icon(
                  esAutorizado ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: esAutorizado ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  esAutorizado ? "Autorizado" : "No autorizado",
                  style: TextStyle(
                    color: esAutorizado ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text("Confianza: $confianza%"),
            Text(
              log.fechaHora ?? "",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: log.fotoRuta != null && log.fotoRuta!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  log.fotoRuta!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, color: Colors.grey[400]),
                ),
              )
            : null,
      ),
    );
  }
}
