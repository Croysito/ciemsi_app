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
        return BlocProvider.value(
          value: context.read<CitaBloc>(),
          child: ReservarCitaAsistentePage(
            ciudadId: usuario.ciudad!.id,
            ciudadNombre: usuario.ciudad!.nombreCiudad,
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
