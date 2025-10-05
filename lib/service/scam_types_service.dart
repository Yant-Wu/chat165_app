import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/scam_type.dart';

class ScamTypesException implements Exception {
  final String message;
  final int? statusCode;

  const ScamTypesException(this.message, {this.statusCode});

  @override
  String toString() => 'ScamTypesException($message, statusCode: $statusCode)';
}

class ScamTypesService {
  ScamTypesService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'https://chat165.niu.edu.tw';

  final http.Client _client;
  final String _baseUrl;

  Future<ScamTypesResponse> fetchScamTypes() async {
    final uri = Uri.parse('$_baseUrl/api/scam-types');

    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const ScamTypesException('連線逾時，請稍後再試');
    } on http.ClientException catch (e) {
      throw ScamTypesException('Network error: ${e.message}');
    } on FormatException {
      throw const ScamTypesException('Invalid API endpoint URL');
    }

    if (response.statusCode != 200) {
      throw ScamTypesException(
        '伺服器回應錯誤 (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    try {
      final Map<String, dynamic> jsonBody =
          jsonDecode(response.body) as Map<String, dynamic>;
      return ScamTypesResponse.fromJson(jsonBody);
    } on FormatException catch (e) {
      throw ScamTypesException('資料格式錯誤：${e.message}');
    }
  }

  void dispose() => _client.close();
}
