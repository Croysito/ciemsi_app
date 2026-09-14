import 'package:equatable/equatable.dart';

import 'ciudad_inventario.dart';

/// Saldo de un suministro en una ciudad concreta.
class SaldoCiudad extends Equatable {
  final int ciudadId;
  final double saldo;

  const SaldoCiudad({required this.ciudadId, required this.saldo});

  @override
  List<Object?> get props => [ciudadId, saldo];
}

/// Una fila de la matriz: un suministro con su saldo en cada ciudad
/// visible. Una ciudad sin fila propia para este suministro (nunca compró
/// ahí) se trata igual que saldo 0 — ver [saldoEn].
class ItemComparado extends Equatable {
  final int id;
  final String nombreSuministro;
  final String unidadMedida;
  final String tipo;
  final int umbral;
  final List<SaldoCiudad> saldos;

  const ItemComparado({
    required this.id,
    required this.nombreSuministro,
    required this.unidadMedida,
    required this.tipo,
    required this.umbral,
    required this.saldos,
  });

  double saldoEn(int ciudadId) =>
      saldos.firstWhere((s) => s.ciudadId == ciudadId, orElse: () => SaldoCiudad(ciudadId: ciudadId, saldo: 0)).saldo;

  @override
  List<Object?> get props => [id, nombreSuministro, umbral, saldos];
}

/// Resultado completo del modo Comparar: las columnas de ciudad (con su
/// estilo) y la matriz de items.
class InventarioComparado extends Equatable {
  final List<CiudadInventario> ciudades;
  final List<ItemComparado> items;

  const InventarioComparado({required this.ciudades, required this.items});

  @override
  List<Object?> get props => [ciudades, items];
}
