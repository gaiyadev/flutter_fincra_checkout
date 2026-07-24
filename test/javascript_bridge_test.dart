import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fincra_checkout/src/inline/javascript_bridge.dart';

void main() {
  group('FincraBridgeMessage', () {
    test('parses success event correctly', () {
      final jsonString = '{"event":"success","data":{"reference":"REF-123","transactionId":"TXN-456"}}';
      
      final message = FincraBridgeMessage.fromJsonString(jsonString);
      
      expect(message.event, FincraBridgeEvent.success);
      expect(message.data, isNotNull);
      expect(message.data!.reference, 'REF-123');
      expect(message.data!.transactionId, 'TXN-456');
      expect(message.data!.status, 'success');
    });

    test('parses closed event correctly', () {
      final jsonString = '{"event":"closed"}';
      
      final message = FincraBridgeMessage.fromJsonString(jsonString);
      
      expect(message.event, FincraBridgeEvent.closed);
      expect(message.data, isNull);
    });

    test('parses unknown event correctly', () {
      final jsonString = '{"event":"something_else"}';
      
      final message = FincraBridgeMessage.fromJsonString(jsonString);
      
      expect(message.event, FincraBridgeEvent.unknown);
      expect(message.data, isNull);
    });

    test('handles malformed JSON safely', () {
      final jsonString = 'malformed_json_not_valid';
      
      final message = FincraBridgeMessage.fromJsonString(jsonString);
      
      expect(message.event, FincraBridgeEvent.unknown);
      expect(message.data, isNull);
    });
  });
}
