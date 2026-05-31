import 'package:ciemsi_app/core/network/api_client.dart';
import '../models/servicio_model.dart';

class ServicioRemoteDatasource {
  final ApiClient _client;
  ServicioRemoteDatasource(this._client);

  Future<List<ServicioModel>> listar() async {
    final response = await _client.dio.get('/servicios');
    return (response.data as List)
        .map((j) => ServicioModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    await _client.dio.post('/servicios', data: datos);
  }

  Future<void> modificar(int id, Map<String, dynamic> datos) async {
    await _client.dio.put('/servicios/$id', data: datos);
  }
}
