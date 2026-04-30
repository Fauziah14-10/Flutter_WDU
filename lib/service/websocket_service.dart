import 'package:flutter/foundation.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../core/constants/websocket_constants.dart';
import '../core/constants/endpoints.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  Echo? _echo;
  PusherChannelsFlutter? _pusherClient;

  Future<void> initEcho(String token) async {
    if (kIsWeb) {
      debugPrint('[WebSocket] Skipping init on Web (Not supported)');
      return;
    }

    if (_echo != null) await disconnect();

    try {
      _pusherClient = PusherChannelsFlutter.getInstance();

      await _pusherClient!.init(
        apiKey: WebSocketConstants.key,
        cluster: 'mt1',
        authEndpoint: '${Endpoints.baseUrl}/broadcasting/auth',
        authParams: {
          'headers': {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        },
        onConnectionStateChange: (currentState, previousState) {
          debugPrint('[WebSocket] State: $previousState -> $currentState');
        },
        onError: (message, code, error) {
          debugPrint('[WebSocket] Error: $message');
        },
      );

      _echo = Echo(
        client: _pusherClient,
        broadcaster: EchoBroadcasterType.Pusher,
      );

      await _pusherClient!.connect();
    } catch (e) {
      debugPrint('[WebSocket] Init Error: $e');
    }
  }

  Echo? get echo => _echo;

  Future<void> disconnect() async {
    await _pusherClient?.disconnect();
    _echo = null;
    _pusherClient = null;
    debugPrint('[WebSocket] Disconnected');
  }
}