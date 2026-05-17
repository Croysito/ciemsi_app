import 'package:equatable/equatable.dart';

class AlertasSuministro extends Equatable {
  final List<dynamic> stockBajo;
  final List<dynamic> proximosAVencer;

  const AlertasSuministro({
    required this.stockBajo,
    required this.proximosAVencer,
  });

  @override
  List<Object?> get props => [stockBajo, proximosAVencer];
}
