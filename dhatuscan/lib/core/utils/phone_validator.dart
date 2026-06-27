/// Pure function for validating Indian mobile phone numbers.
///
/// Accepts a string and returns [true] if and only if the input consists of
/// exactly 10 ASCII digit characters (matches `/^\d{10}$/`).
/// Any string shorter, longer, or containing non-digits is rejected.

final _phoneRegex = RegExp(r'^\d{10}$');

/// Returns [true] if [input] is exactly 10 ASCII digit characters.
bool validatePhone(String input) => _phoneRegex.hasMatch(input);
