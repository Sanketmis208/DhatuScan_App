import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/phone_validator.dart';
import '../../providers/auth_provider.dart';

/// Screen that collects the user's 10-digit mobile number and triggers
/// Firebase Phone OTP authentication.
///
/// Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6
class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  /// Tracks whether the user already attempted to submit — enables inline error.
  bool _submitted = false;

  /// Inline validation error message; null means no error.
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (_submitted) {
      // Re-validate live once the user starts correcting after an attempt.
      setState(() {
        _inlineError = _validatePhone(_phoneController.text);
      });
    } else {
      // Trigger a rebuild so the "Send OTP" button enable state updates.
      setState(() {});
    }
  }

  /// Returns an error string when invalid, null when valid.
  String? _validatePhone(String value) {
    if (!validatePhone(value)) {
      return AppStrings.errorInvalidPhone;
    }
    return null;
  }

  Future<void> _onSendOtp() async {
    setState(() {
      _submitted = true;
      _inlineError = _validatePhone(_phoneController.text);
    });

    if (_inlineError != null) return;

    final phone = _phoneController.text.trim();
    final authProvider = context.read<AuthProvider>();
    await authProvider.sendOtp('+91$phone');
  }

  /// Listens to [AuthProvider] state changes and performs side-effects
  /// (navigation, toasts). Called from the [Consumer] builder.
  void _handleAuthState(BuildContext context, AuthProvider authProvider) {
    switch (authProvider.state) {
      case AuthState.otpSent:
        // Navigate to OTP screen, passing verificationId as argument.
        // Use addPostFrameCallback to avoid calling Navigator during build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            '/otp',
            arguments: authProvider.verificationId,
          );
        });
        break;

      case AuthState.error:
        final message = authProvider.errorMessage ?? AppStrings.errorGeneric;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.error,
            textColor: Colors.white,
            fontSize: 14.0,
          );
          authProvider.clearError();
        });
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Process side-effects on each rebuild when state changes.
        _handleAuthState(context, authProvider);

        final isSendingOtp = authProvider.state == AuthState.sendingOtp;
        final isPhoneValid = validatePhone(_phoneController.text);

        return Scaffold(
          backgroundColor: AppColors.primary,
          body: SafeArea(
            child: Column(
              children: [
                // ── Teal header section ──────────────────────────────────────
                _buildHeader(),
                // ── White card body ──────────────────────────────────────────
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPhoneField(),
                          const SizedBox(height: 8),
                          _buildInlineError(),
                          const SizedBox(height: 32),
                          _buildSendOtpButton(
                            isSendingOtp: isSendingOtp,
                            isPhoneValid: isPhoneValid,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.phoneInputTitle,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.phoneInputSubtitle,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  // ── Phone text field ────────────────────────────────────────────────────────

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          keyboardType: TextInputType.number,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.lato(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            counterText: '', // Hide the default maxLength counter
            hintText: AppStrings.phoneHint,
            hintStyle: GoogleFonts.lato(
              fontSize: 14,
              color: AppColors.textLight,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Text(
                '+91',
                style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: (_submitted && _inlineError != null)
                    ? AppColors.error
                    : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: (_submitted && _inlineError != null)
                    ? AppColors.error
                    : AppColors.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // ── Inline error text ───────────────────────────────────────────────────────

  Widget _buildInlineError() {
    if (!_submitted || _inlineError == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 14),
          const SizedBox(width: 4),
          Text(
            _inlineError!,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // ── Send OTP button ─────────────────────────────────────────────────────────

  Widget _buildSendOtpButton({
    required bool isSendingOtp,
    required bool isPhoneValid,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (isPhoneValid && !isSendingOtp) ? _onSendOtp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          elevation: isPhoneValid ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: isSendingOtp
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(AppStrings.sendOtp),
      ),
    );
  }
}
