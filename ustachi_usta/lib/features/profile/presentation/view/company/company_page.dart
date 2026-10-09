import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ustachi/core/design_sytem/responsive.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final _nameCtrl = TextEditingController();
  final _picker = ImagePicker();

  late final _api = MasterProfileApi(sl<Dio>());

  String? _logoUrl;
  File? _pickedLogo;
  bool _loading = true;
  bool _saving = false;
  String _savedName = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await _api.read();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (profile != null) {
        _savedName = profile.companyName;
        _nameCtrl.text = profile.companyName;
        _logoUrl = profile.companyLogoUrl;
      }
    });
  }

  bool get _dirty => _pickedLogo != null || _nameCtrl.text.trim() != _savedName;

  Future<void> _pickLogo() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;
    setState(() => _pickedLogo = File(picked.path));
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final name = _nameCtrl.text.trim();
    final error = await _api.saveCompany(
      name: name,
      logoPath: _pickedLogo?.path,
    );
    if (!mounted) return;

    if (error != null) {
      setState(() => _saving = false);
      sl<SnackbarService>().showMessage(error);
      return;
    }

    final profile = _pickedLogo != null ? await _api.read() : null;
    if (!mounted) return;
    setState(() {
      _saving = false;
      _savedName = name;
      _pickedLogo = null;
      if (profile != null) _logoUrl = profile.companyLogoUrl;
    });
    sl<SnackbarService>().showMessage(context.t.common.saved);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.company;

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(title: Text(t.title)),
      bottomNavigationBar: _dirty && !_loading
          ? SafeArea(
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
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ChizmaPageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompanyCard(
                    logoUrl: _logoUrl,
                    pickedLogo: _pickedLogo,
                    nameController: _nameCtrl,
                    onPickLogo: _saving ? null : _pickLogo,
                    onNameChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({
    required this.logoUrl,
    required this.pickedLogo,
    required this.nameController,
    required this.onPickLogo,
    required this.onNameChanged,
  });

  final String? logoUrl;
  final File? pickedLogo;
  final TextEditingController nameController;
  final VoidCallback? onPickLogo;
  final VoidCallback onNameChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.company;

    return ChizmaSheet(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onPickLogo,
            borderRadius: BorderRadius.circular(ChizmaRadius.lg),
            child: _Logo(logoUrl: logoUrl, picked: pickedLogo),
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  onChanged: (_) => onNameChanged(),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 120,
                  style: context.text.h4
                      .copyWith(color: colors.neutral.textStrong),
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: '',
                    hintText: uz(t.nameHint),
                    labelText: uz(t.nameLabel),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: ChizmaSpace.xs),
                Text(
                  t.nameNote,
                  style: context.text.body5
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

class _Logo extends StatelessWidget {
  const _Logo({required this.logoUrl, required this.picked});

  final String? logoUrl;
  final File? picked;

  static const _size = 64.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    final Widget content;
    if (picked != null) {
      content = Image.file(picked!, fit: BoxFit.cover);
    } else if (logoUrl != null) {
      content = Image.network(
        logoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    } else {
      content = _placeholder(context);
    }

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: colors.neutral.surface2,
        borderRadius: BorderRadius.circular(ChizmaRadius.lg),
        border: Border.all(color: colors.neutral.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }

  Widget _placeholder(BuildContext context) {
    final colors = context.color;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 22, color: colors.neutral.textMuted),
        const SizedBox(height: 2),
        Text(
          context.t.company.logoHint,
          textAlign: TextAlign.center,
          style: context.text.body5.copyWith(
            color: colors.neutral.textMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
