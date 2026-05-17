import 'package:equatable/equatable.dart';

import 'inventario_item.dart';

class InventarioResult extends Equatable {
  final List<InventarioItem> inventario;
  final List<InventarioItem> stockBajo;
  final int? totalItems;

  const InventarioResult({
    required this.inventario,
    required this.stockBajo,
    this.totalItems,
  });

  @override
  List<Object?> get props => [inventario, stockBajo, totalItems];
}
