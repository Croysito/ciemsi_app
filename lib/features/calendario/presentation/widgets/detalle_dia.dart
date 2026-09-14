import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';
import 'package:ciemsi_app/features/agenda/domain/entities/agenda.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/citas/domain/entities/estado_cita_extension.dart';
import '../controllers/ciudad_color_controller.dart';
import 'cita_card.dart';
import 'franja_horario_card.dart';
import 'modo_switch.dart';

/// Detalle del día seleccionado: en modo Citas las franjas son contexto y
/// las citas son las protagonistas — agrupadas por **ciudad** (P3 addendum:
/// con las tres ciudades siempre visibles a la vez, agrupar por ciudad es
/// lo que evita confundir un 08:00 de Cochabamba con uno de La Paz); en
/// modo Horarios se invierte, una tarjeta por franja. Las citas se agrupan
/// dentro de la franja cuyo rango horario las contiene (no hay vínculo
/// explícito cita→franja en el modelo de datos, así que se infiere por
/// hora); una cita fuera de todo rango se muestra bajo "Fuera de horario".
/// Nunca una lista vacía muda: siempre hay un mensaje o un CTA.
class DetalleDia extends StatelessWidget {
  final DateTime dia;
  final ModoCalendario modo;
  final List<Agenda> franjas;
  final List<CitaMedica> citas;
  final CiudadColorController colores;
  final bool cargando;
  final String? error;
  final VoidCallback? onReintentar;
  final ValueChanged<CitaMedica> onTapCita;
  final ValueChanged<Agenda> onTapFranja;
  final VoidCallback onAbrirHorario;

  const DetalleDia({
    super.key,
    required this.dia,
    required this.modo,
    required this.franjas,
    required this.citas,
    required this.colores,
    required this.cargando,
    required this.error,
    required this.onReintentar,
    required this.onTapCita,
    required this.onTapFranja,
    required this.onAbrirHorario,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _encabezado(),
        const SizedBox(height: 8),
        if (cargando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
          )
        else if (error != null)
          _estadoError()
        else
          _contenido(),
      ],
    );
  }

  Widget _encabezado() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          DateFormat("EEEE d", 'es_ES').format(dia),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF16191C)),
        ),
        const SizedBox(width: 8),
        Text(
          '${citas.length} citas · ${franjas.length} horarios abiertos',
          style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
        ),
      ],
    );
  }

  Widget _estadoError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(error!, style: const TextStyle(color: AppColors.danger), textAlign: TextAlign.center),
          if (onReintentar != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onReintentar, child: const Text('Reintentar')),
          ],
        ],
      ),
    );
  }

  Widget _contenido() {
    if (franjas.isEmpty && citas.isEmpty) {
      return _estadoVacio();
    }
    return modo == ModoCalendario.citas ? _contenidoPorCiudad() : _contenidoHorarios();
  }

  /// Modo Citas: una ciudad por grupo, orden alfabético (estable entre
  /// renders — no "por orden de llegada").
  Widget _contenidoPorCiudad() {
    final ciudades = {
      ...citas.map((c) => c.ciudad.nombreCiudad),
      ...franjas.map((f) => f.ciudad.nombreCiudad),
    }.toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final ciudad in ciudades) _grupoCiudad(ciudad),
      ],
    );
  }

  Widget _grupoCiudad(String ciudad) {
    final estilo = colores.estiloPara(ciudad);
    final franjasCiudad = franjas.where((f) => f.ciudad.nombreCiudad == ciudad).toList();
    final citasCiudad = [...citas.where((c) => c.ciudad.nombreCiudad == ciudad)]
      ..sort((a, b) => a.hora.compareTo(b.hora));

    final citasPorFranja = <int, List<CitaMedica>>{};
    final fuera = <CitaMedica>[];
    for (final c in citasCiudad) {
      final franja = _franjaParaCita(c, franjasCiudad);
      if (franja != null) {
        citasPorFranja.putIfAbsent(franja.id, () => []).add(c);
      } else {
        fuera.add(c);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _encabezadoCiudad(ciudad, estilo),
          const SizedBox(height: 8),
          for (final franja in franjasCiudad) ...[
            FranjaHorarioCard(
              agenda: franja,
              cuposLibres: _cuposLibres(franja, citasPorFranja[franja.id] ?? []),
              compacto: true,
              color: estilo.color,
              colorTexto: estilo.colorTexto,
              onTap: () => onTapFranja(franja),
            ),
            for (final c in citasPorFranja[franja.id] ?? [])
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 8),
                child: CitaCard(cita: c, colorCiudad: estilo.color, onTap: () => onTapCita(c)),
              ),
          ],
          if (fuera.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Fuera de horario',
                style: TextStyle(fontSize: 12, color: AppColors.inkMuted, fontWeight: FontWeight.w600),
              ),
            ),
            for (final c in fuera) CitaCard(cita: c, colorCiudad: estilo.color, onTap: () => onTapCita(c)),
          ],
        ],
      ),
    );
  }

  Widget _encabezadoCiudad(String ciudad, CiudadEstilo estilo) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: estilo.color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(ciudad, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: estilo.colorTexto)),
        const SizedBox(width: 10),
        const Expanded(child: Divider(height: 1, color: Color(0xFFE6E8EA))),
      ],
    );
  }

  /// Modo Horarios: una tarjeta completa por franja — con sus citas
  /// anidadas como referencia — sin agrupar por ciudad; cada tarjeta ya
  /// lleva su ciudad en la segunda línea.
  Widget _contenidoHorarios() {
    if (franjas.isEmpty) return _estadoVacio();

    final citasOrdenadas = [...citas]..sort((a, b) => a.hora.compareTo(b.hora));
    final citasPorFranja = <int, List<CitaMedica>>{};
    final fuera = <CitaMedica>[];
    for (final c in citasOrdenadas) {
      final franja = _franjaDeCualquierCiudad(c);
      if (franja != null) {
        citasPorFranja.putIfAbsent(franja.id, () => []).add(c);
      } else {
        fuera.add(c);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final franja in franjas) ...[
          FranjaHorarioCard(
            agenda: franja,
            cuposLibres: _cuposLibres(franja, citasPorFranja[franja.id] ?? []),
            compacto: false,
            color: colores.estiloPara(franja.ciudad.nombreCiudad).color,
            colorTexto: colores.estiloPara(franja.ciudad.nombreCiudad).colorTexto,
            onTap: () => onTapFranja(franja),
          ),
          for (final c in citasPorFranja[franja.id] ?? [])
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 8),
              child: _LineaCitaCompacta(cita: c, onTap: () => onTapCita(c)),
            ),
        ],
        if (fuera.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'Fuera de horario',
              style: TextStyle(fontSize: 12, color: AppColors.inkMuted, fontWeight: FontWeight.w600),
            ),
          ),
          for (final c in fuera) _LineaCitaCompacta(cita: c, onTap: () => onTapCita(c)),
        ],
      ],
    );
  }

  /// Igual que [_franjaParaCita] pero recorriendo todas las franjas del
  /// día (modo Horarios no filtra por ciudad antes de llamar acá).
  Agenda? _franjaDeCualquierCiudad(CitaMedica cita) {
    final minutos = _parseMinutos(cita.hora);
    for (final f in franjas) {
      if (f.ciudad.id != cita.ciudad.id) continue;
      final inicio = _parseMinutos(f.horaInicio);
      final fin = _parseMinutos(f.horaFin);
      if (minutos >= inicio && minutos < fin) return f;
    }
    return null;
  }

  Widget _estadoVacio() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text('Sin citas ni horarios este día', style: TextStyle(color: AppColors.inkMuted)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onAbrirHorario,
            icon: const Icon(Icons.event_available_outlined, color: AppColors.teal),
            label: const Text('Abrir horario', style: TextStyle(color: AppColors.teal)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.teal)),
          ),
        ],
      ),
    );
  }

  /// Franja a la que pertenece [cita] dentro de [franjasCiudad]: sólo hace
  /// falta comparar hora porque ya viene filtrado a la ciudad de la cita.
  Agenda? _franjaParaCita(CitaMedica cita, List<Agenda> franjasCiudad) {
    final minutos = _parseMinutos(cita.hora);
    for (final f in franjasCiudad) {
      final inicio = _parseMinutos(f.horaInicio);
      final fin = _parseMinutos(f.horaFin);
      if (minutos >= inicio && minutos < fin) return f;
    }
    return null;
  }

  int _cuposLibres(Agenda franja, List<CitaMedica> citasDeFranja) {
    final total = _contarSlots(franja.horaInicio, franja.horaFin, franja.intervalo);
    final ocupados = citasDeFranja.where((c) => !c.estado.esCancelada).length;
    return (total - ocupados).clamp(0, total);
  }

  int _contarSlots(String horaInicio, String horaFin, int intervalo) {
    final diff = _parseMinutos(horaFin) - _parseMinutos(horaInicio);
    if (diff <= 0 || intervalo <= 0) return 0;
    return diff ~/ intervalo;
  }

  int _parseMinutos(String hora) {
    final partes = hora.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }
}

/// Línea de cita dentro de una franja en modo Horarios: sólo referencia,
/// nada que ver con el color de ciudad de la sección 1 (esa regla es
/// específica de la lista de modo Citas).
class _LineaCitaCompacta extends StatelessWidget {
  final CitaMedica cita;
  final VoidCallback onTap;

  const _LineaCitaCompacta({required this.cita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = cita.estado.color;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                cita.hora.length >= 5 ? cita.hora.substring(0, 5) : cita.hora,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            Expanded(
              child: Text(
                cita.paciente.nombreCompleto,
                style: const TextStyle(fontSize: 12, color: AppColors.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(cita.estado.label, style: TextStyle(fontSize: 11, color: cita.estado.colorTexto)),
          ],
        ),
      ),
    );
  }
}
