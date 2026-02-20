import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClientService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Ganti dengan URL API Anda
  final _storage = const FlutterSecureStorage();

  Future<List<dynamic>> getClients() async {
    final token = await _storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$baseUrl/clients'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Sesuaikan dengan struktur response API Anda
      // Kemungkinan: data['data'] atau langsung data
      if (data is List) return data;
      if (data['data'] != null) return data['data'];
      return [];
    } else {
      throw Exception('Failed to load clients: ${response.statusCode}');
    }
  }
}