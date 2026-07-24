import 'dart:convert';
import '../models/fincra_response.dart';

/// The channel name used for JS communication.
const String fincraJavascriptChannelName = 'FincraBridge';

/// Defines the types of messages coming from the Fincra JS SDK.
enum FincraBridgeEvent { ready, success, closed, error, unknown }

/// A parsed message from the Fincra JS SDK.
class FincraBridgeMessage {
  final FincraBridgeEvent event;
  final FincraPaymentResponse? data;

  FincraBridgeMessage({required this.event, this.data});

  /// Parses a raw JSON string message from the JavaScript channel.
  factory FincraBridgeMessage.fromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      final eventString = map['event'] as String?;
      final event = _parseEvent(eventString);

      FincraPaymentResponse? data;
      if (event == FincraBridgeEvent.success && map.containsKey('data')) {
        final dataMap = map['data'] as Map<String, dynamic>? ?? {};

        // Ensure status is success for the FincraPaymentResponse
        dataMap['status'] ??= 'success';

        // Convert to map of strings as FincraPaymentResponse expects it from url params
        // or we can just map it directly.
        final params = dataMap.map(
          (key, value) => MapEntry(key, value.toString()),
        );
        data = FincraPaymentResponse.fromUrlParams(params);
      }

      return FincraBridgeMessage(event: event, data: data);
    } catch (e) {
      return FincraBridgeMessage(event: FincraBridgeEvent.unknown);
    }
  }

  static FincraBridgeEvent _parseEvent(String? eventStr) {
    switch (eventStr) {
      case 'ready':
        return FincraBridgeEvent.ready;
      case 'success':
        return FincraBridgeEvent.success;
      case 'closed':
        return FincraBridgeEvent.closed;
      case 'error':
        return FincraBridgeEvent.error;
      default:
        return FincraBridgeEvent.unknown;
    }
  }
}
