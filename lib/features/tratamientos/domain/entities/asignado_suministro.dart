import 'package:equatable/equatable.dart';
import 'package:ciemsi_app/features/suministros/domain/entities/suministro.dart';

class AsignadoSuministro extends Equatable {
  final int id;
  final int tratamientoAsignadoId;
  final Suministro suministro;
  final double cantidad;
  final String agregadoPor;

  const AsignadoSuministro({
    required this.id,
    required this.tratamientoAsignadoId,
    required this.suministro,
    required this.cantidad,
    required this.agregadoPor,
  });

  @override
  List<Object?> get props => [id, suministro, cantidad, agregadoPor];
}
