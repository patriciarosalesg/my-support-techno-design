import 'package:flutter/material.dart';

import 'orders_screens.dart';
import 'services_design.dart';
import 'soporte_tecnico_screen.dart';
import 'login_screen.dart';
import 'actualization_screen.dart';

import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Guarda la sección seleccionada de la barra inferior.
  int _indiceActual = 0;

  // Guarda los datos del usuario que inició sesión.
  String _nombreUsuario = 'Usuario';
  String _correoUsuario = '';

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  // Carga el nombre y correo guardados después del inicio de sesión.
  Future<void> _cargarDatosUsuario() async {
    final nombre = await _authService.obtenerNombreUsuario();
    final correo = await _authService.obtenerCorreoUsuario();

    if (!mounted) return;

    setState(() {
      _nombreUsuario =
          nombre != null && nombre.isNotEmpty ? nombre : 'Usuario';

      _correoUsuario = correo ?? '';
    });
  }

  // Tres secciones principales.
  List<Widget> get _secciones => [
        InicioSection(nombreUsuario: _nombreUsuario),
        const OrdenesSection(),
        PerfilSection(
          nombreUsuario: _nombreUsuario,
          correoUsuario: _correoUsuario,
        ),
      ];

  // Cambia la sección seleccionada.
  void _cambiarSeccion(int indice) {
    setState(() {
      _indiceActual = indice;
    });
  }

  // SnackBar con acción "VER".
  void _mostrarSnackBarConVer() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Tienes una nueva actualización de servicio.',
        ),
        action: SnackBarAction(
          label: 'VER',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActualizationScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  // SnackBar flotante durante 5 segundos.
  void _mostrarSnackBarFlotante() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'La solicitud fue procesada correctamente.',
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // =====================================================
      // DRAWER
      // =====================================================

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Encabezado personalizado.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  25,
                  20,
                  22,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1565C0),
                      Color(0xFF0D47A1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.computer,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nombreUsuario,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Opciones del Drawer.
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Soporte técnico.
                    ListTile(
                      leading: const Icon(
                        Icons.support_agent,
                        color: Color(0xFF1565C0),
                      ),
                      title: const Text(
                        'Soporte técnico',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SoporteTecnicoScreen(),
                          ),
                        );
                      },
                    ),

                    // Servicios.
                    ListTile(
                      leading: const Icon(
                        Icons.miscellaneous_services,
                        color: Color(0xFF1565C0),
                      ),
                      title: const Text(
                        'Servicios',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ServicesDesign(),
                          ),
                        );
                      },
                    ),

                    // Categorías.
                    ExpansionTile(
                      leading: const Icon(
                        Icons.category,
                        color: Color(0xFF1565C0),
                      ),
                      title: const Text(
                        'Categorías',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.only(
                            left: 72,
                            right: 16,
                          ),
                          leading: const Icon(
                            Icons.computer,
                            size: 20,
                          ),
                          title: const Text('Hardware'),
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SoporteTecnicoScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(
                            left: 72,
                            right: 16,
                          ),
                          leading: const Icon(
                            Icons.apps,
                            size: 20,
                          ),
                          title: const Text('Software'),
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SoporteTecnicoScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(
                            left: 72,
                            right: 16,
                          ),
                          leading: const Icon(
                            Icons.router,
                            size: 20,
                          ),
                          title: const Text('Redes'),
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SoporteTecnicoScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Notificaciones.
                    ListTile(
                      leading: const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF1565C0),
                      ),
                      title: const Text(
                        'Notificaciones',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ActualizationScreen(),
                          ),
                        );
                      },
                    ),

                    // Ayuda.
                    ListTile(
                      leading: const Icon(
                        Icons.help_outline,
                        color: Color(0xFF1565C0),
                      ),
                      title: const Text(
                        'Ayuda',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _mostrarSnackBarFlotante();
                      },
                    ),

                    // Acerca de.
                    ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF1565C0),
                      ),
                      title: const Text(
                        'Acerca de',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _mostrarSnackBarFlotante();
                      },
                    ),
                  ],
                ),
              ),

              // Cerrar sesión.
              const Divider(height: 1),

              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  await _authService.cerrarSesion();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // =====================================================
      // BARRA SUPERIOR
      // =====================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Support Technos Design',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      // =====================================================
      // CONTENIDO
      // =====================================================

      body: IndexedStack(
        index: _indiceActual,
        children: _secciones,
      ),

      // =====================================================
      // BARRA INFERIOR
      // =====================================================

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: _cambiarSeccion,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Órdenes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// SECCIÓN 1 - INICIO
// ===========================================================

class InicioSection extends StatelessWidget {
  final String nombreUsuario;

  const InicioSection({
    super.key,
    required this.nombreUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),

          // Saludo principal en una sola línea.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '¡Bienvenido, $nombreUsuario!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Descripción.
          const Text(
            'Consulta y da seguimiento a tus servicios de soporte.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          // Panel de soporte.
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Panel de soporte',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Mis órdenes.
          _dashboardButton(
            context,
            'Mis órdenes de servicio',
            () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                  ) =>
                      const OrdersScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),

          // Seguimiento.
          _dashboardButton(
            context,
            'Seguimiento de servicio',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServicesDesign(),
                ),
              );
            },
          ),

          // Actualizaciones.
          _dashboardButton(
            context,
            'Actualizaciones del servicio',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActualizationScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// SECCIÓN 2 - ÓRDENES
// ===========================================================

class OrdenesSection extends StatelessWidget {
  const OrdenesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrdersScreen();
  }
}

// ===========================================================
// SECCIÓN 3 - PERFIL
// ===========================================================

class PerfilSection extends StatelessWidget {
  final String nombreUsuario;
  final String correoUsuario;

  const PerfilSection({
    super.key,
    required this.nombreUsuario,
    required this.correoUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30),

          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(
              Icons.person,
              size: 55,
              color: Color(0xFF1565C0),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Perfil del cliente',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Información del cliente',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 25),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.person_outline,
                color: Color(0xFF1565C0),
              ),
              title: const Text('Nombre completo'),
              subtitle: Text(
                nombreUsuario,
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.email,
                color: Color(0xFF1565C0),
              ),
              title: const Text('Correo electrónico'),
              subtitle: Text(
                correoUsuario.isNotEmpty
                    ? correoUsuario
                    : 'No disponible',
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.phone,
                color: Color(0xFF1565C0),
              ),
              title: const Text('Teléfono'),
              subtitle: const Text(
                '+504 9458-3853',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// BOTÓN REUTILIZABLE
// ===========================================================

Widget _dashboardButton(
  BuildContext context,
  String title,
  VoidCallback onPressed,
) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 1,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
