import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_event.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_state.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';

class ModificarCitaPage extends StatefulWidget {
  final CitaMedica cita;
  const ModificarCitaPage({super.key, required this.cita});

  @override
  State<ModificarCitaPage> createState() => _ModificarCitaPageState();
}

class _ModificarCitaPageState extends State<ModificarCitaPage> {
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada;
  Servicio? _servicioSeleccionado;
  List<Servicio> _servicios = [];
  List<String> _horasDisponibles = [];
  final _notasController = TextEditingController();
  bool _cargandoHoras = false;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = widget.cita.fecha;
    _horaSeleccionada = widget.cita.hora.substring(0, 5);
    _notasController.text = widget.cita.notas ?? '';
    context.read<CitaBloc>().add(CargarServiciosEvent());
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDate:
          _fechaSeleccionada ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF00B5C8)),
        ),
        child: child!,
      ),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _horaSeleccionada = null;
        _horasDisponibles = [];
        _cargandoHoras = true;
      });

      context.read<CitaBloc>().add(
        CargarDisponibilidadEvent(
          ciudadId: widget.cita.ciudad.id,
          fecha: DateFormat('yyyy-MM-dd').format(fecha),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Modificar Cita',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00B5C8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<CitaBloc, CitaState>(
        listener: (context, state) {
          if (state is ServiciosCargados) {
            setState(() {
              _servicios = state.servicios;
              try {
                _servicioSeleccionado = _servicios.firstWhere(
                  (s) => s.id == widget.cita.servicio.id,
                );
              } catch (e) {
                _servicioSeleccionado = null;
              }
            });
          }
          if (state is DisponibilidadCargada) {
            setState(() {
              _horasDisponibles = state.horasDisponibles;
              _cargandoHoras = false;
            });
          }
          if (state is CitaModificada) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cita modificada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
            Navigator.pop(context, true);
          }
          if (state is CitaError) {
            setState(() => _cargandoHoras = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Servicio
              const Text(
                'Servicio',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Servicio>(
                    isExpanded: true,
                    hint: const Text('Seleccionar servicio'),
                    value: _servicioSeleccionado,
                    items: _servicios
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              '${s.nombreServicio} (${s.tiempoMin} min)',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _servicioSeleccionado = value),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fecha
              const Text(
                'Nueva Fecha',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _seleccionarFecha,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF00B5C8),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _fechaSeleccionada != null
                            ? DateFormat(
                                'dd/MM/yyyy',
                              ).format(_fechaSeleccionada!)
                            : 'Seleccionar fecha',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Horas
              if (_fechaSeleccionada != null) ...[
                const Text(
                  'Nueva Hora',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B5C8),
                  ),
                ),
                const SizedBox(height: 8),
                if (_cargandoHoras)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00B5C8)),
                  )
                else if (_horasDisponibles.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'No hay horas disponibles',
                      style: TextStyle(color: Colors.orange),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _horasDisponibles.map((hora) {
                      final seleccionada = _horaSeleccionada == hora;
                      return GestureDetector(
                        onTap: () => setState(() => _horaSeleccionada = hora),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: seleccionada
                                ? const Color(0xFF00B5C8)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: seleccionada
                                  ? const Color(0xFF00B5C8)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            hora,
                            style: TextStyle(
                              color: seleccionada ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
              ],

              // Notas
              const Text(
                'Notas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B5C8),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notasController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Explica el motivo de la modificación...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              BlocBuilder<CitaBloc, CitaState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: state is CitaLoading
                          ? null
                          : () {
                              if (_servicioSeleccionado == null ||
                                  _fechaSeleccionada == null ||
                                  _horaSeleccionada == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Selecciona servicio, fecha y hora',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              context.read<CitaBloc>().add(
                                ModificarCitaEvent(
                                  id: widget.cita.id,
                                  fecha: DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(_fechaSeleccionada!),
                                  hora: _horaSeleccionada!,
                                  servicioId: _servicioSeleccionado!.id,
                                  notas: _notasController.text.trim().isEmpty
                                      ? null
                                      : _notasController.text.trim(),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DC63F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state is CitaLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Guardar Modificación',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
