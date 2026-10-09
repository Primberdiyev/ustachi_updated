import 'package:flutter/material.dart' hide Text;
import 'package:url_launcher/url_launcher.dart';
import 'package:ustachi/core/icons/telegram_icon.dart';
import 'package:ustachi/features/auth/presentation/widgets/language_chip.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/components/base_button.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:ustachi/features/auth/presentation/router/auth_router.dart';
import 'package:ustachi/features/auth/presentation/view/auth_form_ui.dart';
import 'package:ustachi/features/splash/presentation/widgets/brand_mark_widget.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({
    super.key,
    required this.router,
  });

  final AuthRouter router;

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = AuthFormUi.createPhoneController();
  final _phoneFormatter = AuthFormUi.createPhoneFormatter();

  static final Uri _botUri = Uri.parse('https://t.me/ustachi_auth_bot?start=master_register');

  Future<void> _openTelegram() async {
    bool opened;
    try {
      opened = await launchUrl(_botUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      sl<SnackbarService>().showMessage(context.t.auth.phone.telegramOpenError);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if ((value ?? '').normalizedPhoneNumber.length != 13) {
      return context.t.auth.common.invalidPhone;
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          AuthCodeRequested(
            phoneNumber: _phoneController.text.normalizedPhoneNumber,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.auth;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.sendCodeStatus != current.sendCodeStatus,
      listener: (context, state) {
        if (state.sendCodeStatus.isSuccess) {
          widget.router.navigateToOtpConfirm(
            context,
            phoneNumber: state.phoneNumber,
          );
          return;
        }

        if (state.sendCodeStatus.isFailure && state.failure != null) {
          sl<SnackbarService>().showMessage(state.failure!.errorMessage);
        }
      },
      builder: (context, state) {
        final isLoading = state.sendCodeStatus.isLoading;

        return Scaffold(
          backgroundColor: colors.neutral.surface,
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    const Align(
                      alignment: Alignment.centerRight,
                      child: LanguageChip(),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: BrandMarkWidget(
                        decoration: colors.neutral.bg,
                        iconColor: colors.categorizedColor.primary,
                        borderColor: colors.neutral.border,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _AudienceNotice(),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        t.phone.title,
                        style: context.text.h1.copyWith(
                          color: colors.neutral.textStrong,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Text(t.phone.label, style: context.text.h4),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_phoneFormatter],
                      validator: _validatePhone,
                      decoration: AuthFormUi.phoneInputDecoration(context),
                      style: context.text.body1,
                      onFieldSubmitted: (_) => isLoading ? null : _submit(),
                    ),
                    const SizedBox(height: 32),
                    BaseButton.primary(
                      text: t.phone.continueBtn,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _submit,
                      backgroundColor: colors.categorizedColor.primary,
                      textColor: colors.neutral.white,
                      textStyle: context.text.body2.copyWith(
                        color: colors.neutral.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Divider(color: colors.neutral.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            t.phone.orOption,
                            style: context.text.body5.copyWith(color: colors.neutral.textMuted),
                          ),
                        ),
                        Expanded(child: Divider(color: colors.neutral.border)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _openTelegram,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: BorderSide(color: colors.neutral.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const TelegramIcon(size: 20),
                          const SizedBox(width: 10),
                          Text(
                            t.phone.telegramBtn,
                            style: context.text.body2.copyWith(
                              color: colors.neutral.textStrong,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.phone.telegramHint,
                      style: context.text.label.copyWith(color: colors.neutral.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AudienceNotice extends StatelessWidget {
  const _AudienceNotice();

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.auth.phone;
    final accent = colors.categorizedColor.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.audienceTitle,
                  style: context.text.body5.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.audienceRedirect,
                  style: context.text.label
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
