import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:ustachi/core/components/base_button.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:ustachi/features/auth/presentation/router/auth_router.dart';

class OtpConfirmPage extends StatefulWidget {
  const OtpConfirmPage({
    super.key,
    required this.phoneNumber,
    required this.router,
  });

  final String phoneNumber;
  final AuthRouter router;

  @override
  State<OtpConfirmPage> createState() => _OtpConfirmPageState();
}

class _OtpConfirmPageState extends State<OtpConfirmPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  static const _resendCooldown = 180;

  Timer? _timer;
  int _secondsRemaining = _resendCooldown;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = _resendCooldown;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
        return;
      }

      setState(() => _canResend = true);
      timer.cancel();
    });
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          AuthCodeSubmitted(
            phoneNumber: widget.phoneNumber,
            code: _otpController.text,
          ),
        );
  }

  void _resend() {

    context.read<AuthBloc>().add(
          AuthCodeResendRequested(phoneNumber: widget.phoneNumber),
        );
  }

  String get _timerText {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  PinTheme _pinTheme(BuildContext context, {Color? borderColor, double? width}) {
    return PinTheme(
      width: 48,
      height: 56,
      textStyle: context.text.h2Black1,
      decoration: BoxDecoration(
        color: context.color.neutral.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? context.color.neutral.border,
          width: width ?? 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.auth.otp;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.verifyCodeStatus != current.verifyCodeStatus ||
          previous.resendCodeStatus != current.resendCodeStatus,
      listener: (context, state) {
        if (state.verifyCodeStatus.isSuccess) {

          if (state.isNewUser) {
            widget.router.replaceWithCompleteProfile(context);
          } else {
            widget.router.replaceWithHome(context);
          }
          return;
        }

        if (state.verifyCodeStatus.isFailure && state.failure != null) {
          sl<SnackbarService>().showMessage(state.failure!.errorMessage);
          return;
        }

        if (state.resendCodeStatus.isSuccess) {
          _startTimer();
          return;
        }

        if (state.resendCodeStatus.isFailure && state.failure != null) {
          sl<SnackbarService>().showMessage(state.failure!.errorMessage);
        }
      },
      builder: (context, state) {
        final isVerifying = state.verifyCodeStatus.isLoading;
        final isResending = state.resendCodeStatus.isLoading;

        return Scaffold(
          backgroundColor: colors.neutral.surface,
          appBar: AppBar(
            backgroundColor: colors.neutral.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: colors.neutral.textStrong,
              ),
              onPressed: () => context.router.back(),
            ),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    t.title,
                    style: context.text.h1.copyWith(
                      color: colors.neutral.textStrong,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.sentMessage(
                      phone: widget.phoneNumber.maskedPhoneNumber,
                    ),
                    style: context.text.body2.copyWith(
                      color: colors.neutral.textMuted,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Pinput(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    length: 6,
                    validator: (value) {
                      if ((value ?? '').trim().length != 6) {
                        return t.invalidCode;
                      }
                      return null;
                    },

                    onCompleted: (_) => _confirm(),
                    defaultPinTheme: _pinTheme(context),
                    focusedPinTheme: _pinTheme(
                      context,
                      borderColor: colors.categorizedColor.primary,
                      width: 2,
                    ),
                    errorPinTheme: _pinTheme(
                      context,
                      borderColor: colors.categorizedColor.error,
                      width: 2,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 28),
                  if (_canResend)
                    TextButton(
                      onPressed: isResending ? null : _resend,
                      child: Text(
                        t.resend,
                        style: context.text.body2.copyWith(
                          color: colors.categorizedColor.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t.resendIn,
                          style: context.text.body3.copyWith(
                            color: colors.neutral.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timerText,

                          style: context.text.numeric.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  BaseButton.primary(
                    onPressed: isVerifying ? null : _confirm,
                    isLoading: isVerifying,
                    text: t.confirmBtn,
                    backgroundColor: colors.categorizedColor.primary,
                    textColor: colors.neutral.white,
                    textStyle: context.text.body2.copyWith(
                      color: colors.neutral.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.router.back(),
                    child: Text(
                      t.changeNumber,
                      style: context.text.body3.copyWith(
                        color: colors.neutral.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
