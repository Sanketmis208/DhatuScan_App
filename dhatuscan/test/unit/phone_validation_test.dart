// Feature: dhatu-scan-app, Property 1: phone input validation
// Validates: Requirements 3.1, 3.2, 3.3
//
// Property 1: For any string input, validatePhone(input) SHALL accept it if
// and only if it matches /^\d{10}$/. Any string shorter, longer, or containing
// non-digits SHALL be rejected.
//
// dart_check is not yet a dependency; property tests are simulated via manual
// loops of 100+ iterations using the built-in test package.

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhatuscan/core/utils/phone_validator.dart';

// ---------------------------------------------------------------------------
// Helpers / generators
// ---------------------------------------------------------------------------

final _rng = Random(42); // fixed seed for reproducibility

const _digits = '0123456789';
const _letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
const _specials = r'!@#$%^&*()-_=+[]{}|;:,.<>?/\~`"' "'";
const _allChars = _digits + _letters + _specials + ' ';

String _randomDigitString(int length) {
  return List.generate(length, (_) => _digits[_rng.nextInt(_digits.length)])
      .join();
}

String _randomString(int length, String charset) {
  return List.generate(
          length, (_) => charset[_rng.nextInt(charset.length)]).join();
}

/// Generates a string of exactly 10 characters that contains at least one
/// non-digit, so it looks like a phone number but is invalid.
String _almostPhoneWithNonDigit() {
  // Replace one random position with a letter or special character.
  final chars = List<String>.from(_randomDigitString(10).split(''));
  final pos = _rng.nextInt(10);
  final pollution = _letters + _specials + ' ';
  chars[pos] = pollution[_rng.nextInt(pollution.length)];
  return chars.join();
}

// ---------------------------------------------------------------------------
// Test suite
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Group 1: Valid 10-digit strings (should return true)
  // Runs 100 iterations of randomly generated 10-digit strings.
  // -------------------------------------------------------------------------
  group('Valid 10-digit strings (Property 1 — accept)', () {
    test('100 random 10-digit strings are accepted', () {
      for (var i = 0; i < 100; i++) {
        final input = _randomDigitString(10);
        expect(
          validatePhone(input),
          isTrue,
          reason: 'Expected validatePhone("$input") to return true '
              '(exactly 10 digits)',
        );
      }
    });

    test('10-digit string with leading zeros is accepted', () {
      // Leading zeros are still valid — they are digits.
      const leadingZero = '0000000000';
      expect(validatePhone(leadingZero), isTrue);

      const mixed = '0123456789';
      expect(validatePhone(mixed), isTrue);

      // Generate 50 more strings that all start with "0".
      for (var i = 0; i < 50; i++) {
        final input = '0' + _randomDigitString(9);
        expect(
          validatePhone(input),
          isTrue,
          reason: 'Expected validatePhone("$input") to return true '
              '(leading zero, exactly 10 digits)',
        );
      }
    });
  });

  // -------------------------------------------------------------------------
  // Group 2: Strings shorter than 10 digits (should return false)
  // 100 iterations: lengths 0–9 each at least once.
  // -------------------------------------------------------------------------
  group('Short strings — fewer than 10 digits (Property 1 — reject)', () {
    test('Empty string is rejected', () {
      expect(validatePhone(''), isFalse);
    });

    test('100 random digit strings shorter than 10 chars are rejected', () {
      for (var i = 0; i < 100; i++) {
        final length = _rng.nextInt(10); // 0..9
        final input = _randomDigitString(length);
        expect(
          validatePhone(input),
          isFalse,
          reason: 'Expected validatePhone("$input") to return false '
              '(length ${input.length} < 10)',
        );
      }
    });

    test('All lengths 1–9 (all-digit) are individually rejected', () {
      for (var len = 1; len <= 9; len++) {
        final input = _randomDigitString(len);
        expect(
          validatePhone(input),
          isFalse,
          reason: 'Length $len should be rejected',
        );
      }
    });
  });

  // -------------------------------------------------------------------------
  // Group 3: Strings longer than 10 digits (should return false)
  // 100 iterations: lengths 11–30.
  // -------------------------------------------------------------------------
  group('Long strings — more than 10 digits (Property 1 — reject)', () {
    test('100 random digit strings longer than 10 chars are rejected', () {
      for (var i = 0; i < 100; i++) {
        final length = 11 + _rng.nextInt(20); // 11..30
        final input = _randomDigitString(length);
        expect(
          validatePhone(input),
          isFalse,
          reason: 'Expected validatePhone("$input") to return false '
              '(length ${input.length} > 10)',
        );
      }
    });

    test('Lengths 11–20 (all-digit) are individually rejected', () {
      for (var len = 11; len <= 20; len++) {
        final input = _randomDigitString(len);
        expect(
          validatePhone(input),
          isFalse,
          reason: 'Length $len should be rejected',
        );
      }
    });
  });

  // -------------------------------------------------------------------------
  // Group 4: Strings with letters (should return false)
  // -------------------------------------------------------------------------
  group('Strings containing letters (Property 1 — reject)', () {
    test('100 random alphanumeric strings of length 10 with a letter are rejected', () {
      for (var i = 0; i < 100; i++) {
        final input = _almostPhoneWithNonDigit();
        // Regenerate until at least one character is a letter or special.
        expect(
          validatePhone(input),
          isFalse,
          reason: 'Expected validatePhone("$input") to return false '
              '(contains non-digit character)',
        );
      }
    });

    test('Pure letter strings of length 10 are rejected', () {
      for (var i = 0; i < 50; i++) {
        final input = _randomString(10, _letters);
        expect(validatePhone(input), isFalse,
            reason: '"$input" is all letters — should be rejected');
      }
    });
  });

  // -------------------------------------------------------------------------
  // Group 5: Strings with special characters (should return false)
  // -------------------------------------------------------------------------
  group('Strings with special characters (Property 1 — reject)', () {
    test('10-char strings containing special chars are rejected', () {
      for (var i = 0; i < 50; i++) {
        final input = _randomString(10, _specials + _digits);
        // Only fail the test if the randomly generated string happened to be
        // all digits (astronomically unlikely but guard it).
        if (RegExp(r'^\d{10}$').hasMatch(input)) continue;
        expect(validatePhone(input), isFalse,
            reason: '"$input" contains special chars — should be rejected');
      }
    });

    test('Common special-character patterns are rejected', () {
      const invalid = [
        '+9876543210', // leading +
        '98765 43210', // internal space
        '9876-543210', // hyphen
        '98765432.10', // dot
        '(9876543210)', // parentheses
        '9876543210!', // trailing special char
      ];
      for (final input in invalid) {
        expect(validatePhone(input), isFalse,
            reason: '"$input" should be rejected');
      }
    });
  });

  // -------------------------------------------------------------------------
  // Group 6: Strings with spaces (should return false)
  // -------------------------------------------------------------------------
  group('Strings with spaces (Property 1 — reject)', () {
    test('10-digit strings with embedded space are rejected', () {
      const cases = [
        '9876 43210', // internal space (9 chars + space = 10)
        ' 987654321', // leading space
        '987654321 ', // trailing space
        '98 765 321', // multiple spaces
        '          ', // all spaces
      ];
      for (final input in cases) {
        expect(validatePhone(input), isFalse,
            reason: '"$input" contains spaces — should be rejected');
      }
    });
  });

  // -------------------------------------------------------------------------
  // Group 7: Boundary / edge cases
  // -------------------------------------------------------------------------
  group('Edge cases (Property 1)', () {
    test('Exactly 9 digits is rejected', () {
      expect(validatePhone('123456789'), isFalse);
    });

    test('Exactly 10 digits is accepted', () {
      expect(validatePhone('1234567890'), isTrue);
    });

    test('Exactly 11 digits is rejected', () {
      expect(validatePhone('12345678901'), isFalse);
    });

    test('Unicode digit lookalikes are rejected', () {
      // U+0661 ARABIC-INDIC DIGIT ONE — looks like '1' but is not ASCII digit
      // Dart string literal for Arabic-Indic digits 1–10
      const arabicIndic = '\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669\u0660';
      expect(validatePhone(arabicIndic), isFalse,
          reason: 'Arabic-Indic digit lookalikes must be rejected');
    });

    test('Null-byte embedded string is rejected', () {
      final withNull = '12345\x0067890'; // 11 chars with null byte between
      expect(validatePhone(withNull), isFalse);
    });

    test('Whitespace-only strings are rejected', () {
      for (final ws in ['\t', '\n', '\r', ' ']) {
        expect(validatePhone(ws * 10), isFalse,
            reason: 'Whitespace-only string must be rejected');
      }
    });
  });
}
