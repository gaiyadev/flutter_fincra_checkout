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

  /// The error message carried by an [FincraBridgeEvent.error] event, if any.
  final String? errorMessage;

  FincraBridgeMessage({required this.event, this.data, this.errorMessage});

  /// Parses a raw JSON string message from the JavaScript channel.
  factory FincraBridgeMessage.fromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      final eventString = map['event'] as String?;
      final event = _parseEvent(eventString);
      final rawData = map['data'];

      FincraPaymentResponse? data;
      String? errorMessage;

      if (event == FincraBridgeEvent.success) {
        // A success must always surface as a success, even if Fincra sent no data.
        final dataMap = rawData is Map ? rawData : const {};

        // Convert to map of strings as FincraPaymentResponse expects it from url params.
        final params = <String, String>{
          for (final entry in dataMap.entries)
            if (entry.value != null)
              entry.key.toString(): _stringify(entry.value),
        };

        // Ensure status is success for the FincraPaymentResponse
        params['status'] ??= 'success';

        data = FincraPaymentResponse.fromUrlParams(params);
      } else if (event == FincraBridgeEvent.error && rawData is Map) {
        errorMessage = rawData['message']?.toString();
      }

      return FincraBridgeMessage(
        event: event,
        data: data,
        errorMessage: errorMessage,
      );
    } catch (e) {
      return FincraBridgeMessage(event: FincraBridgeEvent.unknown);
    }
  }

  static String _stringify(Object value) {
    if (value is Map || value is List) return jsonEncode(value);
    return value.toString();
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
