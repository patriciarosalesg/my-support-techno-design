import 'package:flutter/material.dart';

// Importación de las diferentes pantallas de nuestra aplicación.
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/orders_screens.dart';
import 'screens/services_design.dart';
import 'screens/soporte_tecnico_screen.dart';
import 'screens/actualization_screen.dart';

// Importamos los servicios utilizados por la aplicación.
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'models/orden_servicios.dart';

// Punto de inicio de la aplicación.
// runApp() ejecuta el widget principal de nuestra aplicación.
void main() async {
  // Permite utilizar funciones que necesitan inicializarse
  // antes de ejecutar la aplicación.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos el servicio de notificaciones.
  await NotificationService.initialize();

  // Ejecutamos el widget principal de nuestra aplicación.
  runApp(const MyApp());
}

// MyApp es el widget principal de nuestra aplicación.
// Utilizamos StatelessWidget porque la configuración general
// de las rutas y el tema no necesita cambiar su estado.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // El método build se encarga de construir la aplicación.
  // BuildContext permite que Flutter conozca la ubicación
  // de este widget dentro de la estructura de widgets.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Ocultamos la etiqueta roja de "DEBUG" que aparece
      // en la esquina de la aplicación durante las pruebas.
      debugShowCheckedModeBanner: false,

      // Nombre de nuestra aplicación.
      title: 'My Support Technos Design',

      // Configuración del tema general de la aplicación.
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // La pantalla inicial verifica si existe una sesión guardada.
      home: const InitialScreen(),

      // Rutas nombradas de nuestra aplicación.
      routes: {
        // Ruta para la pantalla principal.
        '/home': (context) => const HomeScreen(),

        // Ruta para iniciar sesión.
        '/login': (context) => const LoginScreen(),

        // Ruta para el panel principal del usuario.
        '/dashboard': (context) => const DashboardScreen(),

        // Ruta para consultar las órdenes de servicio.
        '/orders': (context) => const OrdersScreen(),

        // Ruta para consultar los servicios disponibles.
        '/services': (context) {
        final orden =
        ModalRoute.of(context)?.settings.arguments as OrdenServicio?;

        return ServicesDesign(
        ordenSeleccionada: orden,
        );
      },

        // Ruta para la sección de soporte técnico.
        '/soporte-tecnico': (context) => const SoporteTecnicoScreen(),

        // Ruta para consultar las actualizaciones del servicio.
        '/actualizaciones': (context) => const ActualizationScreen(),
      },
    );
  }
}

// InitialScreen verifica si existe una sesión guardada
// antes de mostrar la pantalla principal de la aplicación.
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  // Creamos una instancia del servicio de autenticación
  // para consultar los datos guardados.
  final AuthService _authService = AuthService();

  // initState() se ejecuta una sola vez cuando
  // se crea esta pantalla.
  @override
  void initState() {
    super.initState();

    // Verificamos si existe una sesión guardada.
    _revisarSesion();
  }

  // Este método revisa si existe un token y el nombre
  // del usuario guardados después del inicio de sesión.
  Future<void> _revisarSesion() async {
    // Obtenemos el token almacenado de forma segura.
    final token = await _authService.obtenerToken();

    // Obtenemos el nombre del usuario almacenado.
    final nombreUsuario = await _authService.obtenerNombreUsuario();

    // Verificamos que la pantalla todavía exista
    // antes de utilizar el contexto de navegación.
    if (!mounted) return;

    // Si existe un token, significa que hay una sesión guardada.
    if (token != null && token.isNotEmpty) {
      // Enviamos al usuario al Dashboard y recuperamos
      // el nombre que fue guardado durante el inicio de sesión.
      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
        arguments: nombreUsuario,
      );
    } else {
      // Si no existe un token, mostramos la pantalla principal.
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostramos un indicador mientras se verifica la sesión.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}