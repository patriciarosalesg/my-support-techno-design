import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/orden_servicios.dart';

class ServicesDesign extends StatefulWidget {
  final OrdenServicio? ordenSeleccionada;

  const ServicesDesign({
    super.key,
    this.ordenSeleccionada,
  });

  @override
  State<ServicesDesign> createState() => _ServicesDesignState();
}

class _ServicesDesignState extends State<ServicesDesign> {
  static const String baseUrl =
      'https://fixit-backend-production-0499.up.railway.app';

  OrdenServicio? orden;

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarOrden();
  }

  Future<void> cargarOrden() async {
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
          setState(() {
            orden = widget.ordenSeleccionada ??
              OrdenServicio.fromJson(lista.first);
          cargando = false;
        });
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

  @override
  Widget build(BuildContext context) {
    final estado = orden?.estado.toLowerCase() ?? '';

    final bool diagnosticoCompletado =
        estado.contains('repar') ||
        estado.contains('prueba') ||
        estado.contains('lista');

    final bool reparacionCompletada =
        estado.contains('prueba') ||
        estado.contains('lista');

    final bool reparacionActual =
        estado.contains('repar');

    final bool reparacionFinalizadaActual =
        estado.contains('prueba');

    final bool listoParaEntregar =
        estado.contains('lista');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          'Seguimiento del servicio',
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
          : orden == null
              ? const Center(
                  child: Text(
                    'No hay órdenes de servicio registradas.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        'Seguimiento de mi servicio',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Consulta el estado actual de tu equipo.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Información de la orden
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Text(
                                'Orden ${orden!.numeroOrden}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'Equipo: ${orden!.equipo}',
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Servicio: ${orden!.servicio}',
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Fecha de ingreso: ${orden!.fechaIngreso}',
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Entrega estimada: ${orden!.fechaEntrega}',
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Técnico: ${orden!.tecnico}',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Estado del servicio',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Equipo recibido
                      _statusStep(
                        icon: Icons.inventory_2_outlined,
                        title: 'Equipo recibido',
                        description:
                            'El equipo fue recibido por el área técnica.',
                        completed: true,
                      ),

                      _line(),

                      // Diagnóstico
                      _statusStep(
                        icon: Icons.search,
                        title: 'Diagnóstico realizado',
                        description:
                            'El equipo fue revisado por el técnico.',
                        completed: diagnosticoCompletado,
                        current: estado.contains('diagnóstico') ||
                            estado.contains('diagnostico'),
                      ),

                      _line(),

                      // Reparación
                      _statusStep(
                        icon: Icons.build_outlined,
                        title: 'Equipo en reparación',
                        description:
                            'El equipo se encuentra actualmente en reparación.',
                        completed: reparacionCompletada,
                        current: reparacionActual,
                      ),

                      _line(),

                      // Reparación finalizada
                      _statusStep(
                        icon: Icons.check_circle_outline,
                        title: 'Reparación finalizada',
                        description:
                            'Pendiente de finalizar el servicio.',
                        completed:
                            estado.contains('prueba') ||
                            estado.contains('lista'),
                        current: reparacionFinalizadaActual,
                      ),

                      _line(),

                      // Listo para entregar
                      _statusStep(
                        icon: Icons.inventory_outlined,
                        title: 'Listo para entregar',
                        description:
                            'El equipo estará disponible para ser retirado.',
                        completed: listoParaEntregar,
                        current: listoParaEntregar,
                      ),

                      const SizedBox(height: 25),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF1565C0),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'El estado de tu servicio se actualizará conforme avance el proceso técnico.',
                                style: TextStyle(
                                  color: Color(0xFF0D47A1),
                                ),
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

  static Widget _statusStep({
    required IconData icon,
    required String title,
    required String description,
    required bool completed,
    bool current = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: completed || current
                ? const Color(0xFF1565C0)
                : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: completed || current
                ? Colors.white
                : Colors.grey.shade600,
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: completed || current
                      ? const Color(0xFF1565C0)
                      : Colors.black54,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _line() {
    return Container(
      margin: const EdgeInsets.only(
        left: 22,
        top: 5,
        bottom: 5,
      ),
      height: 25,
      width: 2,
      color: Colors.grey.shade300,
    );
  }
}