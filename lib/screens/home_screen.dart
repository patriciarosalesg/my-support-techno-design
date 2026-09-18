import 'package:flutter/material.dart';

// Pantalla principal de la aplicacion
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Colores principales de la aplicacion
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color secondaryColor = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    // Estructura principal de la pantalla
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // Barra superior de la aplicacion
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,

        // Nombre de la aplicacion
        title: const Text(
          'My Support Technos Design',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
      ),

      // Contenido principal de la pantalla
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          // Organiza los elementos verticalmente
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Encabezado principal
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),

                // Diseño de la tarjeta
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                // Contenido de la tarjeta
                child: Column(
                  children: [
                    // Imagen logo Technos Design Computadoras
                    Image.asset(
                      'widget_profile/technos_design.jpeg',
                      height: 90,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 20),

                    // Descripcion de la funcion principal
                    const Text(
                      'Consulta y da seguimiento al estado '
                      'de tu equipo de forma rápida, segura y sencilla.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Boton principal para consultar el soporte
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        // Accion que ejecuta al presionar el boton
                        onPressed: () {
                          // Abre la pantalla de iniciar sesion
                          Navigator.pushNamed(context, '/login');
                        },

                        // Icono del boton
                        icon: const Icon(
                          Icons.support_agent,
                        ),

                        // Texto del boton
                        label: const Text(
                          'Consultar soporte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Servicios
              const Text(
                'Nuestros servicios',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),

              const SizedBox(height: 14),

              _ServiceCard(
                icon: Icons.support_agent,
                title: 'Soporte técnico',
                description:
                    'Seguimiento y atención de solicitudes de soporte.',
              ),

              const SizedBox(height: 12),

              _ServiceCard(
                icon: Icons.computer,
                title: 'Reparación y mantenimiento',
                description:
                    'Atención de equipos y mantenimiento técnico.',
              ),

              const SizedBox(height: 12),

              _ServiceCard(
                icon: Icons.router,
                title: 'Redes y equipos',
                description:
                    'Configuración y soporte de redes y dispositivos.',
              ),

              const SizedBox(height: 28),

              const Center(
                child: Text(
                  'Technos Design Computadoras',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// Tarjeta reutilizable para los servicios
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: HomeScreen.primaryColor,
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.3,
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