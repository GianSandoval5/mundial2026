import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    required String baseUrl,
    required String projectId,
    required String apiKey,
    required String functionName,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl.trim(),
        _projectId = projectId.trim(),
        _apiKey = apiKey.trim(),
        _functionName = functionName.trim(),
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final String _projectId;
  final String _apiKey;
  final String _functionName;
  final http.Client _httpClient;

  bool get isConfigured =>
      _baseUrl.isNotEmpty &&
      _projectId.isNotEmpty &&
      _apiKey.isNotEmpty &&
      _functionName.isNotEmpty;

  Future<Map<String, dynamic>> invoke(Map<String, Object?> data) async {
    if (!isConfigured) {
      throw const ApiClientException('Flupibase function config is incomplete.');
    }

    final baseUri = Uri.parse(_baseUrl.replaceAll(RegExp(r'/+$'), ''));
    final encodedProjectId = Uri.encodeComponent(_projectId);
    final encodedFunctionName = Uri.encodeComponent(_functionName);
    final uri = baseUri.replace(
      path:
          '${baseUri.path}/projects/$encodedProjectId/functions/$encodedFunctionName/invoke',
    );

    final response = await _httpClient
        .post(
          uri,
          headers: <String, String>{
            'accept': 'application/json',
            'content-type': 'application/json',
            'x-api-key': _apiKey,
          },
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 14));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiClientException(
        'Request failed with status ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiClientException('Unexpected API response shape.');
    }

    return _unwrapInvocationResponse(decoded);
  }

  Map<String, dynamic> _unwrapInvocationResponse(Map<String, dynamic> decoded) {
    final success = decoded['success'];
    if (success == false) {
      throw ApiClientException(decoded['message']?.toString() ?? 'Function failed.');
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      return decoded;
    }

    if (data['status'] == 'error') {
      throw ApiClientException(
        data['error']?.toString() ?? decoded['message']?.toString() ?? 'Function failed.',
      );
    }

    final invocationResult = data['result'];
    if (invocationResult is Map<String, dynamic>) {
      if (invocationResult['ok'] == false) {
        final error = invocationResult['error'];
        if (error is Map<String, dynamic>) {
          throw ApiClientException(error['message']?.toString() ?? 'Function failed.');
        }
        throw ApiClientException(invocationResult['message']?.toString() ?? 'Function failed.');
      }

      final result = invocationResult['result'];
      if (result is Map<String, dynamic>) {
        return result;
      }
    }

    if (invocationResult is Map) {
      return Map<String, dynamic>.from(invocationResult);
    }

    return data;
  }
}

class ApiClientException implements Exception {
  const ApiClientException(this.message);

  final String message;

  @override
  String toString() => message;
}
