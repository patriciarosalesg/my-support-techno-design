import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../models/orden_servicios.dart';
import '../widgets/orden_servicio_card.dart';
import '../services/auth_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool cargando = false;

  // Las órdenes se cargan desde el backend según el usuario autenticado.
  final List<OrdenServicio> ordenes = [];

  final Set<String> favoritos = {};

  final TextEditingController equipoController =
      TextEditingController();

  final TextEditingController servicioController =
      TextEditingController();

  final TextEditingController fechaController =
      TextEditingController();

  final TextEditingController costoController =
      TextEditingController();

  String textoBusqueda = '';

  static const String baseUrl =
      'https://fixit-backend-production-0499.up.railway.app';

  
  Future<void> cargarOrdenesDesdeBackend() async {
  setState(() {
    cargando = true;
  });

  try {
    final authService = AuthService();

    final token = await authService.obtenerToken();
    final userId = await authService.obtenerIdUsuario();

    if (token == null ||
        token.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      setState(() {
        ordenes.clear();
        cargando = false;
      });

      return;
    }

    final respuesta = await http.get(
      Uri.parse('$baseUrl/api/ordenes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);

      final List<dynamic> lista = datos['data'] ?? [];

      // Solo mostramos las órdenes del usuario que inició sesión.
      final ordenesDelUsuario = lista.where((item) {
        return item['usuarioId']?.toString() == userId;
      }).toList();

      setState(() {
        ordenes.clear();

        ordenes.addAll(
          ordenesDelUsuario.map(
            (item) => OrdenServicio.fromJson(item),
          ),
        );

        cargando = false;
      });
    } else {
      setState(() {
        ordenes.clear();
        cargando = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudieron cargar las órdenes. Código: ${respuesta.statusCode}',
            ),
          ),
        );
      }
    }
  } catch (error) {
    setState(() {
      ordenes.clear();
      cargando = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo conectar con el servidor.',
          ),
        ),
      );
    }

    print('Error al conectar con el backend: $error');
  }
}

Future<void> crearOrdenEnBackend() async {
  if (equipoController.text.trim().isEmpty ||
      servicioController.text.trim().isEmpty ||
      fechaController.text.trim().isEmpty ||
      costoController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Complete todos los campos antes de guardar.',
        ),
      ),
    );

    return;
  }

  final costo =
      double.tryParse(costoController.text.trim());

  if (costo == null || costo < 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ingrese un costo válido.',
        ),
      ),
    );

    return;
  }

  final authService = AuthService();
  final token = await authService.obtenerToken();

  if (token == null || token.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La sesión no está activa.',
        ),
      ),
    );

    return;
  }

  final numeroOrden =
      'TD-${DateTime.now().millisecondsSinceEpoch}';

  final fechaIngreso = _obtenerFechaActual();

  try {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/api/ordenes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'numeroOrden': numeroOrden,
        'equipo': equipoController.text.trim(),
        'servicio': servicioController.text.trim(),
        'fechaIngreso': fechaIngreso,
        'fechaEntrega': fechaController.text.trim(),
        'costoTotal': costo,
        'estado': 'Pendiente',
        'tecnico': 'Área de Soporte Técnico',
      }),
    );

    final datos = jsonDecode(respuesta.body);

    if (respuesta.statusCode == 201) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nueva orden guardada correctamente.',
          ),
        ),
      );

      await cargarOrdenesDesdeBackend();
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            datos['message'] ??
                'No se pudo guardar la orden.',
          ),
        ),
      );
    }
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No se pudo conectar con el servidor.',
        ),
      ),
    );

    print('Error al crear la orden: $error');
  }
}

  Future<void> actualizarOrdenEnBackend({
    required OrdenServicio orden,
    required String equipo,
    required String servicio,
    required String fechaEntrega,
    required double costoTotal,
  }) async {
    final authService = AuthService();
    final token = await authService.obtenerToken();

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La sesión no está activa.',
          ),
        ),
      );

      return;
    }

    try {
      final respuesta = await http.put(
        Uri.parse('$baseUrl/api/ordenes/${orden.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'equipo': equipo,
          'servicio': servicio,
          'fechaEntrega': fechaEntrega,
          'costoTotal': costoTotal,
        }),
      );

      final datos = jsonDecode(respuesta.body);

      if (respuesta.statusCode == 200) {
        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Orden ${orden.numeroOrden} actualizada correctamente.',
            ),
          ),
        );

        await cargarOrdenesDesdeBackend();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              datos['message'] ??
                  'No se pudo actualizar la orden.',
            ),
          ),
        );
      }
    } catch (error) {
      print('Error al actualizar la orden: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo conectar con el servidor.',
          ),
        ),
      );
    }
  }

  String _obtenerFechaActual() {
    final ahora = DateTime.now();

    final dia = ahora.day.toString().padLeft(2, '0');
    final mes = ahora.month.toString().padLeft(2, '0');
    final anio = ahora.year.toString();

    return '$dia/$mes/$anio';
  }

  Future<void> generarFactura(OrdenServicio orden) async {
    final url = Uri.parse(
      '$baseUrl/api/ordenes/${orden.id}/factura',
    );

    try {
      final puedeAbrir = await canLaunchUrl(url);

      if (!puedeAbrir) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo abrir la factura.',
            ),
          ),
        );

        return;
      }

      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      print('Error al abrir la factura: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocurrió un error al abrir la factura.',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cargarOrdenesDesdeBackend();
  }

  @override
  void dispose() {
    equipoController.dispose();
    servicioController.dispose();
    fechaController.dispose();
    costoController.dispose();
    super.dispose();
  }

  void cambiarFavorito(String numeroOrden) {
    setState(() {
      if (favoritos.contains(numeroOrden)) {
        favoritos.remove(numeroOrden);
      } else {
        favoritos.add(numeroOrden);
      }
    });
  }

  void confirmarEliminacion(OrdenServicio orden) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar orden'),
          content: Text(
            '¿Desea eliminar la orden ${orden.numeroOrden}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  ordenes.removeWhere(
                    (item) =>
                        item.numeroOrden ==
                        orden.numeroOrden,
                  );

                  favoritos.remove(orden.numeroOrden);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Orden ${orden.numeroOrden} eliminada.',
                    ),
                  ),
                );
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void abrirFormularioNuevaOrden() {
    equipoController.clear();
    servicioController.clear();
    fechaController.clear();
    costoController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nueva orden de servicio',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: equipoController,
                  decoration: const InputDecoration(
                    labelText: 'Equipo',
                    prefixIcon: Icon(Icons.computer),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: servicioController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de servicio',
                    prefixIcon: Icon(Icons.build),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: fechaController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de entrega',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: costoController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Costo total',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                    hintText: 'Ej. 850.00',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: crearOrdenEnBackend,
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void editarOrden(OrdenServicio orden) {
    final equipoEditar =
        TextEditingController(text: orden.equipo);

    final servicioEditar =
        TextEditingController(text: orden.servicio);

    final fechaEditar =
        TextEditingController(text: orden.fechaEntrega);

    final costoEditar = TextEditingController(
      text: orden.costoTotal.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar orden'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: equipoEditar,
                  decoration: const InputDecoration(
                    labelText: 'Equipo',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: servicioEditar,
                  decoration: const InputDecoration(
                    labelText: 'Servicio',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fechaEditar,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de entrega',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: costoEditar,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Costo total',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final costo = double.tryParse(
                  costoEditar.text.trim(),
                );

                if (costo == null || costo < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ingrese un costo válido.',
                      ),
                    ),
                  );

                  return;
                }

                actualizarOrdenEnBackend(
                  orden: orden,
                  equipo: equipoEditar.text.trim(),
                  servicio: servicioEditar.text.trim(),
                  fechaEntrega: fechaEditar.text.trim(),
                  costoTotal: costo,
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double anchoPantalla =
        MediaQuery.of(context).size.width;

    final double margenHorizontal =
        anchoPantalla > 600 ? 60 : 20;

    final String busqueda =
        textoBusqueda.trim().toLowerCase();

    final List<OrdenServicio> ordenesFiltradas =
        ordenes.where((orden) {
      return orden.numeroOrden
              .toLowerCase()
              .contains(busqueda) ||
          orden.equipo
              .toLowerCase()
              .contains(busqueda) ||
          orden.servicio
              .toLowerCase()
              .contains(busqueda);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis órdenes de servicio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              margenHorizontal,
              20,
              margenHorizontal,
              10,
            ),
            child: TextField(
              onChanged: (valor) {
                setState(() {
                  textoBusqueda = valor;
                });
              },
              decoration: InputDecoration(
                hintText:
                    'Buscar por orden, equipo o servicio',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF1565C0),
                ),
                suffixIcon: textoBusqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            textoBusqueda = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1565C0),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          if (cargando)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1565C0),
                ),
              ),
            )
          else if (ordenesFiltradas.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 55,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No tienes órdenes de servicio.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: margenHorizontal,
                  vertical: 10,
                ),
                itemCount: ordenesFiltradas.length,
                itemBuilder: (context, index) {
                  final orden = ordenesFiltradas[index];

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 15,
                    ),
                    child: Dismissible(
                      key: ValueKey(orden.numeroOrden),

                      background: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Editar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      secondaryBackground: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                        child: const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            Text(
                              'Eliminar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),

                      direction:
                          DismissDirection.horizontal,

                      confirmDismiss:
                          (direction) async {
                        if (direction ==
                            DismissDirection.startToEnd) {
                          editarOrden(orden);
                          return false;
                        }

                        if (direction ==
                            DismissDirection.endToStart) {
                          final confirmar =
                              await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  'Confirmar eliminación',
                                ),
                                content: Text(
                                  '¿Desea eliminar la orden ${orden.numeroOrden}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                        false,
                                      );
                                    },
                                    child: const Text(
                                      'Cancelar',
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                        true,
                                      );
                                    },
                                    child: const Text(
                                      'Eliminar',
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          return confirmar ?? false;
                        }

                        return false;
                      },

                      onDismissed: (direction) {
                        if (direction ==
                            DismissDirection.endToStart) {
                          setState(() {
                            ordenes.removeWhere(
                              (item) =>
                                  item.numeroOrden ==
                                  orden.numeroOrden,
                            );

                            favoritos.remove(
                              orden.numeroOrden,
                            );
                          });

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                'Orden ${orden.numeroOrden} eliminada.',
                              ),
                            ),
                          );
                        }
                      },

                      child: Column(
                        children: [
                          GestureDetector(
                            onLongPress: () {
                              confirmarEliminacion(orden);
                            },
                            child: OrdenServicioCard(
                              numeroOrden:
                                  orden.numeroOrden,
                              equipo: orden.equipo,
                              servicio: orden.servicio,
                              estado: orden.estado,
                              fechaEntrega:
                                  orden.fechaEntrega,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/actualizaciones',
                                  arguments: orden,
                                );
                              },
                              onToggleFavorite: () {
                                cambiarFavorito(
                                  orden.numeroOrden,
                                );
                              },
                              esFavorito:
                                  favoritos.contains(
                                orden.numeroOrden,
                              ),
                              mostrarEstado: true,
                            ),
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                generarFactura(orden);
                              },
                              icon: const Icon(
                                Icons.picture_as_pdf,
                                color: Color(0xFF1565C0),
                              ),
                              label: const Text(
                                'Generar factura',
                                style: TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF1565C0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: abrirFormularioNuevaOrden,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva orden'),
      ),
    );
  }
}