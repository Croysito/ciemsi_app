import 'package:ciemsi_app/features/recetas/presentation/pages/generar_receta_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_event.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_state.dart';
import 'modificar_cita_page.dart';
import 'pago_adelanto_page.dart';
import 'package:ciemsi_app/features/tratamientos/presentation/pages/asignar_tratamiento_page.dart';
import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_bloc.dart';
import 'package:ciemsi_app/features/pacientes/presentation/pages/completar_paciente_page.dart';
import 'package:ciemsi_app/features/historial/presentation/pages/historial_page.dart';
import 'package:ciemsi_app/features/historial/presentation/bloc/historial_bloc.dart';
import 'package:ciemsi_app/features/historial/data/datasources/historial_remote_datasource.dart';
import 'package:ciemsi_app/features/historial/data/repositories/historial_repository_impl.dart';
import 'package:ciemsi_app/features/historial/domain/usecases/obtener_historial.dart';
import 'package:ciemsi_app/features/historial/domain/usecases/obtener_mi_historial.dart';
import 'package:ciemsi_app/features/historial/domain/usecases/agregar_nota.dart';
import 'package:ciemsi_app/features/historial/domain/usecases/agregar_link.dart';
import 'package:ciemsi_app/features/historial/domain/usecases/subir_archivo_drive.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/core/di/app_dependencies.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleCitaPage extends StatelessWidget {
  final CitaMedica cita;
  final Usuario usuario;
  const DetalleCitaPage({super.key, required this.cita, required this.usuario});

  static const _primario = Color(0xFF00B5C8);
  static const _verde = Color(0xFF8DC63F);

  Color _colorEstado(EstadoCita e) {
    switch (e) {
      case EstadoCita.PENDIENTE:
        return Colors.orange;
      case EstadoCita.PENDIENTE_PAGO:
        return Colors.deepOrange;
      case EstadoCita.MODIFICADA:
        return Colors.purple;
      case EstadoCita.CONFIRMADA:
        return _primario;
      case EstadoCita.CANCELADA:
        return Colors.red;
      case EstadoCita.COMPLETADA:
        return _verde;
    }
  }

  IconData _iconoEstado(EstadoCita e) {
    switch (e) {
      case EstadoCita.PENDIENTE:
        return Icons.schedule_rounded;
      case EstadoCita.PENDIENTE_PAGO:
        return Icons.payment_rounded;
      case EstadoCita.MODIFICADA:
        return Icons.edit_calendar_rounded;
      case EstadoCita.CONFIRMADA:
        return Icons.check_circle_rounded;
      case EstadoCita.CANCELADA:
        return Icons.cancel_rounded;
      case EstadoCita.COMPLETADA:
        return Icons.task_alt_rounded;
    }
  }

  String _textoEstado(EstadoCita e) {
    switch (e) {
      case EstadoCita.PENDIENTE:
        return 'En espera de confirmación';
      case EstadoCita.PENDIENTE_PAGO:
        return 'Esperando comprobante de pago';
      case EstadoCita.MODIFICADA:
        return 'Solicitud de modificación pendiente';
      case EstadoCita.CONFIRMADA:
        return 'Cita médica confirmada';
      case EstadoCita.CANCELADA:
        return 'Esta cita fue cancelada';
      case EstadoCita.COMPLETADA:
        return 'Cita realizada con éxito';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _colorEstado(cita.estado);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Detalle de Cita',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primario,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocListener<CitaBloc, CitaState>(
        listener: (context, state) {
          if (state is EstadoCitaCambiado || state is PagoConfirmado) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is PagoConfirmado
                      ? 'Pago confirmado y cita confirmada correctamente'
                      : 'Estado actualizado correctamente',
                ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBanner(colorEstado),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientCard(),
                    const SizedBox(height: 12),
                    _buildAppointmentCard(),
                    const SizedBox(height: 24),
                    _buildActionsSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Banner de estado ─────────────────────────────────────────────────────

  Widget _buildStatusBanner(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(color: color.withValues(alpha: 0.18), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconoEstado(cita.estado), color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cita.estado.name,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _textoEstado(cita.estado),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tarjeta del paciente ─────────────────────────────────────────────────

  Widget _buildPatientCard() {
    final esProvisional = cita.paciente.ci.startsWith('PROV-');
    final inicial = cita.paciente.nombreCompleto.isNotEmpty
        ? cita.paciente.nombreCompleto[0].toUpperCase()
        : 'P';

    return _InfoCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: _primario,
            child: Text(
              inicial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cita.paciente.nombreCompleto,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 13,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      esProvisional
                          ? 'Paciente provisional'
                          : 'CI: ${cita.paciente.ci}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                if (esProvisional) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 12,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Datos incompletos',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tarjeta de detalles de la cita ───────────────────────────────────────

  Widget _buildAppointmentCard() {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_note_rounded, color: _primario, size: 17),
              const SizedBox(width: 8),
              const Text(
                'Información de la cita',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: _primario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.medical_services_outlined,
            'Servicio',
            cita.servicio.nombreServicio,
          ),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Fecha',
            DateFormat("EEEE d 'de' MMMM yyyy", 'es').format(cita.fecha),
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
            _buildInfoRow(Icons.notes_outlined, 'Notas', cita.notas!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primario, size: 16),
          const SizedBox(width: 10),
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sección de acciones ──────────────────────────────────────────────────

  Widget _buildActionsSection(BuildContext context) {
    return BlocBuilder<CitaBloc, CitaState>(
      builder: (context, state) {
        final loading = state is CitaLoading;
        final puedeGestionarCita = usuario.rol != 'Paciente';
        final esPaciente = usuario.rol == 'Paciente';
        final tiles = <Widget>[];

        // PENDIENTE_PAGO
        if (cita.estado == EstadoCita.PENDIENTE_PAGO) {
          tiles.add(_sectionLabel('Pago adelantado'));
          if (cita.tieneComprobante) {
            tiles.add(
              _actionTile(
                icon: Icons.receipt_long_outlined,
                color: Colors.teal,
                title: 'Ver comprobante',
                subtitle: 'Revisar el comprobante subido por el paciente',
                onTap: loading ? null : () => _verComprobante(context),
              ),
            );
            if (puedeGestionarCita) {
              tiles.add(
                _actionTile(
                  icon: Icons.check_circle_outline,
                  color: _verde,
                  title: 'Confirmar Pago y Cita',
                  subtitle: 'Verificar pago y confirmar la cita',
                  onTap: loading
                      ? null
                      : () => context.read<CitaBloc>().add(
                          ConfirmarPagoEvent(cita.id),
                        ),
                ),
              );
            }
          } else {
            tiles.add(
              _actionTile(
                icon: Icons.upload_file_outlined,
                color: Colors.orange,
                title: esPaciente ? 'Subir comprobante' : 'Aún sin comprobante',
                subtitle: esPaciente
                    ? 'Completa el pago adelantado para confirmar tu reserva'
                    : 'El paciente no ha subido el comprobante de pago',
                onTap: esPaciente && !loading
                    ? () => _abrirPagoAdelanto(context)
                    : null,
              ),
            );
          }
          if (puedeGestionarCita) {
            tiles.add(
              _actionTile(
                icon: Icons.cancel_outlined,
                color: Colors.red,
                title: 'Cancelar Cita',
                subtitle: 'Esta acción no se puede deshacer',
                onTap: loading ? null : () => _mostrarDialogoCancelar(context),
                isDestructive: true,
              ),
            );
          }
        }

        if (!puedeGestionarCita) {
          if (tiles.isEmpty) return const SizedBox();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tiles,
          );
        }

        // PENDIENTE
        if (cita.estado == EstadoCita.PENDIENTE) {
          tiles.add(_sectionLabel('Estado de la cita'));
          tiles.add(
            _actionTile(
              icon: Icons.check_circle_outline,
              color: _primario,
              title: 'Confirmar Cita',
              subtitle: 'Marcar como confirmada',
              onTap: loading
                  ? null
                  : () => _cambiarEstado(context, 'CONFIRMADA'),
            ),
          );
          tiles.add(
            _actionTile(
              icon: Icons.edit_calendar_outlined,
              color: Colors.purple,
              title: 'Modificar Cita',
              subtitle: 'Cambiar fecha u hora',
              onTap: loading
                  ? null
                  : () => Navigator.push(
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
          tiles.add(
            _actionTile(
              icon: Icons.cancel_outlined,
              color: Colors.red,
              title: 'Cancelar Cita',
              subtitle: 'Esta acción no se puede deshacer',
              onTap: loading ? null : () => _mostrarDialogoCancelar(context),
              isDestructive: true,
            ),
          );
        }

        // MODIFICADA
        if (cita.estado == EstadoCita.MODIFICADA) {
          tiles.add(_sectionLabel('Revisión de cambios'));
          tiles.add(
            _actionTile(
              icon: Icons.check_circle_outline,
              color: _verde,
              title: 'Aceptar Modificación',
              subtitle: 'Confirmar los nuevos datos',
              onTap: loading
                  ? null
                  : () => _cambiarEstado(context, 'CONFIRMADA'),
            ),
          );
          tiles.add(
            _actionTile(
              icon: Icons.cancel_outlined,
              color: Colors.red,
              title: 'Rechazar y Cancelar',
              subtitle: 'No aceptar la modificación',
              onTap: loading ? null : () => _mostrarDialogoCancelar(context),
              isDestructive: true,
            ),
          );
        }

        // CONFIRMADA
        if (cita.estado == EstadoCita.CONFIRMADA) {
          final esProvisional = cita.paciente.ci.startsWith('PROV-');

          if (esProvisional) {
            tiles.add(_sectionLabel('Atención requerida'));
            tiles.add(
              _actionTile(
                icon: Icons.person_add_alt_1_outlined,
                color: Colors.orange,
                title: 'Completar datos del paciente',
                subtitle: 'Requerido antes de cerrar la cita',
                onTap: loading
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<PacienteBloc>(),
                            child: CompletarPacientePage(
                              paciente: cita.paciente,
                            ),
                          ),
                        ),
                      ),
                isWarning: true,
              ),
            );
          }

          tiles.add(_sectionLabel('Gestión médica'));
          tiles.add(
            _actionTile(
              icon: Icons.folder_open_outlined,
              color: _primario,
              title: 'Historial Clínico',
              subtitle: 'Ver y gestionar notas, imágenes y videos',
              onTap: loading ? null : () => _navigateToHistorial(context),
            ),
          );
          tiles.add(
            _actionTile(
              icon: Icons.healing_outlined,
              color: Colors.purple,
              title: 'Asignar Tratamiento',
              subtitle: 'Registrar plan de tratamiento',
              onTap: loading
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) =>
                              AppDependencies.createTratamientoBloc(),
                          child: AsignarTratamientoPage(cita: cita),
                        ),
                      ),
                    ),
            ),
          );
          tiles.add(
            _actionTile(
              icon: Icons.receipt_long_outlined,
              color: _verde,
              title: 'Generar Receta',
              subtitle: 'Emitir prescripción médica',
              onTap: loading
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (_) =>
                                  AppDependencies.createTratamientoBloc(),
                            ),
                            BlocProvider(
                              create: (_) => AppDependencies.createRecetaBloc(),
                            ),
                          ],
                          child: GenerarRecetaPage(cita: cita),
                        ),
                      ),
                    ),
            ),
          );

          tiles.add(_sectionLabel('Estado de la cita'));
          tiles.add(
            _actionTile(
              icon: Icons.task_alt_rounded,
              color: _verde,
              title: 'Marcar como Completada',
              subtitle: esProvisional
                  ? 'Completa primero los datos del paciente'
                  : 'Cerrar esta cita como realizada',
              onTap: esProvisional || loading
                  ? null
                  : () => _cambiarEstado(context, 'COMPLETADA'),
              isDisabled: esProvisional,
            ),
          );
          tiles.add(
            _actionTile(
              icon: Icons.cancel_outlined,
              color: Colors.red,
              title: 'Cancelar Cita',
              subtitle: 'Esta acción no se puede deshacer',
              onTap: loading ? null : () => _mostrarDialogoCancelar(context),
              isDestructive: true,
            ),
          );
        }

        if (loading) {
          tiles.add(
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(child: CircularProgressIndicator(color: _primario)),
            ),
          );
        }

        if (tiles.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: tiles,
        );
      },
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
    bool isWarning = false,
    bool isDisabled = false,
  }) {
    final tileColor = isDestructive
        ? Colors.red
        : isWarning
        ? Colors.orange
        : color;

    return Opacity(
      opacity: isDisabled ? 0.45 : 1.0,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.25)
                : isWarning
                ? Colors.orange.withValues(alpha: 0.25)
                : Colors.grey.shade200,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tileColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: tileColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDestructive ? Colors.red : Colors.black87,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: onTap == null
                      ? Colors.grey.shade300
                      : Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Navegación ───────────────────────────────────────────────────────────

  void _navigateToHistorial(BuildContext context) {
    final apiClient = ApiClientProvider.instance;
    final datasource = HistorialRemoteDatasource(apiClient);
    final repository = HistorialRepositoryImpl(datasource);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => HistorialBloc(
            obtenerHistorialUseCase: ObtenerHistorialUseCase(repository),
            obtenerMiHistorialUseCase: ObtenerMiHistorialUseCase(repository),
            agregarNotaUseCase: AgregarNotaUseCase(repository),
            agregarLinkUseCase: AgregarLinkUseCase(repository),
            subirArchivoDriveUseCase: SubirArchivoDriveUseCase(repository),
          ),
          child: HistorialPage(paciente: cita.paciente),
        ),
      ),
    );
  }

  Future<void> _verComprobante(BuildContext context) async {
    if (cita.comprobantePath == null) return;
    final baseUrl = ApiClientProvider.instance.dio.options.baseUrl.replaceAll(
      RegExp(r'/api$'),
      '',
    );
    final uri = Uri.parse('$baseUrl${cita.comprobantePath}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el comprobante')),
        );
      }
    }
  }

  void _abrirPagoAdelanto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CitaBloc>(),
          child: PagoAdelantoPage(citaId: cita.id),
        ),
      ),
    );
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: Colors.red,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Cancelar Cita', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro? Esta acción no se puede deshacer.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: notasController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Motivo de cancelación (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primario, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Volver', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget auxiliar para tarjetas de información ─────────────────────────────

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}
