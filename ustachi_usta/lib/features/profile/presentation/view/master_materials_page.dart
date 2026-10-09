import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class MasterMaterialsPage extends StatefulWidget {
  const MasterMaterialsPage({super.key});

  @override
  State<MasterMaterialsPage> createState() => _MasterMaterialsPageState();
}

class _MasterMaterialsPageState extends State<MasterMaterialsPage> {
  late final _api = MasterProfileApi(sl<Dio>());

  MasterMaterials _materials = MasterMaterials.all;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    final profile = await _api.read();
    if (!mounted || profile == null) return;
    setState(() => _materials = profile.materials);
  }

  void _toggleMaterial(MasterMaterials next) {
    if (!next.anyOn) {
      sl<SnackbarService>().showMessage(context.t.materials.allOff);
      return;
    }
    setState(() => _materials = next);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final error = await _api.saveMaterials(_materials);
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      sl<SnackbarService>().showMessage(error);
      return;
    }

    sl<SnackbarService>().showMessage(context.t.common.saved);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(title: Text(context.t.materials.title)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(ChizmaSpace.lg),
        child: FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: colors.categorizedColor.primary,
          ),
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(context.t.common.save),
        ),
      ),
      body: ChizmaPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MaterialCard(
              label: context.t.calculatePage.plastic,
              imageAsset: 'assets/images/plast.png',
              enabled: !_saving,
              works: _materials.plastic,
              onWorksChanged: (v) =>
                  _toggleMaterial(_materials.copyWith(plastic: v)),
            ),
            const SizedBox(height: ChizmaSpace.md),
            _MaterialCard(
              label: context.t.calculatePage.aluminium,
              imageAsset: 'assets/images/alumin.png',
              enabled: !_saving,
              works: _materials.aluminium,
              onWorksChanged: (v) =>
                  _toggleMaterial(_materials.copyWith(aluminium: v)),
            ),
            const SizedBox(height: ChizmaSpace.md),
            _MaterialCard(
              label: context.t.calculatePage.termo,
              imageAsset: 'assets/images/termo.png',
              enabled: !_saving,
              works: _materials.termo,
              onWorksChanged: (v) =>
                  _toggleMaterial(_materials.copyWith(termo: v)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({
    required this.label,
    required this.imageAsset,
    required this.enabled,
    required this.works,
    required this.onWorksChanged,
  });

  final String label;
  final String imageAsset;
  final bool enabled;
  final bool works;
  final ValueChanged<bool> onWorksChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return ChizmaSheet(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ChizmaRadius.md),
            child: Container(
              width: 72,
              height: 72,
              color: Colors.white,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.window_outlined,
                    color: colors.neutral.textMuted),
              ),
            ),
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: context.text.h4.copyWith(
                    color: works
                        ? colors.neutral.textStrong
                        : colors.neutral.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  works ? context.t.materials.on : context.t.materials.off,
                  style: context.text.label.copyWith(
                    color: works
                        ? colors.neutral.textMuted
                        : colors.categorizedColor.warning,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: works,
            onChanged: enabled ? onWorksChanged : null,
          ),
        ],
      ),
    );
  }
}
