import 'package:ciemsi_app/features/pacientes/presentation/bloc/paciente_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/paciente.dart';
import '../../../historial/presentation/pages/historial_page.dart';
import '../../../../core/di/app_dependencies.dart';
import 'package:ciemsi_app/features/pacientes/presentation/pages/modificar_paciente_page.dart';
import 'package:ciemsi_app/features/pagos/presentation/pages/estado_cuenta_page.dart';

class DetallePacientePage extends StatelessWidget {
  final Paciente paciente;
  const DetallePacientePage({super.key, required this.paciente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
          paciente.nombreCompleto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF00B5C8),
              child: Text(
                paciente.nombreCompleto[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              paciente.nombreCompleto,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              paciente.ciudad!.nombreCiudad,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Info card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.badge_outlined, 'CI', paciente.ci),
                    if (paciente.edad != null)
                      _buildInfoRow(
                        Icons.cake_outlined,
                        'Edad',
                        '${paciente.edad} años',
                      ),
                    if (paciente.telefono != null)
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Teléfono',
                        paciente.telefono!,
                      ),
                    if (paciente.fechaNacimiento != null)
                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        'Fecha de nacimiento',
                        DateFormat('dd/MM/yyyy').format(paciente.fechaNacimiento!),
                      ),
                    if (paciente.genero != null)
                      _buildInfoRow(
                        Icons.wc_outlined,
                        'Género',
                        paciente.genero == 'M' ? 'Masculino' : 'Femenino',
                      ),
                    _buildInfoRow(
                      Icons.location_city_outlined,
                      'Ciudad',
                      paciente.ciudad?.nombreCiudad ?? 'Sin ciudad',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón ver historial
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => AppDependencies.createHistorialBloc(),
                        child: HistorialPage(paciente: paciente),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history, color: Colors.white),
                label: const Text(
                  'Ver Historial Clínico',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B5C8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EstadoCuentaPage(
                        pacienteId: paciente.id,
                        ciudadId: paciente.ciudad!.id,
                        nombrePaciente: paciente.nombreCompleto,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long, color: Colors.white),
                label: const Text(
                  'Estado de Cuenta',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8DC63F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final modificado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<PacienteBloc>(),
                        child: ModificarPacientePage(paciente: paciente),
                      ),
                    ),
                  );
                  if (modificado == true) {
                    Navigator.pop(context, true);
                  }
                },
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF8DC63F)),
                label: const Text(
                  'Modificar Datos',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8DC63F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF8DC63F)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
