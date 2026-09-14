import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:ciemsi_app/core/di/app_dependencies.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'package:ciemsi_app/core/theme/app_colors.dart';
import 'package:ciemsi_app/features/agenda/domain/entities/agenda.dart';
import 'package:ciemsi_app/features/agenda/domain/utils/agenda_dia_utils.dart';
import 'package:ciemsi_app/features/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:ciemsi_app/features/agenda/presentation/bloc/agenda_event.dart';
import 'package:ciemsi_app/features/agenda/presentation/bloc/agenda_state.dart';
import 'package:ciemsi_app/features/agenda/presentation/pages/crear_agenda.dart';
import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';
import 'package:ciemsi_app/features/citas/domain/entities/disponibilidad_dia.dart';
import 'package:ciemsi_app/features/citas/domain/entities/reservar_cita_config.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_event.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_state.dart';
import 'package:ciemsi_app/features/citas/presentation/controllers/paciente_busqueda_controller.dart';
import 'package:ciemsi_app/features/citas/presentation/widgets/reservar_cita/calendario_mes.dart';
import 'package:ciemsi_app/features/citas/presentation/widgets/reservar_cita/horas_disponibles.dart';
import 'package:ciemsi_app/features/citas/presentation/widgets/reservar_cita/pie_reserva.dart';
import 'package:ciemsi_app/features/citas/presentation/widgets/reservar_cita/tarjeta_abrir_horario.dart';
import 'package:ciemsi_app/features/citas/presentation/widgets/reservar_cita/tarjeta_paciente.dart';
import 'package:ciemsi_app/features/pacientes/domain/entities/ciudad.dart';
import 'package:ciemsi_app/features/servicios/domain/entities/servicio.dart';
import 'pago_adelanto_page.dart';

/// P2 · Nueva cita — un día sin horario deja de ser un callejón sin salida:
/// se puede abrir la franja aquí mismo. Unifica las 4 variantes de reserva
/// (Doctora, Asistente, Asistente multi-ciudad, Paciente) en una sola
/// pantalla parametrizada por [ReservarCitaConfig], en vez de 3 páginas
/// que copiaban casi todo su código entre sí.
class ReservarCitaPage extends StatelessWidget {
  final Usuario usuario;

  /// Fecha con la que llega el flujo (ej. desde el calendario unificado,
  /// "Nueva cita" del día ya seleccionado) — se preselecciona apenas se
  /// conoce la ciudad, sin obligar a un segundo tap.
  final DateTime? fechaInicial;

  const ReservarCitaPage({super.key, required this.usuario, this.fechaInicial});

  @override
  Widget build(BuildContext context) {
    if (usuario.rol == 'Asistente' && !usuario.veTodasCiudades && usuario.ciudad == null) {
      return const _CiudadNoAsignadaPage();
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<CitaBloc>()),
        BlocProvider(create: (_) => AppDependencies.createAgendaBloc()),
      ],
      child: _ReservarCitaView(
        usuario: usuario,
        config: ReservarCitaConfig.paraUsuario(usuario),
        fechaInicial: fechaInicial,
      ),
    );
  }
}

class _ReservarCitaView extends StatefulWidget {
  final Usuario usuario;
  final ReservarCitaConfig config;
  final DateTime? fechaInicial;
  const _ReservarCitaView({required this.usuario, required this.config, this.fechaInicial});

  @override
  State<_ReservarCitaView> createState() => _ReservarCitaViewState();
}

class _ReservarCitaViewState extends State<_ReservarCitaView> {
  static DateTime get _hoy {
    final ahora = DateTime.now();
    return DateTime(ahora.year, ahora.month, ahora.day);
  }

  final PacienteBusquedaController _pacienteCtrl = PacienteBusquedaController();
  final _buscadorController = TextEditingController();
  final _nombreNuevoController = TextEditingController();
  final _telefonoNuevoController = TextEditingController();
  final _notasController = TextEditingController();

  int? _ciudadId;
  String? _ciudadNombre;
  List<Ciudad> _ciudadesDisponibles = [];

  List<Servicio> _servicios = [];
  Servicio? _servicioSeleccionado;
  bool _cargandoServicios = true;
  String? _advertenciaServicio;

  late DateTime _mesVisible;
  final Map<String, List<DisponibilidadDia>> _cacheMeses = {};
  Map<String, DisponibilidadDia> _disponibilidadMesActual = {};
  bool _cargandoMes = true;

  List<Agenda> _agendasCiudad = [];
  DateTime? _fechaSeleccionada;
  bool _diaTieneAgendaDoctora = false;
  bool _diaTieneAgendaAsistente = false;
  String? _rolAgendaSeleccionado;
  int? _agendaSeleccionadaId;
  List<String> _horasDisponibles = [];
  String? _horaSeleccionada;
  bool _cargandoHoras = false;

  TimeOfDay _desde = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _hasta = const TimeOfDay(hour: 12, minute: 0);
  int _intervaloNuevo = 30;
  String _rolNuevaAgenda = 'Doctora';
  bool _creandoHorario = false;
  String? _errorCrearHorario;

  bool _tieneAdelanto = false;
  String _adelantoMetodo = 'qr';
  static const _adelantoMonto = 50.0;

  bool _reservando = false;

  @override
  void initState() {
    super.initState();
    final inicial = widget.fechaInicial;
    _mesVisible = inicial != null ? DateTime(inicial.year, inicial.month, 1) : DateTime(_hoy.year, _hoy.month, 1);
    if (inicial != null && !inicial.isBefore(_hoy)) {
      _fechaSeleccionada = DateTime(inicial.year, inicial.month, inicial.day);
    }
    _pacienteCtrl.addListener(_onPacienteCtrlChanged);
    context.read<CitaBloc>().add(CargarServiciosEvent());

    if (widget.config.ciudadFijaId != null) {
      _ciudadId = widget.config.ciudadFijaId;
      _ciudadNombre = widget.config.ciudadFijaNombre;
      _despuesDeCiudad();
    } else if (widget.config.esPaciente) {
      // El paciente es él mismo: se siembra un registro "seleccionado" sólo
      // para reusar la tarjeta de resumen (nombre + servicio); el backend
      // infiere el pacienteId real desde el usuario autenticado.
      _pacienteCtrl.seleccionar({
        'ci': '',
        'usuario': {'nombre': widget.usuario.nombre, 'apellido': widget.usuario.apellido},
      });
      _cargarCiudadPaciente();
    } else if (widget.config.puedeElegirCiudad) {
      context.read<AgendaBloc>().add(CargarCiudadesAgendaEvent());
    }
  }

  @override
  void dispose() {
    _pacienteCtrl.removeListener(_onPacienteCtrlChanged);
    _pacienteCtrl.dispose();
    _buscadorController.dispose();
    _nombreNuevoController.dispose();
    _telefonoNuevoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _onPacienteCtrlChanged() {
    if (mounted) setState(() {});
  }

  // ---------------------------------------------------------------------
  // Ciudad
  // ---------------------------------------------------------------------

  Future<void> _cargarCiudadPaciente() async {
    try {
      final response = await ApiClientProvider.instance.dio.get('/pacientes/mi-perfil');
      final ciudad = response.data['usuario']?['ciudad'];
      if (ciudad != null && mounted) {
        setState(() {
          _ciudadId = ciudad['id'];
          _ciudadNombre = ciudad['nombreCiudad'];
        });
        _despuesDeCiudad();
      }
    } catch (_) {
      // El calendario queda en el estado "esperando ciudad"; nada que
      // reservar sin una ciudad conocida.
    }
  }

  void _onCiudadElegida(Ciudad ciudad) {
    setState(() {
      _ciudadId = ciudad.id;
      _ciudadNombre = ciudad.nombreCiudad;
      _agendasCiudad = [];
      _fechaSeleccionada = null;
      _horaSeleccionada = null;
      _horasDisponibles = [];
      _cacheMeses.clear();
      _disponibilidadMesActual = {};
    });
    _despuesDeCiudad();
  }

  void _despuesDeCiudad() {
    if (_ciudadId == null) return;
    context.read<AgendaBloc>().add(CargarAgendasEvent(ciudadId: _ciudadId));
    _cargarMes(_mesVisible);
    if (!widget.config.esPaciente) _pacienteCtrl.cargar(ciudadId: _ciudadId);
  }

  // ---------------------------------------------------------------------
  // Mes / calendario (una llamada por mes en vez de una por día)
  // ---------------------------------------------------------------------

  String _mesKey(DateTime mes) => '${mes.year}-${mes.month}';
  String _fmtDia(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  void _cargarMes(DateTime mes) {
    if (_ciudadId == null) return;
    final key = _mesKey(mes);
    final cacheado = _cacheMeses[key];
    if (cacheado != null) {
      setState(() {
        _disponibilidadMesActual = {for (final d in cacheado) _fmtDia(d.fecha): d};
        _cargandoMes = false;
      });
      return;
    }
    setState(() => _cargandoMes = true);
    context.read<CitaBloc>().add(
      CargarDisponibilidadMesEvent(ciudadId: _ciudadId!, anio: mes.year, mes: mes.month),
    );
  }

  void _onMesCambiado(DateTime nuevoMes) {
    setState(() => _mesVisible = DateTime(nuevoMes.year, nuevoMes.month, 1));
    _cargarMes(_mesVisible);
  }

  // ---------------------------------------------------------------------
  // Selección de día / agenda / horas
  // ---------------------------------------------------------------------

  void _seleccionarFecha(DateTime dia) {
    setState(() {
      _fechaSeleccionada = dia;
      _horaSeleccionada = null;
      _horasDisponibles = [];
      _rolAgendaSeleccionado = null;
      _agendaSeleccionadaId = null;
      _errorCrearHorario = null;
      _desde = const TimeOfDay(hour: 8, minute: 0);
      _hasta = const TimeOfDay(hour: 12, minute: 0);
    });
    _detectarRolesParaDia(dia);
  }

  void _detectarRolesParaDia(DateTime dia) {
    bool tieneDoctora = false;
    bool tieneAsistente = false;
    for (final agenda in _agendasCiudad) {
      if (!agenda.estado || !AgendaDiaUtils.aplicaParaDia(agenda, dia)) continue;
      if (agenda.rolCreador == 'Doctora') tieneDoctora = true;
      if (agenda.rolCreador == 'Asistente') tieneAsistente = true;
    }
    setState(() {
      _diaTieneAgendaDoctora = tieneDoctora;
      _diaTieneAgendaAsistente = tieneAsistente;
    });
    if (tieneDoctora && !tieneAsistente) {
      _seleccionarRolAgenda('Doctora');
    } else if (!tieneDoctora && tieneAsistente) {
      _seleccionarRolAgenda('Asistente');
    } else if (tieneDoctora && tieneAsistente) {
      _seleccionarRolAgenda(_rolAgendaSeleccionado ?? 'Doctora');
    }
  }

  void _seleccionarRolAgenda(String rol) {
    if (_fechaSeleccionada == null || _ciudadId == null) return;
    final agenda = AgendaDiaUtils.encontrarParaDiaYRol(_agendasCiudad, _fechaSeleccionada!, rol);
    setState(() {
      _rolAgendaSeleccionado = rol;
      _agendaSeleccionadaId = agenda?.id;
      _cargandoHoras = true;
    });
    _validarServicioParaAgenda(agenda);
    context.read<CitaBloc>().add(
      CargarDisponibilidadEvent(ciudadId: _ciudadId!, fecha: _fmtDia(_fechaSeleccionada!)),
    );
  }

  void _validarServicioParaAgenda(Agenda? agenda) {
    if (_servicioSeleccionado == null || agenda?.servicios == null || agenda!.servicios!.isEmpty) {
      setState(() => _advertenciaServicio = null);
      return;
    }
    final valido = agenda.servicios!.any((s) => s.id == _servicioSeleccionado!.id);
    setState(() {
      _advertenciaServicio = valido ? null : 'No disponible en la agenda de ${agenda.rolCreador}';
    });
  }

  void _onServicioCambiado(Servicio? servicio) {
    setState(() => _servicioSeleccionado = servicio);
    if (_rolAgendaSeleccionado != null && _fechaSeleccionada != null) {
      _validarServicioParaAgenda(
        AgendaDiaUtils.encontrarParaDiaYRol(_agendasCiudad, _fechaSeleccionada!, _rolAgendaSeleccionado!),
      );
    }
  }

  // ---------------------------------------------------------------------
  // Abrir horario inline
  // ---------------------------------------------------------------------

  String _fmtHora(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _crearHorarioInline() {
    if (_ciudadId == null || _fechaSeleccionada == null) return;
    setState(() {
      _creandoHorario = true;
      _errorCrearHorario = null;
    });
    context.read<AgendaBloc>().add(
      CrearAgendaEvent({
        'fecha': _fmtDia(_fechaSeleccionada!),
        'horaInicio': _fmtHora(_desde),
        'horaFin': _fmtHora(_hasta),
        'intervalo': _intervaloNuevo,
        'ciudadId': _ciudadId,
      }),
    );
  }

  void _abrirCrearAgendaCompleta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AgendaBloc>(),
          child: CrearAgendaPage(usuario: widget.usuario, fechaInicial: _fechaSeleccionada),
        ),
      ),
    ).then((_) {
      if (_ciudadId != null) context.read<AgendaBloc>().add(CargarAgendasEvent(ciudadId: _ciudadId));
    });
  }

  // ---------------------------------------------------------------------
  // Reservar
  // ---------------------------------------------------------------------

  bool get _puedeReservar =>
      (widget.config.esPaciente || _pacienteCtrl.pacienteSeleccionado != null) &&
      _servicioSeleccionado != null &&
      _fechaSeleccionada != null &&
      _horaSeleccionada != null;

  String get _razonNoPuedeReservar {
    if (!widget.config.esPaciente && _pacienteCtrl.pacienteSeleccionado == null) return 'Falta elegir paciente';
    if (_servicioSeleccionado == null) return 'Falta elegir servicio';
    if (_fechaSeleccionada == null) return 'Falta elegir fecha';
    if (_horaSeleccionada == null) return 'Falta elegir hora';
    return '';
  }

  Future<void> _onReservar() async {
    if (!_puedeReservar || _reservando) return;

    int? pacienteId;
    if (!widget.config.esPaciente) {
      pacienteId = await _obtenerPacienteId();
      if (pacienteId == null) return;
    }
    if (!mounted) return;

    setState(() => _reservando = true);
    context.read<CitaBloc>().add(
      ReservarCitaEvent(
        fecha: _fmtDia(_fechaSeleccionada!),
        hora: _horaSeleccionada!,
        servicioId: _servicioSeleccionado!.id,
        pacienteId: pacienteId,
        ciudadId: _ciudadId,
        agendaId: _agendaSeleccionadaId,
        notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
        esPaciente: widget.config.esPaciente,
        adelantoMonto: (widget.config.muestraAdelantoInline && _tieneAdelanto) ? _adelantoMonto : null,
        adelantoMetodo: (widget.config.muestraAdelantoInline && _tieneAdelanto) ? _adelantoMetodo : null,
      ),
    );
  }

  Future<int?> _obtenerPacienteId() async {
    if (!_pacienteCtrl.usarPacienteNuevo) {
      final id = _intValue(_pacienteCtrl.pacienteSeleccionado?['id']);
      if (id == null) _mostrarMensaje('Selecciona un paciente');
      return id;
    }
    if (_ciudadId == null) {
      _mostrarMensaje('Falta la ciudad del paciente');
      return null;
    }
    final nombre = _nombreNuevoController.text.trim();
    final telefono = _telefonoNuevoController.text.trim();
    if (nombre.isEmpty || telefono.isEmpty) {
      _mostrarMensaje('Ingresa nombre y teléfono del paciente nuevo');
      return null;
    }
    final id = await _pacienteCtrl.crearProvisional(nombre: nombre, telefono: telefono, ciudadId: _ciudadId!);
    if (id == null) _mostrarMensaje('No se pudo crear el paciente provisional');
    return id;
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: AppColors.warning),
    );
  }

  // ---------------------------------------------------------------------
  // Bloc listeners
  // ---------------------------------------------------------------------

  void _onCitaState(BuildContext context, CitaState state) {
    if (state is ServiciosCargados) {
      setState(() {
        _servicios = state.servicios;
        _cargandoServicios = false;
      });
    } else if (state is DisponibilidadMesCargada) {
      final key = '${state.anio}-${state.mes}';
      _cacheMeses[key] = state.dias;
      if (_mesKey(_mesVisible) == key) {
        setState(() {
          _disponibilidadMesActual = {for (final d in state.dias) _fmtDia(d.fecha): d};
          _cargandoMes = false;
        });
      }
    } else if (state is DisponibilidadCargada) {
      setState(() {
        _horasDisponibles = state.horasDisponibles;
        _cargandoHoras = false;
      });
    } else if (state is CitaReservada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita reservada correctamente'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else if (state is CitaReservadaConPago) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<CitaBloc>(),
            child: PagoAdelantoPage(citaId: state.citaId),
          ),
        ),
      );
    } else if (state is CitaError) {
      setState(() {
        _cargandoServicios = false;
        _cargandoHoras = false;
        _cargandoMes = false;
        _reservando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.mensaje), backgroundColor: AppColors.danger),
      );
    }
  }

  void _onAgendaState(BuildContext context, AgendaState state) {
    if (state is CiudadesAgendaCargadas) {
      setState(() => _ciudadesDisponibles = state.ciudades);
    } else if (state is AgendasCargadas) {
      setState(() => _agendasCiudad = state.agendas);
      if (_fechaSeleccionada != null) _detectarRolesParaDia(_fechaSeleccionada!);
    } else if (state is AgendaOperacionExitosa) {
      setState(() => _creandoHorario = false);
      if (_ciudadId != null) context.read<AgendaBloc>().add(CargarAgendasEvent(ciudadId: _ciudadId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Horario abierto'),
          action: SnackBarAction(label: 'Repetir cada semana', onPressed: _abrirCrearAgendaCompleta),
        ),
      );
    } else if (state is AgendaError) {
      setState(() {
        _creandoHorario = false;
        _errorCrearHorario = state.mensaje;
      });
    }
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: _buildAppBar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CitaBloc, CitaState>(listener: _onCitaState),
          BlocListener<AgendaBloc, AgendaState>(listener: _onAgendaState),
        ],
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.config.puedeElegirCiudad) ...[
                  _buildCiudadPicker(),
                  const SizedBox(height: 12),
                ],
                TarjetaPaciente(
                  controller: _pacienteCtrl,
                  puedeCrearPacienteNuevo: widget.config.puedeCrearPacienteNuevo,
                  buscadorController: _buscadorController,
                  servicioSeleccionado: _servicioSeleccionado,
                  servicios: _servicios,
                  cargandoServicios: _cargandoServicios,
                  advertenciaServicio: _advertenciaServicio,
                  onServicioCambiado: _onServicioCambiado,
                  onEditar: _pacienteCtrl.limpiarSeleccion,
                  nombreNuevoController: _nombreNuevoController,
                  telefonoNuevoController: _telefonoNuevoController,
                  mostrarEditar: !widget.config.esPaciente,
                ),
                const SizedBox(height: 16),
                if (_ciudadId == null)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.teal)))
                else ...[
                  CalendarioMes(
                    mesVisible: _mesVisible,
                    fechaSeleccionada: _fechaSeleccionada,
                    disponibilidad: _disponibilidadMesActual,
                    cargando: _cargandoMes,
                    onDiaSeleccionado: _seleccionarFecha,
                    onMesCambiado: _onMesCambiado,
                  ),
                  const SizedBox(height: 16),
                  if (_fechaSeleccionada != null) ...[
                    _buildSeccionHorario(),
                    const SizedBox(height: 16),
                  ],
                ],
                if (widget.config.muestraAdelantoInline) ...[
                  _buildAdelanto(),
                  const SizedBox(height: 16),
                ],
                const Text('Notas (opcional)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.teal, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _notasController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Escribe alguna nota...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: PieReserva(
        resumenFecha: _resumenFechaTexto,
        montoTexto: _montoTexto,
        habilitado: _puedeReservar,
        reservando: _reservando,
        razonDeshabilitado: _razonNoPuedeReservar,
        onReservar: _onReservar,
      ),
    );
  }

  String get _resumenFechaTexto {
    if (_fechaSeleccionada == null) return 'Elige fecha y hora';
    final fecha = DateFormat("d MMM", 'es_ES').format(_fechaSeleccionada!);
    final hora = _horaSeleccionada ?? '--:--';
    final servicio = _servicioSeleccionado?.nombreServicio ?? '';
    return servicio.isEmpty ? '$fecha · $hora' : '$fecha · $hora · $servicio';
  }

  String? get _montoTexto {
    if (!widget.config.muestraAdelantoInline || !_tieneAdelanto) return null;
    return 'Adelanto Bs ${_adelantoMonto.toStringAsFixed(0)}';
  }

  PreferredSizeWidget _buildAppBar() {
    final pacienteTxt = widget.config.esPaciente
        ? widget.usuario.nombreCompleto
        : (_pacienteCtrl.pacienteSeleccionado != null
              ? PacienteBusquedaController.nombrePaciente(_pacienteCtrl.pacienteSeleccionado)
              : 'Sin paciente');
    final subtitulo = '${_ciudadNombre ?? '...'} · $pacienteTxt';

    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        toolbarHeight: 64,
        backgroundColor: AppColors.teal,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nueva cita', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(
              subtitulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xBFFFFFFF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCiudadPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderChip),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: const Text('Elegir ciudad'),
          value: _ciudadId,
          items: _ciudadesDisponibles
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombreCiudad)))
              .toList(),
          onChanged: (id) {
            if (id == null) return;
            final ciudad = _ciudadesDisponibles.firstWhere((c) => c.id == id);
            _onCiudadElegida(ciudad);
          },
        ),
      ),
    );
  }

  Widget _buildSeccionHorario() {
    final tieneAlgunaAgenda = _diaTieneAgendaDoctora || _diaTieneAgendaAsistente;

    if (!tieneAlgunaAgenda) {
      if (!widget.config.muestraTarjetaAbrirHorario) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [
              Icon(Icons.event_busy_outlined, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(child: Text('No hay horario disponible este día', style: TextStyle(color: Colors.grey))),
            ],
          ),
        );
      }
      return TarjetaAbrirHorario(
        dia: _fechaSeleccionada!,
        desde: _desde,
        hasta: _hasta,
        intervalo: _intervaloNuevo,
        rolSeleccionado: _rolNuevaAgenda,
        creando: _creandoHorario,
        error: _errorCrearHorario,
        onDesdeCambiado: (t) => setState(() => _desde = t),
        onHastaCambiado: (t) => setState(() => _hasta = t),
        onIntervaloCambiado: (i) => setState(() => _intervaloNuevo = i),
        onRolCambiado: (r) => setState(() => _rolNuevaAgenda = r),
        onCrear: _crearHorarioInline,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_diaTieneAgendaDoctora && _diaTieneAgendaAsistente) ...[
          Row(
            children: [
              Expanded(child: _chipRolFiltro('Doctora')),
              const SizedBox(width: 8),
              Expanded(child: _chipRolFiltro('Asistente')),
            ],
          ),
          const SizedBox(height: 12),
        ],
        HorasDisponibles(
          titulo: "Horas del ${DateFormat('d MMM', 'es_ES').format(_fechaSeleccionada!)} · agenda ${_rolAgendaSeleccionado ?? ''}",
          horas: _horasDisponibles,
          horasOcupadas: const {},
          horaSeleccionada: _horaSeleccionada,
          cargando: _cargandoHoras,
          onSeleccionar: (h) => setState(() => _horaSeleccionada = h),
        ),
      ],
    );
  }

  Widget _chipRolFiltro(String rol) {
    final activo = _rolAgendaSeleccionado == rol;
    return GestureDetector(
      onTap: () => _seleccionarRolAgenda(rol),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: activo ? const Color(0x1A00B5C8) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: activo ? AppColors.teal : AppColors.borderChip),
        ),
        child: Text(
          rol,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: activo ? AppColors.tealDark : const Color(0xFF4A4F54)),
        ),
      ),
    );
  }

  Widget _buildAdelanto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _tieneAdelanto,
              activeColor: AppColors.teal,
              onChanged: (v) => setState(() => _tieneAdelanto = v ?? false),
            ),
            const Text('Registrar adelanto (Bs 50)'),
          ],
        ),
        if (_tieneAdelanto)
          Row(
            children: [
              _metodoChip('efectivo', 'Efectivo'),
              const SizedBox(width: 8),
              _metodoChip('qr', 'QR'),
            ],
          ),
      ],
    );
  }

  Widget _metodoChip(String valor, String etiqueta) {
    final sel = _adelantoMetodo == valor;
    return GestureDetector(
      onTap: () => setState(() => _adelantoMetodo = valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? AppColors.teal : AppColors.borderChip),
        ),
        child: Text(etiqueta, style: TextStyle(color: sel ? Colors.white : AppColors.ink, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}

class _CiudadNoAsignadaPage extends StatelessWidget {
  const _CiudadNoAsignadaPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Nueva cita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.teal,
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
