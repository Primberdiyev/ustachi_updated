import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ustachi/core/api/error/failures.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/domain/repositories/auth_repository.dart';
import 'package:ustachi/features/auth/presentation/router/auth_router.dart';
import 'package:ustachi/features/profile/presentation/bloc/profile_bloc.dart';

class TelegramExchangePage extends StatefulWidget {
  const TelegramExchangePage({super.key, required this.code, required this.router});

  final String code;
  final AuthRouter router;

  @override
  State<TelegramExchangePage> createState() => _TelegramExchangePageState();
}

class _TelegramExchangePageState extends State<TelegramExchangePage> {
  static final Uri _botUri = Uri.parse('https://t.me/ustachi_auth_bot?start=master_register');
  static final RegExp _codePattern = RegExp(r'^[A-Za-z0-9_-]{16,256}$');

  bool _loading = true;
  Failure? _failure;
  bool _invalidCode = false;

  @override
  void initState() {
    super.initState();
    _exchange();
  }

  @override
  void didUpdateWidget(covariant TelegramExchangePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code) _exchange();
  }

  Future<void> _exchange() async {
    if (!_codePattern.hasMatch(widget.code)) {
      setState(() {
        _loading = false;
        _invalidCode = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _failure = null;
      _invalidCode = false;
    });
    final result = await sl<AuthRepository>().exchangeTelegramCode(widget.code);
    if (!mounted) return;

    if (result.isRight) {
      context.read<ProfileBloc>().add(const ClearProfileEvent());
      widget.router.replaceWithHome(context);
      return;
    }

    setState(() {
      _loading = false;
      _failure = result.left;
    });
  }

  Future<void> _restartBot() async {
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
  Widget build(BuildContext context) {
    final t = context.t.auth.telegram;
    final colors = context.color;
    final expired =
        _failure is ServerFailure && const {400, 404, 410}.contains((_failure as ServerFailure).statusCode);
    final message = _invalidCode
        ? t.invalidLink
        : expired
            ? t.expiredLink
            : _failure?.errorMessage ?? t.invalidLink;

    return Scaffold(
      backgroundColor: colors.neutral.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _loading ? Icons.lock_outline_rounded : Icons.link_off_rounded,
                  size: 48,
                  color: colors.categorizedColor.primary,
                ),
                const SizedBox(height: 20),
                Text(t.loadingTitle, style: context.text.h1, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _loading ? t.loadingHint : message,
                    style: context.text.body2.copyWith(
                      color: _loading ? colors.neutral.textMuted : colors.categorizedColor.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                if (_loading)
                  Center(child: CircularProgressIndicator(color: colors.categorizedColor.primary))
                else ...[
                  if (!_invalidCode && !expired)
                    FilledButton(onPressed: _exchange, child: Text(t.retry)),
                  FilledButton(onPressed: _restartBot, child: Text(t.restartBot)),
                  TextButton(
                    onPressed: () => context.router.root.replaceAll([const PhoneAuthPageRoute()]),
                    child: Text(t.smsOption),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
