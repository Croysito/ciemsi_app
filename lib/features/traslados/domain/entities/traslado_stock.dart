import 'package:equatable/equatable.dart';

class TrasladoStock extends Equatable {
  final double disponible;

  const TrasladoStock({required this.disponible});

  @override
  List<Object?> get props => [disponible];
}
