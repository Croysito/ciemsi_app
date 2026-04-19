import '../../domain/entities/link_archivo.dart';

class LinkModel extends LinkArchivo {
  const LinkModel({
    required super.id,
    required super.nombre,
    required super.link,
    required super.tipo,
    required super.notaId,
  });

  factory LinkModel.fromJson(Map<String, dynamic> json) {
    return LinkModel(
      id: json['id'],
      nombre: json['nombre'],
      link: json['link'],
      tipo: TipoLink.values.firstWhere((e) => e.name == json['tipo']),
      notaId: json['notaId'] ?? json['nota_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'link': link,
    'tipo': tipo.name,
    'notaId': notaId,
  };
}
