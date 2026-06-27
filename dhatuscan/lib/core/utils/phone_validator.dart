/// Phone number validation utility.
///
/// Validates that a phone number consists of exactly 10 decimal digits,
/// conforming to the Indian mobile number format used in DhatuScan.
library phone_validator;

// Feature: dhatu-scan-app, Property 1: phone input validation

final _phoneRegex = RegExp(r'^\d{10}$');

/// Returns `true` if and only if [input] matches `/^\d{10}$/`.
///
/// Requirements: 3.1, 3.2, 3.3
bool validatePhone(String input) => _phoneRegex.hasMatch(input);
