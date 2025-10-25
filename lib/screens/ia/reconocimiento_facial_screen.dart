import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../utils/config.dart';
import '../../models/log_reconocimiento.dart';

class ReconocimientoFacialScreen extends StatefulWidget {
  @override
  _ReconocimientoFacialScreenState createState() =>
      _ReconocimientoFacialScreenState();
}

class _ReconocimientoFacialScreenState
    extends State<ReconocimientoFacialScreen> {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  File? _imagen;
  String? _resultado;
  bool _procesando = false;
  List<LogReconocimiento> _logs = [];

  @override
  void initState() {
    super.initState();
    // Cargar logs después del primer frame
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
      // 1. Subir imagen a Cloudinary
      final urlImagen = await _subirACloudinary(archivo);
      if (urlImagen == null) throw Exception("Error al subir imagen");

      // 2. Enviar al backend para reconocimiento
      final response = await _dio.post(
        "${Config.baseUrl}/vision/reconocer/",
        data: {"foto_url": urlImagen},
      );

      if (!mounted) return;

      final data = response.data;
      final coincidencia = _formatearCoincidencia(data["coincidencia"]);

      setState(() {
        if (data["autorizado"] == true) {
          final residente = data["residente"];
          _resultado =
              "✅ AUTORIZADO\n"
              "${residente["nombre"]} ${residente["apellido"]}\n"
              "Coincidencia: $coincidencia%";
        } else {
          _resultado =
              "❌ NO AUTORIZADO\n"
              "Persona no reconocida\n"
              "Coincidencia: $coincidencia%";
        }
        _procesando = false;
      });

      // Recargar logs después del reconocimiento
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
      print("Cargando logs desde: ${Config.baseUrl}/vision/logs/"); // Debug

      final response = await _dio.get("${Config.baseUrl}/vision/logs/");

      print("Response status: ${response.statusCode}"); // Debug
      print("Response data: ${response.data}"); // Debug

      if (!mounted) return;

      if (response.data is List) {
        setState(() {
          _logs = (response.data as List<dynamic>)
              .map((json) {
                try {
                  return LogReconocimiento.fromJson(json);
                } catch (e) {
                  print("Error parsing log: $e"); // Debug
                  return null;
                }
              })
              .where((log) => log != null)
              .cast<LogReconocimiento>()
              .toList();
        });
        print("Logs cargados: ${_logs.length}"); // Debug
      } else {
        print("Response data is not a list: ${response.data}"); // Debug
        setState(() {
          _logs = [];
        });
      }
    } catch (e) {
      print("Error cargando logs: $e"); // Debug
      if (mounted) {
        setState(() {
          _logs = [];
        });
      }
    }
  }

  String _formatearCoincidencia(dynamic coincidencia) {
    if (coincidencia == null) return "0.00";
    if (coincidencia is double) return coincidencia.toStringAsFixed(2);
    if (coincidencia is int) return coincidencia.toDouble().toStringAsFixed(2);
    if (coincidencia is String) {
      return (double.tryParse(coincidencia) ?? 0.0).toStringAsFixed(2);
    }
    return "0.00";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Reconocimiento Facial',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de imagen y resultado
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
                        "Procesando imagen...",
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
                        Icons.face_retouching_natural,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Selecciona una imagen para reconocimiento facial",
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botones de acción
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
                      backgroundColor: Colors.deepPurple,
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
                      backgroundColor: Colors.deepPurple,
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

            // Historial de reconocimientos
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

  Widget _construirTarjetaLog(LogReconocimiento log) {
    final esAutorizado = log.descripcion?.contains("exitoso") ?? false;
    final coincidencia = _formatearCoincidencia(log.coincidencia);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: esAutorizado ? Colors.green[100] : Colors.red[100],
          backgroundImage:
              (log.fotoResidente != null && log.fotoResidente!.isNotEmpty)
              ? NetworkImage(log.fotoResidente!)
              : null,
          child: (log.fotoResidente == null || log.fotoResidente!.isEmpty)
              ? Icon(
                  Icons.person,
                  color: esAutorizado ? Colors.green[700] : Colors.red[700],
                  size: 32,
                )
              : null,
        ),
        title: Text(
          (log.nombreResidente?.isNotEmpty == true &&
                  log.apellidoResidente?.isNotEmpty == true)
              ? "${log.nombreResidente} ${log.apellidoResidente}"
              : "Desconocido",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
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
            const SizedBox(height: 2),
            Text("Coincidencia: $coincidencia%"),
            const SizedBox(height: 2),
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
