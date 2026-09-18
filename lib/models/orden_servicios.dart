class OrdenServicio {
  final int id;
  final String numeroOrden;
  final String equipo;
  final String servicio;
  final String fechaIngreso;
  final String fechaEntrega;
  final double costoTotal;
  final String estado;
  final String tecnico;

  const OrdenServicio({
    required this.id,
    required this.numeroOrden,
    required this.equipo,
    required this.servicio,
    required this.fechaIngreso,
    required this.fechaEntrega,
    this.costoTotal = 0,
    required this.estado,
    required this.tecnico,
  });

  factory OrdenServicio.fromJson(Map<String, dynamic> json) {
    return OrdenServicio(
      id: json['id'] ?? 0,
      numeroOrden: json['numeroOrden'] ?? '',
      equipo: json['equipo'] ?? '',
      servicio: json['servicio'] ?? '',
      fechaIngreso: json['fechaIngreso'] ?? '',
      fechaEntrega: json['fechaEntrega'] ?? '',
      costoTotal:
          double.tryParse(json['costoTotal']?.toString() ?? '0') ?? 0,
      estado: json['estado'] ?? '',
      tecnico: json['tecnico'] ?? '',
    );
  }
}