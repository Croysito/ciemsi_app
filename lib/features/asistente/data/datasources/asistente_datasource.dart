import 'dart:typed_data';
import 'package:ciemsi_app/core/network/api_client.dart';
import 'package:dio/dio.dart';

class AsistenteDatasource {
  final ApiClient _client;
  AsistenteDatasource(this._client);

  Future<Map<String, dynamic>> obtenerEstado() async {
    final res = await _client.dio.get('/chatbot/estado');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> chat({required String nuevoMensaje}) async {
    final res = await _client.dio.post(
      '/chatbot/chat',
      data: {'nuevoMensaje': nuevoMensaje},
      options: Options(receiveTimeout: const Duration(seconds: 40)),
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Uint8List> tts(String texto) async {
    final res = await _client.dio.post(
      '/chatbot/tts',
      data: {'texto': texto},
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    return Uint8List.fromList(res.data as List<int>);
  }

  Future<void> finalizar() async {
    await _client.dio.post(
      '/chatbot/finalizar',
      options: Options(receiveTimeout: const Duration(seconds: 40)),
    );
  }
}
