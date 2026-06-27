/// Pure function for validating Indian mobile phone numbers.
///
/// Accepts a string and returns [true] if and only if the input consists of
/// exactly 10 ASCII digit characters (matches `/^\d{10}$/`).
/// Any string shorter, longer, or containing non-digits is rejected.
///
/// Requirements: 3.1, 3.2, 3.3
library phone_validator;

// Feature: dhatu-scan-app, Property 1: phone input validation

final _phoneRegex = RegExp(r'^\d{10}$');

/// Returns `true` if and only if [input] matches `/^\d{10}$/`.
bool validatePhone(String input) => _phoneRegex.hasMatch(input);
