class MedicamentoBase {
  final int suministroId;
  final String nombreSuministro;
  final int cantidad;
  final double precioVentaBase;

  const MedicamentoBase({
    required this.suministroId,
    required this.nombreSuministro,
    required this.cantidad,
    required this.precioVentaBase,
  });

  factory MedicamentoBase.fromJson(Map<String, dynamic> json) {
    return MedicamentoBase(
      suministroId: json['suministroId'],
      nombreSuministro: json['nombreSuministro'],
      cantidad: json['cantidad'],
      precioVentaBase:
          double.tryParse(json['precioVentaBase'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'suministroId': suministroId,
    'cantidad': cantidad,
  };
}
