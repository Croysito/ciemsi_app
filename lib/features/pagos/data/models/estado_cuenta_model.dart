import '../../domain/entities/estado_cuenta.dart';
import 'ingreso_model.dart';
import 'deuda_model.dart';

class EstadoCuentaModel extends EstadoCuenta {
  const EstadoCuentaModel({
    required super.deudas,
    required super.ingresos,
    required super.totalDeuda,
    required super.totalCobrado,
    required super.totalPendiente,
  });

  factory EstadoCuentaModel.fromJson(Map<String, dynamic> json) {
    final resumen = json['resumen'] as Map<String, dynamic>;
    return EstadoCuentaModel(
      deudas: (json['deudas'] as List? ?? [])
          .map((d) => DeudaModel.fromJson(d as Map<String, dynamic>))
          .toList(),
      ingresos: (json['ingresos'] as List? ?? [])
          .map((i) => IngresoModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      totalDeuda: (resumen['totalDeuda'] as num).toDouble(),
      totalCobrado: (resumen['totalCobrado'] as num).toDouble(),
      totalPendiente: (resumen['totalPendiente'] as num).toDouble(),
    );
  }
}
