// Feature: dhatu-scan-app, Property 7: Recommendation table completeness
// Validates: Requirements 13.1, 13.2, 13.3

import 'package:flutter_test/flutter_test.dart';
import 'package:dhatuscan/core/constants/recommendations_data.dart';

void main() {
  group('Recommendation Table Completeness Property', () {
    test('all 14 combinations of Dhatus and conditions return non-null, non-empty recommendations', () {
      final dhatus = ['Rasa', 'Rakta', 'Mamsa', 'Meda', 'Asthi', 'Majja', 'Shukra'];
      final conditions = ['Vriddhi', 'Kshaya'];

      int count = 0;
      for (final dhatu in dhatus) {
        for (final condition in conditions) {
          final rec = RecommendationsData.getRecommendation(dhatu, condition);

          expect(rec, isNotNull, reason: 'No recommendation found for $dhatu - $condition');
          expect(rec!.dhatu, dhatu);
          expect(rec.condition, condition);

          // Verify all fields are non-empty
          expect(rec.pathyaAahar.isNotEmpty, isTrue, reason: 'pathyaAahar is empty for $dhatu - $condition');
          expect(rec.pathyaAaharHi.isNotEmpty, isTrue, reason: 'pathyaAaharHi is empty for $dhatu - $condition');
          expect(rec.apathyaAahar.isNotEmpty, isTrue, reason: 'apathyaAahar is empty for $dhatu - $condition');
          expect(rec.apathyaAaharHi.isNotEmpty, isTrue, reason: 'apathyaAaharHi is empty for $dhatu - $condition');
          expect(rec.pathyaVihara.isNotEmpty, isTrue, reason: 'pathyaVihara is empty for $dhatu - $condition');
          expect(rec.pathyaViharaHi.isNotEmpty, isTrue, reason: 'pathyaViharaHi is empty for $dhatu - $condition');
          expect(rec.apathyaVihara.isNotEmpty, isTrue, reason: 'apathyaVihara is empty for $dhatu - $condition');
          expect(rec.apathyaViharaHi.isNotEmpty, isTrue, reason: 'apathyaViharaHi is empty for $dhatu - $condition');
          expect(rec.aushadha.isNotEmpty, isTrue, reason: 'aushadha is empty for $dhatu - $condition');
          expect(rec.aushadhaHi.isNotEmpty, isTrue, reason: 'aushadhaHi is empty for $dhatu - $condition');

          count++;
        }
      }

      expect(count, 14);
    });
  });
}
