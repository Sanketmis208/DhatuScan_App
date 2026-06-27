import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_storage_service.dart';

/// Screen that collects the 6-digit OTP and verifies the user's phone number
/// via Firebase Phone Authentication.
///
/// Receives [verificationId] from route arguments (passed by [PhoneInputScreen]).
///
/// Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 4.10
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  /// Countdown timer — starts at 60 seconds, decrements every second.
  Timer? _countdownTimer;
  int _secondsRemaining = 60;

  /// Inline error shown beneath the Pinput widget (e.g. incorrect OTP).
  String? _otpError;

  /// Whether the "Verify & Continue" button was tapped (guards against
  /// re-triggering navigation on subsequent rebuilds).
  bool _verifyTapped = false;

  // ── Pinput theme definitions ───────────────────────────────────────────────

  /// Default (unfocused, empty) cell style.
  final _defaultPinTheme = PinTheme(
    width: 48,
    height: 56,
    textStyle: GoogleFonts.lato(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300, width: 1.5),
    ),
  );

  PinTheme get _focusedPinTheme => _defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary, // teal #1A5C5A
            width: 2,
          ),
        ),
      );

  PinTheme get _submittedPinTheme => _defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accent, // golden #E8A838
            width: 2,
          ),
        ),
      );

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  // ── Countdown helpers ──────────────────────────────────────────────────────

  /// Starts (or restarts) the 60-second countdown.
  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  bool get _isTimerRunning => _secondsRemaining > 0;

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _onResendOtp() async {
    if (_isTimerRunning) return;
    final authProvider = context.read<AuthProvider>();
    _otpController.clear();
    setState(() => _otpError = null);
    await authProvider.resendOtp();
    _startCountdown();
  }

  Future<void> _onVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _otpError = 'Please enter the complete 6-digit OTP.');
      return;
    }

    setState(() {
      _otpError = null;
      _verifyTapped = true;
    });

    final authProvider = context.read<AuthProvider>();
    await authProvider.verifyOtp(otp);
    // Navigation and error handling are done in [_handleAuthState].
  }

  // ── State handler (side-effects) ───────────────────────────────────────────

  void _handleAuthState(BuildContext context, AuthProvider authProvider) {
    switch (authProvider.state) {
      case AuthState.authenticated:
        if (!_verifyTapped) break;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _verifyTapped = false;
          
          final userData = LocalStorageService.userData;
          final isProfileComplete = userData?['isProfileComplete'] as bool? ?? false;

          if (authProvider.isNewUser || !isProfileComplete) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.personalDetails,
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboard,
              (route) => false,
            );
          }
        });
        break;

      case AuthState.error:
        if (!_verifyTapped) break;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _verifyTapped = false;
          final message = authProvider.errorMessage ?? AppStrings.errorOtpFailed;

          // Distinguish between incorrect OTP (inline error) and expiry (toast).
          final isExpired = message.toLowerCase().contains('expired') ||
              message.toLowerCase().contains('session');

          if (isExpired) {
            Fluttertoast.showToast(
              msg: 'OTP has expired. Please tap "Resend OTP" to get a new code.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppColors.error,
              textColor: Colors.white,
              fontSize: 14.0,
            );
          } else {
            setState(() => _otpError = message);
          }

          authProvider.clearError();
        });
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract verificationId from route arguments (Requirement 4.6).
    // AuthProvider already stores this value internally via sendOtp(); the
    // argument is validated here to ensure the screen is reached correctly.
    assert(
      ModalRoute.of(context)?.settings.arguments is String?,
      'OtpVerificationScreen expects a String verificationId as route argument',
    );

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        _handleAuthState(context, authProvider);

        final isVerifying = authProvider.state == AuthState.verifying;
        final otp = _otpController.text;

        return Scaffold(
          backgroundColor: AppColors.primary,
          body: SafeArea(
            child: Column(
              children: [
                // ── Teal header ───────────────────────────────────────────
                _buildHeader(authProvider),
                // ── White card body ───────────────────────────────────────
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
                          _buildOtpLabel(),
                          const SizedBox(height: 12),
                          _buildPinput(isVerifying: isVerifying),
                          const SizedBox(height: 8),
                          _buildInlineError(),
                          const SizedBox(height: 24),
                          _buildCountdownRow(),
                          const SizedBox(height: 32),
                          _buildVerifyButton(
                            otp: otp,
                            isVerifying: isVerifying,
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

  Widget _buildHeader(AuthProvider authProvider) {
    final phone = authProvider.phoneNumber ?? '';
    // Strip leading +91 for display if present.
    final displayPhone =
        phone.startsWith('+91') ? phone.substring(3) : phone;
    // Mask phone number: e.g. XXXXXX1234
    final maskedPhone = displayPhone.length >= 10
        ? 'XXXXXX${displayPhone.substring(displayPhone.length - 4)}'
        : displayPhone;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button → returns to phone input screen.
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
            AppStrings.otpVerificationTitle,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${AppStrings.otpVerificationSubtitle} +91 $maskedPhone',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  // ── OTP label ──────────────────────────────────────────────────────────────

  Widget _buildOtpLabel() {
    return Text(
      'Enter OTP',
      style: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ── Pinput widget ──────────────────────────────────────────────────────────

  Widget _buildPinput({required bool isVerifying}) {
    return Pinput(
      controller: _otpController,
      focusNode: _otpFocusNode,
      length: 6,
      defaultPinTheme: _defaultPinTheme,
      focusedPinTheme: _focusedPinTheme,
      submittedPinTheme: _submittedPinTheme,
      errorPinTheme: _defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error, width: 1.5),
        ),
      ),
      keyboardType: TextInputType.number,
      readOnly: isVerifying,
      autofocus: true,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      onChanged: (value) {
        // Clear inline error as the user edits.
        if (_otpError != null) {
          setState(() => _otpError = null);
        }
      },
      onCompleted: (_) {
        // Auto-trigger verify when all 6 digits entered.
        if (!isVerifying) _onVerify();
      },
      // Show error state when there is an inline error.
      forceErrorState: _otpError != null,
      errorText: null, // We render our own error widget below.
    );
  }

  // ── Inline error ───────────────────────────────────────────────────────────

  Widget _buildInlineError() {
    if (_otpError == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _otpError!,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Countdown row ──────────────────────────────────────────────────────────

  Widget _buildCountdownRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Timer label
        if (_isTimerRunning)
          Text(
            'Resend in ${_secondsRemaining}s',
            style: GoogleFonts.lato(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          )
        else
          Text(
            'Didn\'t receive the code?',
            style: GoogleFonts.lato(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

        // Resend OTP button
        TextButton(
          onPressed: _isTimerRunning ? null : _onResendOtp,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textLight,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppStrings.resendOtp,
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Verify button ──────────────────────────────────────────────────────────

  Widget _buildVerifyButton({
    required String otp,
    required bool isVerifying,
  }) {
    final isOtpComplete = otp.length == 6;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (isOtpComplete && !isVerifying) ? _onVerify : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          elevation: isOtpComplete ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: isVerifying
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(AppStrings.verifyOtp),
      ),
    );
  }
}
