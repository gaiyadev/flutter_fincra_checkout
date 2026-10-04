import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fincra_checkout/src/inline/javascript_bridge.dart';

void main() {
  group('FincraBridgeMessage', () {
    test('parses success event correctly', () {
      final jsonString =
          '{"event":"success","data":{"reference":"REF-123","transactionId":"TXN-456"}}';

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
    test('keeps the message of an error event', () {
      final message = FincraBridgeMessage.fromJsonString(
        '{"event":"error","data":{"message":"Fincra SDK failed to load."}}',
      );

      expect(message.event, FincraBridgeEvent.error);
      expect(message.errorMessage, 'Fincra SDK failed to load.');
      expect(message.data, isNull);
    });

    test('success without data still yields a response', () {
      for (final json in [
        '{"event":"success"}',
        '{"event":"success","data":null}',
      ]) {
        final message = FincraBridgeMessage.fromJsonString(json);

        expect(message.event, FincraBridgeEvent.success);
        expect(message.data, isNotNull);
        expect(message.data!.status, 'success');
      }
    });

    test('JSON-encodes nested success data and drops nulls', () {
      final message = FincraBridgeMessage.fromJsonString(
        '{"event":"success","data":{"reference":"R1","customer":{"name":"A"},'
        '"tags":[1,2],"message":null}}',
      );

      final raw = message.data!.rawResponse!;
      expect(raw['customer'], '{"name":"A"}');
      expect(raw['tags'], '[1,2]');
      expect(raw.containsKey('message'), isFalse);
      expect(message.data!.message, isNull);
    });
  });
}
