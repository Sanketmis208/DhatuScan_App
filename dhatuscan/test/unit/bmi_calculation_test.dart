// Feature: dhatu-scan-app, Property 2: BMI computation
// Validates: Requirements 5.3
//
// Property: For any height h > 0 cm and weight w > 0 kg,
//   UserModel.calculateBmi(h, w) == w / (h/100)^2  (rounded to 1 dp)
//   and the result must be positive and finite.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:dhatuscan/models/user_model.dart';

void main() {
  // ── Helper ──────────────────────────────────────────────────────────────────
  double _expectedBmi(double h, double w) {
    final hM = h / 100.0;
    return w / (hM * hM);
  }

  // ── Deterministic edge cases ─────────────────────────────────────────────
  group('BMI computation — deterministic cases', () {
    test('typical: 170 cm, 70 kg → ≈ 24.2', () {
      final bmi = UserModel.calculateBmi(170, 70)!;
      expect(bmi, closeTo(24.22, 0.05));
    });

    test('minimum valid input: 1 cm, 1 kg → positive finite', () {
      final bmi = UserModel.calculateBmi(1, 1)!;
      expect(bmi.isFinite, isTrue);
      expect(bmi > 0, isTrue);
    });

    test('maximum valid input: 300 cm, 300 kg → positive finite', () {
      final bmi = UserModel.calculateBmi(300, 300)!;
      expect(bmi.isFinite, isTrue);
      expect(bmi > 0, isTrue);
    });

    test('returns null when height is 0', () {
      expect(UserModel.calculateBmi(0, 70), isNull);
    });

    test('returns null when height is null', () {
      expect(UserModel.calculateBmi(null, 70), isNull);
    });

    test('returns null when weight is null', () {
      expect(UserModel.calculateBmi(170, null), isNull);
    });
  });

  // ── Property-based test (100+ random samples) ────────────────────────────
  // dart_check is declared as a dev-dep but its API surface is not guaranteed
  // to be stable; we implement the same property using a seeded Random to keep
  // the test hermetic and always passing in CI.
  //
  // The property verified:
  //   ∀ h ∈ (0, 300], w ∈ (0, 300]:
  //     calculateBmi(h, w) == w / (h/100)²  AND  result > 0  AND  result.isFinite
  group('BMI computation — property (100 random samples)', () {
    test('w / (h/100)^2 for random h, w in (0, 300]', () {
      final rng = Random(42); // fixed seed → reproducible
      const iterations = 100;

      for (var i = 0; i < iterations; i++) {
        // h and w in range (0.01, 300]
        final h = 0.01 + rng.nextDouble() * 299.99;
        final w = 0.01 + rng.nextDouble() * 299.99;

        final bmi = UserModel.calculateBmi(h, w);

        expect(
          bmi,
          isNotNull,
          reason: 'calculateBmi($h, $w) returned null',
        );

        final expected = _expectedBmi(h, w);

        expect(
          bmi!,
          closeTo(expected, 1e-9),
          reason: 'calculateBmi($h, $w): got $bmi, expected $expected',
        );

        expect(
          bmi > 0,
          isTrue,
          reason: 'BMI must be positive for h=$h, w=$w',
        );

        expect(
          bmi.isFinite,
          isTrue,
          reason: 'BMI must be finite for h=$h, w=$w',
        );
      }
    });
  });
}
