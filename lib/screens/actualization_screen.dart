import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/orden_servicios.dart';
import '../services/auth_service.dart';
import '../widgets/actualizacion_servicio_card.dart';

class ActualizationScreen extends StatefulWidget {
  const ActualizationScreen({super.key});

  @override
  State<ActualizationScreen> createState() =>
      _ActualizationScreenState();
}

class _ActualizationScreenState
    extends State<ActualizationScreen> {
  static const String baseUrl =
      'https://fixit-backend-production-0499.up.railway.app';

  OrdenServicio? orden;
  List<dynamic> actualizaciones = [];

  bool cargando = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (cargando) {
      final argumentos =
          ModalRoute.of(context)?.settings.arguments;

      if (argumentos is OrdenServicio) {
        orden = argumentos;
        cargarActualizaciones();
      } else {
        cargarOrdenDesdeBackend();
      }
    }
  }

  Future<void> cargarOrdenDesdeBackend() async {
    try {
      final authService = AuthService();
      final token = await authService.obtenerToken();

      final respuesta = await http.get(
        Uri.parse('$baseUrl/api/ordenes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        final List<dynamic> lista = datos['data'];

        if (lista.isNotEmpty) {
          orden = OrdenServicio.fromJson(lista.first);
          await cargarActualizaciones();
        } else {
          setState(() {
            cargando = false;
          });
        }
      } else {
        setState(() {
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> cargarActualizaciones() async {
    if (orden == null) {
      setState(() {
        cargando = false;
      });
      return;
    }

    try {
      final authService = AuthService();
      final token = await authService.obtenerToken();

      final respuesta = await http.get(
        Uri.parse(
          '$baseUrl/api/ordenes/${orden!.id}/actualizaciones',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);

        setState(() {
          actualizaciones = datos['data'] ?? [];
          cargando = false;
        });
      } else {
        setState(() {
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          'Actualizaciones del servicio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1565C0),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Actualizaciones recientes',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Consulta los avances registrados por el área técnica sobre tus equipos.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                if (orden != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Orden seleccionada',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Número de orden: ${orden!.numeroOrden}',
                          ),
                          Text(
                            'Equipo: ${orden!.equipo}',
                          ),
                          Text(
                            'Servicio: ${orden!.servicio}',
                          ),
                          Text(
                            'Estado: ${orden!.estado}',
                          ),
                        ],
                      ),
                    ),
                  ),

                if (orden != null)
                  const SizedBox(height: 20),

                if (actualizaciones.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        'Todavía no hay actualizaciones registradas para esta orden.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),

                ...actualizaciones.map(
                  (actualizacion) {
                    final estado =
                        actualizacion['estado']?.toString() ??
                            'Sin estado';

                    final fecha =
                        actualizacion['fecha']?.toString() ??
                            '';

                    return ActualizacionServicioCard(
                      numeroOrden: orden!.numeroOrden,
                      equipo: orden!.equipo,
                      problemaReportado:
                          'Servicio registrado: ${orden!.servicio}',
                      diagnostico:
                          'Estado registrado por el área técnica: $estado',
                      mensaje:
                          'Se registró una actualización de la orden con el estado: $estado.',
                      estado: estado,
                      fecha: 'Fecha: $fecha',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/services',
                          arguments: orden,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        color: Color(0xFF1565C0),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Las actualizaciones se mostrarán conforme el área técnica registre nuevos avances en tu servicio.',
                          style: TextStyle(
                            color: Color(0xFF0D47A1),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}