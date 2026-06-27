import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

/// Validates that [input] is exactly 10 numeric digits.
/// Returns null when valid, an error string when invalid.
String? validatePhone(String? input) {
  if (input == null || input.isEmpty) {
    return AppStrings.errorRequired;
  }
  final digitsOnly = RegExp(r'^\d{10}$');
  if (!digitsOnly.hasMatch(input)) {
    return AppStrings.errorInvalidPhone;
  }
  return null;
}

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Tracks whether the user has already tried submitting (to show inline errors
  /// only after the first attempt, not before).
  bool _submitted = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ── Auth-state listener ────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Listen once the tree is built so we have context.
      final auth = context.read<AuthProvider>();
      auth.addListener(_onAuthStateChanged);
    });
  }

  void _onAuthStateChanged() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();

    if (auth.state == AuthState.otpSent) {
      // Navigate to OTP screen passing the verificationId as a route argument.
      Navigator.of(context).pushNamed(
        '/otp',
        arguments: auth.verificationId,
      );
    } else if (auth.state == AuthState.error) {
      final msg = auth.errorMessage ?? AppStrings.errorGeneric;
      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  @override
  void deactivate() {
    // Remove listener when the screen is popped to avoid stale callbacks.
    final auth = context.read<AuthProvider>();
    auth.removeListener(_onAuthStateChanged);
    super.deactivate();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _onSendOtp() async {
    setState(() => _submitted = true);

    // Run local validation first.
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final auth = context.read<AuthProvider>();

    // sendOtp internally fires two concurrent calls:
    //  1. Firebase verifyPhoneNumber → triggers the OTP SMS
    //  2. ApiService.checkUser(phone) → determines isNewUser (stored in provider)
    await auth.sendOtp(phone);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final isSending = auth.state == AuthState.sendingOtp;

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // ── Logo / branding ─────────────────────────────────────
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.health_and_safety_outlined,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Title ───────────────────────────────────────────────
                    Text(
                      AppStrings.phoneInputTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.phoneInputSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 40),

                    // ── Phone input form ────────────────────────────────────
                    Form(
                      key: _formKey,
                      autovalidateMode: _submitted
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: _PhoneField(controller: _phoneController),
                    ),
                    const SizedBox(height: 32),

                    // ── Send OTP button / loading indicator ─────────────────
                    if (isSending)
                      const Center(child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ))
                    else
                      ElevatedButton(
                        onPressed: isSending ? null : _onSendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          AppStrings.sendOtp,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Phone input field widget ───────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      maxLength: 10,
      style: const TextStyle(
        fontSize: 18,
        color: AppColors.textPrimary,
        letterSpacing: 2,
      ),
      decoration: InputDecoration(
        counterText: '', // hide the default "x/10" counter
        labelText: AppStrings.mobileLabel,
        hintText: AppStrings.phoneHint,
        hintStyle: const TextStyle(color: AppColors.textLight),
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4),
              const Text(
                '+91',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 24,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.textLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validatePhone,
      textInputAction: TextInputAction.done,
    );
  }
}
