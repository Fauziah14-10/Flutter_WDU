import '../core/api/api_client.dart';
import '../core/constants/endpoints.dart';
import '../models/client_model.dart';
import '../models/user_project_model.dart';

class ClientService {
  final _api = ApiClient();

  // client_service.dart
Future<Map<String, dynamic>> getDashboardData() async {
  final response = await _api.get(Endpoints.clients);

  print('── GET DASHBOARD ────────────────────');
  print('response.data: ${response.data}');
  print('────────────────────────────────────');

  if (response.data == null) {
    throw Exception('Response data is null');
  }

  return response.data!;
}

  Future<List<Client>> getClients() async {
    final response = await _api.get(Endpoints.clients);
    final List<dynamic> raw = response.data!['clients'] as List<dynamic>;
    return raw.map((e) => Client.fromJson(e)).toList();
  }

  Future<List<UserProject>> getUserProjects() async {
    final response = await _api.get(Endpoints.clients);
    final List<dynamic> raw = response.data!['userProjects'] as List<dynamic>;
    return raw.map((e) => UserProject.fromJson(e)).toList();
  }
}