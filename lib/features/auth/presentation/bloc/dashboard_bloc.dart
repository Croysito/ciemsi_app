import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ciemsi_app/core/network/api_client_provider.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<CargarDashboardEvent>(_onCargar);
  }

  Future<void> _onCargar(
    CargarDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final dio = ApiClientProvider.instance.dio;
      final hoy = DateTime.now();

      final futures = <Future>[
        dio.get('/citas'),
        dio.get('/pacientes'),
        if (event.ciudadId != null)
          dio.get(
            '/suministros/alertas',
            queryParameters: {'ciudadId': event.ciudadId},
          ),
      ];
      final results = await Future.wait(futures);

      final citasHoy =
          (results[0].data as List)
              .cast<Map<String, dynamic>>()
              .where((c) {
                final f = DateTime.tryParse(c['fecha']?.toString() ?? '');
                return f != null &&
                    f.year == hoy.year &&
                    f.month == hoy.month &&
                    f.day == hoy.day;
              })
              .toList()
            ..sort(
              (a, b) =>
                  (a['hora']?.toString() ?? '').compareTo(
                    b['hora']?.toString() ?? '',
                  ),
            );

      final cumpleaneros =
          (results[1].data as List).cast<Map<String, dynamic>>().where((p) {
            final fn = DateTime.tryParse(p['fechaNacimiento']?.toString() ?? '');
            return fn != null && fn.month == hoy.month && fn.day == hoy.day;
          }).toList();

      final alertasStock =
          results.length > 2
              ? ((results[2].data['stockBajo'] as List?) ?? [])
                  .cast<Map<String, dynamic>>()
              : <Map<String, dynamic>>[];

      emit(
        DashboardCargado(
          citasHoy: citasHoy,
          cumpleaneros: cumpleaneros,
          alertasStock: alertasStock,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
