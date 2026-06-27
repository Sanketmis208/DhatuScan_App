// Feature: dhatu-scan-app, Property 8: assessment state JSON round-trip
// Validates: Requirements 15.3, 17.1, 17.2

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhatuscan/models/assessment_model.dart';

void main() {
  group('Assessment state JSON round-trip serialization property', () {
    test('DhatuVKAnswers to/from JSON round-trip is lossless', () {
      final original = DhatuVKAnswers(
        vriddhiAnswers: {
          'Excessive Salivation': 2,
          'Loss of Appetite': 3,
          'Body Ache': 0,
        },
        kshayaAnswers: {
          'Dryness': 1,
          'State of Illusion': 3,
        },
      );

      final jsonMap = original.toJson();
      final roundTrip = DhatuVKAnswers.fromJson(jsonMap);

      expect(roundTrip.vriddhiAnswers, original.vriddhiAnswers);
      expect(roundTrip.kshayaAnswers, original.kshayaAnswers);
      expect(roundTrip.vriddhiScore, original.vriddhiScore);
      expect(roundTrip.kshayaScore, original.kshayaScore);
    });

    test('Full vkAnswers map json round-trip matches exactly', () {
      final originalMap = {
        'Rasa': DhatuVKAnswers(
          vriddhiAnswers: {'Excessive Salivation': 2},
          kshayaAnswers: {'Dryness': 1},
        ),
        'Rakta': DhatuVKAnswers(
          vriddhiAnswers: {'Skin Inflammation': 3},
          kshayaAnswers: {'Desire for Sour Taste': 0},
        ),
      };

      // Encode
      final encoded = jsonEncode(originalMap.map((k, v) => MapEntry(k, v.toJson())));

      // Decode
      final decodedMap = (jsonDecode(encoded) as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, DhatuVKAnswers.fromJson(v as Map<String, dynamic>)),
      );

      expect(decodedMap.length, originalMap.length);
      for (final key in originalMap.keys) {
        expect(decodedMap[key]!.vriddhiAnswers, originalMap[key]!.vriddhiAnswers);
        expect(decodedMap[key]!.kshayaAnswers, originalMap[key]!.kshayaAnswers);
      }
    });

    test('SarataSelections map json round-trip matches exactly', () {
      final originalSelections = {
        'Rasa': {
          'Oily skin': true,
          'Smooth skin': false,
          'Glowing skin': true,
        },
        'Rakta': {
          'Moist/Lustrous body parts': true,
          'Reddish/Pink skin tone': true,
        },
      };

      // Encode
      final encoded = jsonEncode(originalSelections);

      // Decode
      final decodedSelections = (jsonDecode(encoded) as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          k,
          (v as Map<String, dynamic>).map((sk, sv) => MapEntry(sk, sv as bool)),
        ),
      );

      expect(decodedSelections, originalSelections);
    });
  });
}
