import 'package:ciemsi_app/features/recetas/presentation/pages/generar_receta_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_event.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_state.dart';
import 'modificar_cita_page.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/bloc/tratamiento_bloc.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/pages/asignar_tratamiento_page.dart';

class DetalleCitaPage extends StatelessWidget {
  final CitaMedica cita;
  const DetalleCitaPage({super.key, required this.cita});

  Color _colorEstado(EstadoCita estado) {
    switch (estado) {
      case EstadoCita.PENDIENTE:
        return Colors.orange;
      case EstadoCita.MODIFICADA:
        return Colors.purple;
      case EstadoCita.CONFIRMADA:
        return const Color(0xFF00B5C8);
      case EstadoCita.CANCELADA:
        return Colors.red;
      case EstadoCita.COMPLETADA:
        return const Color(0xFF8DC63F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Detalle de Cita',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<CitaBloc, CitaState>(
        listener: (context, state) {
          if (state is EstadoCitaCambiado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Estado actualizado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is CitaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _colorEstado(cita.estado).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _colorEstado(cita.estado)),
                  ),
                  child: Text(
                    cita.estado.name,
                    style: TextStyle(
                      color: _colorEstado(cita.estado),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Info de la cita
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.person_outlined,
                        'Paciente',
                        cita.paciente.nombreCompleto,
                      ),
                      _buildInfoRow(
                        Icons.badge_outlined,
                        'CI',
                        cita.paciente.ci,
                      ),
                      _buildInfoRow(
                        Icons.medical_services_outlined,
                        'Servicio',
                        cita.servicio.nombreServicio,
                      ),
                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        'Fecha',
                        DateFormat('dd/MM/yyyy').format(cita.fecha),
                      ),
                      _buildInfoRow(
                        Icons.access_time_outlined,
                        'Hora',
                        cita.hora.substring(0, 5),
                      ),
                      _buildInfoRow(
                        Icons.location_city_outlined,
                        'Ciudad',
                        cita.ciudad.nombreCiudad,
                      ),
                      if (cita.notas != null && cita.notas!.isNotEmpty)
                        _buildInfoRow(
                          Icons.notes_outlined,
                          'Notas',
                          cita.notas!,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Acciones según estado
              ..._buildAcciones(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAcciones(BuildContext context) {
    final acciones = <Widget>[];

    if (cita.estado == EstadoCita.PENDIENTE) {
      acciones.add(
        _buildBoton(
          context,
          'Confirmar Cita',
          Icons.check_circle_outline,
          const Color(0xFF00B5C8),
          () => _cambiarEstado(context, 'CONFIRMADA'),
        ),
      );
      acciones.add(const SizedBox(height: 12));
      acciones.add(
        _buildBoton(
          context,
          'Modificar Cita',
          Icons.edit_calendar_outlined,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CitaBloc>(),
                child: ModificarCitaPage(cita: cita),
              ),
            ),
          ),
        ),
      );
      acciones.add(const SizedBox(height: 12));
      acciones.add(
        _buildBoton(
          context,
          'Cancelar Cita',
          Icons.cancel_outlined,
          Colors.red,
          () => _mostrarDialogoCancelar(context),
        ),
      );
    }

    if (cita.estado == EstadoCita.MODIFICADA) {
      acciones.add(
        _buildBoton(
          context,
          'Aceptar Modificación',
          Icons.check_circle_outline,
          const Color(0xFF8DC63F),
          () => _cambiarEstado(context, 'CONFIRMADA'),
        ),
      );
      acciones.add(const SizedBox(height: 12));
      acciones.add(
        _buildBoton(
          context,
          'Rechazar y Cancelar',
          Icons.cancel_outlined,
          Colors.red,
          () => _mostrarDialogoCancelar(context),
        ),
      );
    }

    if (cita.estado == EstadoCita.CONFIRMADA) {
      acciones.add(
        _buildBoton(
          context,
          'Marcar como Completada',
          Icons.task_alt,
          const Color(0xFF8DC63F),
          () => _cambiarEstado(context, 'COMPLETADA'),
        ),
      );
      acciones.add(const SizedBox(height: 12));
      acciones.add(
        _buildBoton(
          context,
          'Cancelar Cita',
          Icons.cancel_outlined,
          Colors.red,
          () => _mostrarDialogoCancelar(context),
        ),
      );
      acciones.add(const SizedBox(height: 12));
      acciones.add(
        _buildBoton(
          context,
          'Asignar Tratamiento',
          Icons.healing_outlined,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => TratamientoBloc(),
                child: AsignarTratamientoPage(cita: cita),
              ),
            ),
          ),
        ),
      );
      acciones.add(const SizedBox(height: 12));
      acciones.add(
        _buildBoton(
          context,
          'Generar Receta',
          Icons.receipt_outlined,
          const Color(0xFF8DC63F),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => TratamientoBloc(),
                child: GenerarRecetaPage(cita: cita),
              ),
            ),
          ),
        ),
      );
    }

    return acciones;
  }

  void _cambiarEstado(BuildContext context, String estado) {
    context.read<CitaBloc>().add(
      CambiarEstadoCitaEvent(id: cita.id, estado: estado),
    );
  }

  void _mostrarDialogoCancelar(BuildContext context) {
    final notasController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Motivo de cancelación? (opcional)'),
            const SizedBox(height: 12),
            TextField(
              controller: notasController,
              decoration: InputDecoration(
                hintText: 'Escribe el motivo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CitaBloc>().add(
                CambiarEstadoCitaEvent(
                  id: cita.id,
                  estado: 'CANCELADA',
                  notas: notasController.text.trim().isEmpty
                      ? null
                      : notasController.text.trim(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Confirmar Cancelación',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return BlocBuilder<CitaBloc, CitaState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: state is CitaLoading ? null : onTap,
            icon: state is CitaLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(icon, color: Colors.white),
            label: Text(label, style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00B5C8), size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
