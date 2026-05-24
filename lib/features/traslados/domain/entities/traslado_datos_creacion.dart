import 'package:equatable/equatable.dart';

import 'traslado_ciudad_option.dart';
import 'traslado_item_option.dart';

class TrasladoDatosCreacion extends Equatable {
  final List<TrasladoItemOption> suministros;
  final List<TrasladoItemOption> productos;
  final List<TrasladoCiudadOption> ciudades;

  const TrasladoDatosCreacion({
    required this.suministros,
    required this.productos,
    required this.ciudades,
  });

  @override
  List<Object?> get props => [suministros, productos, ciudades];
}
