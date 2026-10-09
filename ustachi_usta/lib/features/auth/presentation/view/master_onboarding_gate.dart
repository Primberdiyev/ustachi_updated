import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/auth/domain/services/master_onboarding_check.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';

class MasterOnboardingGate extends StatefulWidget {
  const MasterOnboardingGate({
    super.key,
    required this.check,
    required this.personalBuilder,
    required this.professionalBuilder,
    required this.readyBuilder,
    required this.onSignIn,
    this.reconnects,
  });
  final Future<MasterOnboardingResult> Function() check;
  final Widget Function(UserModel user, VoidCallback saved) personalBuilder;
  final Widget Function(VoidCallback saved) professionalBuilder;
  final WidgetBuilder readyBuilder;
  final VoidCallback onSignIn;
  final Stream<void>? reconnects;

  @override
  State<MasterOnboardingGate> createState() => _MasterOnboardingGateState();
}

class _MasterOnboardingGateState extends State<MasterOnboardingGate>
    with WidgetsBindingObserver {
  MasterOnboardingResult? _result;
  bool _checking = false;
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = widget.reconnects?.listen((_) => _retryIfNeeded());
    _check();
  }

  void _retryIfNeeded() {
    if (_result?.step == MasterOnboardingStep.retry) _check();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _retryIfNeeded();
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() {
      _checking = true;
    });
    MasterOnboardingResult result;
    try {
      result = await widget.check();
    } catch (_) {
      result = const MasterOnboardingResult(MasterOnboardingStep.retry);
    }
    if (!mounted) return;
    setState(() {
      _result = result;
      _checking = false;
    });
    if (result.step == MasterOnboardingStep.signIn) widget.onSignIn();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (!_checking && result?.step == MasterOnboardingStep.ready) {
      return widget.readyBuilder(context);
    }
    return PopScope(
      canPop: false,
      child: _checking ||
              result == null ||
              result.step == MasterOnboardingStep.signIn
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : switch (result.step) {
              MasterOnboardingStep.personal =>
                widget.personalBuilder(result.user!, _check),
              MasterOnboardingStep.professional =>
                widget.professionalBuilder(_check),
              _ => Scaffold(
                    body: Center(
                        child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(context.t.common.wentWrong,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _check, child: Text(context.t.common.retry)),
                  ]),
                ))),
            },
    );
  }
}
