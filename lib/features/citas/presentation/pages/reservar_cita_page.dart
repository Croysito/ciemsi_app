import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'reservar_cita_doctora_page.dart';
import 'reservar_cita_asistente_page.dart';
import 'reservar_cita_paciente_page.dart';

class ReservarCitaPage extends StatelessWidget {
  final Usuario usuario;
  const ReservarCitaPage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    switch (usuario.rol) {
      case 'Doctora':
        return BlocProvider.value(
          value: context.read<CitaBloc>(),
          child: const ReservarCitaDoctoraPage(),
        );
      case 'Asistente':
        final ciudad = usuario.ciudad;
        if (ciudad == null) {
          return const _CiudadNoAsignadaPage();
        }

        return BlocProvider.value(
          value: context.read<CitaBloc>(),
          child: ReservarCitaAsistentePage(
            ciudadId: ciudad.id,
            ciudadNombre: ciudad.nombreCiudad,
          ),
        );
      default:
        return BlocProvider.value(
          value: context.read<CitaBloc>(),
          child: const ReservarCitaPacientePage(),
        );
    }
  }
}

class _CiudadNoAsignadaPage extends StatelessWidget {
  const _CiudadNoAsignadaPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Nueva Cita',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Tu usuario no tiene una ciudad asignada. No se puede reservar una cita.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
