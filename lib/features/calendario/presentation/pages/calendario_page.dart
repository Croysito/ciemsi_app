import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:ciemsi_app/core/theme/app_colors.dart';
import 'package:ciemsi_app/features/agenda/domain/entities/agenda.dart';
import 'package:ciemsi_app/features/agenda/domain/utils/agenda_dia_utils.dart';
import 'package:ciemsi_app/features/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:ciemsi_app/features/agenda/presentation/bloc/agenda_event.dart';
import 'package:ciemsi_app/features/agenda/presentation/bloc/agenda_state.dart';
import 'package:ciemsi_app/features/agenda/presentation/pages/crear_agenda.dart';
import 'package:ciemsi_app/features/auth/domain/entities/usuario.dart';
import 'package:ciemsi_app/features/citas/domain/entities/cita_medica.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_bloc.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_event.dart';
import 'package:ciemsi_app/features/citas/presentation/bloc/cita_state.dart';
import 'package:ciemsi_app/features/citas/presentation/pages/detalle_cita_page.dart';
import 'package:ciemsi_app/features/citas/presentation/pages/reservar_cita_page.dart';
import '../controllers/ciudad_color_controller.dart';
import '../widgets/calendario_compacto.dart';
import '../widgets/ciudad_chips_row.dart';
import '../widgets/detalle_dia.dart';
import '../widgets/modo_switch.dart';

/// P3 · Calendario unificado — citas y horarios en una sola vista, con un
/// único punto de creación. Reemplaza `citas_page.dart` (tab inferior) y
/// `agenda_page.dart` (menú lateral).
class CalendarioPage extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback? onMenuTap;
  final VoidCallback? onAsistenteIA;
  final ModoCalendario modoInicial;

  const CalendarioPage({
    super.key,
    required this.usuario,
    this.onMenuTap,
    this.onAsistenteIA,
    this.modoInicial = ModoCalendario.citas,
  });

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  static DateTime get _hoy {
    final ahora = DateTime.now();
    return DateTime(ahora.year, ahora.month, ahora.day);
  }

  late ModoCalendario _modo;
  DateTime _focusDay = _hoy;
  DateTime _diaSeleccionado = _hoy;
  bool _calendarioExpandido = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _detalleKey = GlobalKey();
  final CiudadColorController _colores = CiudadColorController();

  List<CitaMedica> _citas = [];
  bool _cargandoCitas = true;
  String? _errorCitas;

  List<Agenda> _agendas = [];
  bool _cargandoAgendas = true;
  String? _errorAgendas;

  bool get _puedeGestionarHorarios => widget.usuario.rol == 'Doctora' || widget.usuario.rol == 'Asistente';

  @override
  void initState() {
    super.initState();
    _modo = _puedeGestionarHorarios ? widget.modoInicial : ModoCalendario.citas;
    context.read<CitaBloc>().add(ListarCitasEvent());
    context.read<AgendaBloc>().add(CargarAgendasEvent());
    _colores.addListener(_onColoresCambiados);
    _colores.cargar();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _colores.removeListener(_onColoresCambiados);
    _colores.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onColoresCambiados() {
    if (mounted) setState(() {});
  }

  /// P3 addendum · "Colapsa solo al desplazar la lista del día hacia
  /// arriba, y vuelve a expandirse al llegar de nuevo al tope."
  void _onScroll() {
    final offset = _scrollController.offset;
    if (offset > 8 && _calendarioExpandido) {
      setState(() => _calendarioExpandido = false);
    } else if (offset <= 0 && !_calendarioExpandido) {
      setState(() => _calendarioExpandido = true);
    }
  }

  // ---------------------------------------------------------------------
  // Ciudades — color fijo, filtro reducido a ocultar/mostrar (addendum §1)
  // ---------------------------------------------------------------------

  List<String> get _todasLasCiudades =>
      {..._citas.map((c) => c.ciudad.nombreCiudad), ..._agendas.map((a) => a.ciudad.nombreCiudad)}.toList()..sort();

  bool _pasaFiltroCita(CitaMedica c) => !_colores.estaOculta(c.ciudad.nombreCiudad);

  bool _pasaFiltroAgenda(Agenda a) => !_colores.estaOculta(a.ciudad.nombreCiudad);

  List<CitaMedica> get _citasFiltradas => _citas.where(_pasaFiltroCita).toList();
  List<Agenda> get _agendasFiltradas => _agendas.where((a) => a.estado && _pasaFiltroAgenda(a)).toList();

  List<CitaMedica> _citasDelDia(DateTime dia) =>
      _citasFiltradas.where((c) => isSameDay(c.fecha, dia)).toList();

  List<Agenda> _franjasDelDia(DateTime dia) =>
      _agendasFiltradas.where((a) => AgendaDiaUtils.aplicaParaDia(a, dia)).toList();

  /// Marcas del calendario compacto: hasta 3 puntos de ciudad con cita en
  /// modo Citas, o un segmento por ciudad con franja abierta en modo
  /// Horarios — una por ciudad, sin repetir.
  List<CiudadEstilo> _marcasEnDia(DateTime dia) {
    final vistas = <String>{};
    final resultado = <CiudadEstilo>[];
    if (_modo == ModoCalendario.horarios) {
      for (final f in _franjasDelDia(dia)) {
        if (vistas.add(f.ciudad.nombreCiudad)) resultado.add(_colores.estiloPara(f.ciudad.nombreCiudad));
      }
    } else {
      for (final c in _citasDelDia(dia)) {
        if (vistas.add(c.ciudad.nombreCiudad)) {
          resultado.add(_colores.estiloPara(c.ciudad.nombreCiudad));
          if (resultado.length == 3) break;
        }
      }
    }
    return resultado;
  }

  String get _subtituloAppBar {
    final ocultas = _colores.ciudadesOcultas;
    final visibles = _todasLasCiudades.where((c) => !ocultas.contains(c.trim().toLowerCase())).toList();
    if (visibles.isEmpty) return 'Todas las ciudades ocultas';
    if (visibles.length == _todasLasCiudades.length) return 'Todas las ciudades';
    return visibles.join(', ');
  }

  // ---------------------------------------------------------------------
  // Interacciones
  // ---------------------------------------------------------------------

  void _seleccionarDia(DateTime dia) {
    setState(() => _diaSeleccionado = DateTime(dia.year, dia.month, dia.day));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _detalleKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 250), alignment: 0);
      }
    });
  }

  void _focusDayCambiado(DateTime dia) => setState(() => _focusDay = dia);

  void _alternarExpandido() => setState(() => _calendarioExpandido = !_calendarioExpandido);

  void _cambiarModo(ModoCalendario modo) => setState(() => _modo = modo);

  Future<void> _abrirDetalleCita(CitaMedica cita) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CitaBloc>(),
          child: DetalleCitaPage(cita: cita, usuario: widget.usuario),
        ),
      ),
    );
    // Actualiza sólo esa tarjeta (GET /citas/:id) en vez de recargar todo
    // el mes, a diferencia de la pantalla anterior.
    if (resultado == true && mounted) {
      context.read<CitaBloc>().add(ObtenerCitaEvent(cita.id));
    }
  }

  Future<void> _nuevaCita() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CitaBloc>(),
          child: ReservarCitaPage(usuario: widget.usuario, fechaInicial: _diaSeleccionado),
        ),
      ),
    );
    if (mounted) context.read<CitaBloc>().add(ListarCitasEvent());
  }

  Future<void> _abrirHorario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AgendaBloc>(),
          child: CrearAgendaPage(usuario: widget.usuario, fechaInicial: _diaSeleccionado),
        ),
      ),
    );
    if (mounted) context.read<AgendaBloc>().add(CargarAgendasEvent());
  }

  void _tocarFranja(Agenda agenda) {
    if (!_puedeGestionarHorarios) return;
    _mostrarOpcionesAgenda(agenda);
  }

  void _mostrarOpcionesAgenda(Agenda agenda) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_hora(agenda.horaInicio)} — ${_hora(agenda.horaFin)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text('${agenda.rolCreador ?? 'Sin rol'} · ${agenda.ciudad.nombreCiudad}', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 28),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(agenda.estado ? Icons.pause_circle_outline : Icons.play_circle_outline, color: AppColors.teal),
              title: Text(agenda.estado ? 'Desactivar agenda' : 'Activar agenda'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<AgendaBloc>().add(CambiarEstadoAgendaEvent(agenda.id, !agenda.estado));
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text('Eliminar agenda', style: TextStyle(color: AppColors.danger)),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmarEliminarAgenda(agenda.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminarAgenda(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar agenda'),
        content: const Text('¿Estás segura de eliminar esta configuración?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AgendaBloc>().add(EliminarAgendaEvent(id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _hora(String h) => h.length >= 5 ? h.substring(0, 5) : h;

  // ---------------------------------------------------------------------
  // Bloc listeners
  // ---------------------------------------------------------------------

  void _onCitaState(BuildContext context, CitaState state) {
    if (state is CitasListadas) {
      setState(() {
        _citas = state.citas;
        _cargandoCitas = false;
        _errorCitas = null;
      });
    } else if (state is CitaObtenida) {
      setState(() {
        final idx = _citas.indexWhere((c) => c.id == state.cita.id);
        if (idx >= 0) {
          _citas = List.of(_citas)..[idx] = state.cita;
        } else {
          _citas = [..._citas, state.cita];
        }
      });
    } else if (state is CitaError && _cargandoCitas) {
      setState(() {
        _cargandoCitas = false;
        _errorCitas = state.mensaje;
      });
    }
  }

  void _onAgendaState(BuildContext context, AgendaState state) {
    if (state is AgendasCargadas) {
      setState(() {
        _agendas = state.agendas;
        _cargandoAgendas = false;
        _errorAgendas = null;
      });
    } else if (state is AgendaOperacionExitosa) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horario actualizado'), backgroundColor: Colors.green),
      );
      context.read<AgendaBloc>().add(CargarAgendasEvent());
    } else if (state is AgendaError && _cargandoAgendas) {
      setState(() {
        _cargandoAgendas = false;
        _errorAgendas = state.mensaje;
      });
    }
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CitaBloc, CitaState>(listener: _onCitaState),
        BlocListener<AgendaBloc, AgendaState>(listener: _onAgendaState),
      ],
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 88),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_puedeGestionarHorarios)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ModoSwitch(modo: _modo, onCambiar: _cambiarModo),
                ),
              CiudadChipsRow(
                ciudades: _todasLasCiudades,
                colores: _colores,
                onToggle: (c) => setState(() => _colores.alternarVisibilidad(c)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: CalendarioCompacto(
                  modo: _modo,
                  expandido: _calendarioExpandido,
                  focusDay: _focusDay,
                  diaSeleccionado: _diaSeleccionado,
                  marcasEnDia: _marcasEnDia,
                  onDiaSeleccionado: _seleccionarDia,
                  onFocusDayCambiado: _focusDayCambiado,
                  onAlternarExpandido: _alternarExpandido,
                ),
              ),
              Padding(
                key: _detalleKey,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: DetalleDia(
                  dia: _diaSeleccionado,
                  modo: _modo,
                  franjas: _franjasDelDia(_diaSeleccionado),
                  citas: _citasDelDia(_diaSeleccionado),
                  colores: _colores,
                  cargando: _cargandoCitas || _cargandoAgendas,
                  error: _errorCitas ?? _errorAgendas,
                  onReintentar: () {
                    context.read<CitaBloc>().add(ListarCitasEvent());
                    context.read<AgendaBloc>().add(CargarAgendasEvent());
                  },
                  onTapCita: _abrirDetalleCita,
                  onTapFranja: _tocarFranja,
                  onAbrirHorario: _abrirHorario,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFabs(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        toolbarHeight: 64,
        backgroundColor: AppColors.teal,
        elevation: 0,
        leading: widget.onMenuTap != null
            ? IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: widget.onMenuTap)
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Calendario', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(
              _subtituloAppBar,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xBFFFFFFF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.onAsistenteIA != null) ...[
          FloatingActionButton.small(
            heroTag: 'fab_asistente',
            backgroundColor: AppColors.teal,
            onPressed: widget.onAsistenteIA,
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
          ),
          const SizedBox(height: 10),
        ],
        if (_puedeGestionarHorarios) ...[
          _FabSecundario(onTap: _abrirHorario),
          const SizedBox(height: 10),
        ],
        FloatingActionButton.extended(
          heroTag: 'fab_nueva_cita',
          backgroundColor: AppColors.green,
          onPressed: _nuevaCita,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Nueva cita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

class _FabSecundario extends StatelessWidget {
  final VoidCallback onTap;
  const _FabSecundario({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_available, size: 18, color: AppColors.teal),
              SizedBox(width: 6),
              Text('Abrir horario', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
            ],
          ),
        ),
      ),
    );
  }
}
