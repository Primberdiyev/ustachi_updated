import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ustachi/core/components/base_button.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/orders/presentation/specialty_icons.dart';
import 'package:ustachi/features/profile/data/master_profile_api.dart';
import 'package:ustachi/features/profile/presentation/view/specialty_question_page.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class MasterProfessionalPage extends StatefulWidget {
  const MasterProfessionalPage(
      {super.key, this.isOnboarding = false, this.onSaved});

  final bool isOnboarding;
  final VoidCallback? onSaved;

  @override
  State<MasterProfessionalPage> createState() => _MasterProfessionalPageState();
}

class _MasterProfessionalPageState extends State<MasterProfessionalPage> {
  bool _allowExit = false;
  final _formKey = GlobalKey<FormState>();
  final _experienceCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _picker = ImagePicker();

  late final _api = MasterProfileApi(sl<Dio>());

  List<MasterSpecialty> _specialties = const [];
  List<MasterWorkSample> _samples = const [];

  final List<File> _pending = [];

  bool _profileSaved = false;

  final Set<int> _specialtyIds = <int>{};

  final Map<int, TextEditingController> _rateCtrls = {};

  TextEditingController _rateCtrl(int specialtyId) =>
      _rateCtrls.putIfAbsent(specialtyId, TextEditingController.new);


  final Map<int, TextEditingController> _variantRateCtrls = {};

  TextEditingController _variantRateCtrl(int variantId) =>
      _variantRateCtrls.putIfAbsent(variantId, TextEditingController.new);

  Map<({int specialtyId, int variantId}), int> get _variantRates {
    final out = <({int specialtyId, int variantId}), int>{};
    for (final specialty in _specialties) {
      if (!_specialtyIds.contains(specialty.id) ||
          !specialty.asksRatePerVariant) {
        continue;
      }
      for (final variant in specialty.variants) {
        final text = _variantRateCtrls[variant.id]
                ?.text
                .replaceAll(RegExp(r'[^0-9]'), '') ??
            '';
        final price = int.tryParse(text) ?? 0;
        if (price > 0) {
          out[(specialtyId: specialty.id, variantId: variant.id)] = price;
        }
      }
    }
    return out;
  }

  final Map<int, List<String>> _machineUnits = {};
  final Map<String, TextEditingController> _unitRateCtrls = {};

  TextEditingController _unitRateCtrl(int specialtyId, String unit) =>
      _unitRateCtrls.putIfAbsent(
          '$specialtyId|$unit', TextEditingController.new);

  void _toggleMachineUnit(int specialtyId, String unit) => setState(() {
        final units = _machineUnits.putIfAbsent(specialtyId, () => []);
        if (units.contains(unit)) {
          units.remove(unit);
        } else if (units.length < maxMasterUnits) {
          units.add(unit);
        }
      });

  Map<int, Map<String, int>> get _unitRates {
    final out = <int, Map<String, int>>{};
    for (final specialty in _specialties) {
      if (!_specialtyIds.contains(specialty.id) || !specialty.unitByMaster) {
        continue;
      }
      for (final unit in _machineUnits[specialty.id] ?? const <String>[]) {
        final text = _unitRateCtrls['${specialty.id}|$unit']
                ?.text
                .replaceAll(RegExp(r'[^0-9]'), '') ??
            '';
        final price = int.tryParse(text) ?? 0;
        if (price > 0) (out[specialty.id] ??= {})[unit] = price;
      }
    }
    return out;
  }

  final Map<int, TextEditingController> _noteCtrls = {};

  TextEditingController _noteCtrl(int specialtyId) =>
      _noteCtrls.putIfAbsent(specialtyId, TextEditingController.new);

  Map<int, String> get _notes => {
        for (final specialty in _specialties)
          if (_specialtyIds.contains(specialty.id) && specialty.noteByMaster)
            specialty.id: _noteCtrls[specialty.id]?.text.trim() ?? '',
      };

  Map<int, int> get _rates {
    final out = <int, int>{};
    for (final specialty in _specialties) {
      if (!_specialtyIds.contains(specialty.id) ||
          !specialty.asksRate ||
          specialty.asksRatePerVariant ||
          specialty.unitByMaster) {
        continue;
      }
      final text =
          _rateCtrls[specialty.id]?.text.replaceAll(RegExp(r'[^0-9]'), '') ??
              '';
      final price = int.tryParse(text) ?? 0;
      if (price > 0) out[specialty.id] = price;
    }
    return out;
  }

  bool _loading = true;
  bool _saving = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _experienceCtrl.dispose();
    _bioCtrl.dispose();
    for (final controller in _variantRateCtrls.values) {
      controller.dispose();
    }
    for (final controller in _rateCtrls.values) {
      controller.dispose();
    }
    for (final controller in _unitRateCtrls.values) {
      controller.dispose();
    }
    for (final controller in _noteCtrls.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _asksSomething(MasterSpecialty specialty) =>
      specialty.asksRate || specialty.noteByMaster;

  String _answer(MasterSpecialty specialty) {
    if (specialty.noteByMaster) {
      return _noteCtrls[specialty.id]?.text.trim() ?? '';
    }
    if (specialty.asksRatePerVariant) {
      final parts = [
        for (final variant in specialty.variants)
          if ((_variantRateCtrls[variant.id]?.text ?? '').isNotEmpty)
            '${variant.name} ${_variantRateCtrls[variant.id]!.text}',
      ];
      return parts.join(' · ');
    }
    final rate = _rateCtrls[specialty.id]?.text ?? '';
    if (rate.isEmpty) return '';
    return '$rate ${context.t.common.som} / ${specialty.unit}';
  }

  Map<int, int> _variantRatesOf(MasterSpecialty specialty) => {
        for (final variant in specialty.variants)
          if (int.tryParse(_variantRateCtrls[variant.id]?.text ?? '')
              case final price? when price > 0)
            variant.id: price,
      };

  Future<bool> _ask(MasterSpecialty specialty) async {
    final answers = await SpecialtyQuestionPage.show(
      context,
      specialty: specialty,
      rate: int.tryParse(_rateCtrls[specialty.id]?.text ?? ''),
      variantRates: _variantRatesOf(specialty),
      note: _noteCtrls[specialty.id]?.text,
    );
    if (answers == null || !mounted) return false;

    setState(() {
      if (answers.rate != null && answers.rate! > 0) {
        _rateCtrl(specialty.id).text = '${answers.rate}';
      }
      answers.variantRates.forEach((variantId, price) {
        _variantRateCtrl(variantId).text = '$price';
      });
      if (answers.note != null) {
        _noteCtrl(specialty.id).text = answers.note!;
      }
    });
    return true;
  }

  Future<void> _toggleSpecialty(MasterSpecialty specialty) async {
    if (_specialtyIds.contains(specialty.id)) {
      setState(() => _specialtyIds.remove(specialty.id));
      return;
    }

    if (_asksSomething(specialty) && !await _ask(specialty)) return;
    if (!mounted) return;
    setState(() => _specialtyIds.add(specialty.id));
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([_api.specialties(), _api.read()]);
    if (!mounted) return;

    final specialties = results[0] as List<MasterSpecialty>;
    final profile = results[1] as MasterProfileData?;

    setState(() {
      _loading = false;
      _specialties = specialties;
      if (profile != null) {
        _profileSaved = true;
        final ids = specialties.map((s) => s.id).toSet();
        _specialtyIds
          ..clear()
          ..addAll(profile.specialties.map((s) => s.id).where(ids.contains));
        if (_specialtyIds.isEmpty && ids.contains(profile.specialtyId)) {
          _specialtyIds.add(profile.specialtyId!);
        }
        _experienceCtrl.text = profile.experienceYears?.toString() ?? '';
        _bioCtrl.text = profile.bio;
        _samples = profile.workSamples;
        profile.rateBySpecialty.forEach((id, price) {
          _rateCtrl(id).text = price.toString();
        });
        profile.rateByVariant.forEach((variantId, price) {
          _variantRateCtrl(variantId).text = price.toString();
        });
        profile.specialtyNotes.forEach((id, text) {
          _noteCtrl(id).text = text;
        });

        final machineIds = {
          for (final s in specialties)
            if (s.unitByMaster) s.id,
        };
        for (final rate in profile.specialtyRates) {
          if (!machineIds.contains(rate.specialtyId) ||
              !masterUnits.contains(rate.unit)) {
            continue;
          }
          final units = _machineUnits.putIfAbsent(rate.specialtyId, () => []);
          if (!units.contains(rate.unit) && units.length < maxMasterUnits) {
            units.add(rate.unit);
          }
          _unitRateCtrl(rate.specialtyId, rate.unit).text =
              rate.price.toString();
        }
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_specialtyIds.isEmpty) {
      sl<SnackbarService>().showMessage(context.t.professional.pickSpecialty);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final error = await _api.save(
      specialtyIds: [
        for (final specialty in _specialties)
          if (_specialtyIds.contains(specialty.id)) specialty.id,
      ],
      experienceYears: int.parse(_experienceCtrl.text.trim()),
      bio: _bioCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      sl<SnackbarService>().showMessage(error);
      return;
    }

    final rateError = await _api.saveRates(
      _rates,
      variantRates: _variantRates,
      unitRates: _unitRates,
    );
    if (!mounted) return;
    if (rateError != null) {
      sl<SnackbarService>().showMessage(rateError);
    }

    final noteError = await _api.saveNotes(_notes);
    if (!mounted) return;
    if (noteError != null) {
      sl<SnackbarService>().showMessage(noteError);
    }

    _profileSaved = true;
    final uploadError = await _uploadPending();
    if (!mounted) return;

    sl<SnackbarService>().showMessage(
      uploadError ?? context.t.common.saved,
    );
    if (widget.onSaved != null) {
      widget.onSaved!();
    } else {
      setState(() => _allowExit = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(true);
      });
    }
  }

  Future<void> _addSample() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1440,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    if (!_profileSaved) {
      setState(() => _pending.add(File(picked.path)));
      return;
    }

    setState(() => _uploading = true);
    final error = await _api.addWorkSample(picked.path);
    if (!mounted) return;

    if (error != null) {
      setState(() => _uploading = false);
      sl<SnackbarService>().showMessage(error);
      return;
    }
    final profile = await _api.read();
    if (!mounted) return;
    setState(() {
      _uploading = false;
      _samples = profile?.workSamples ?? _samples;
    });
  }

  void _removePending(File file) =>
      setState(() => _pending.removeWhere((f) => f.path == file.path));

  Future<String?> _uploadPending() async {
    if (_pending.isEmpty) return null;
    String? firstError;
    for (final file in List<File>.from(_pending)) {
      final error = await _api.addWorkSample(file.path);
      if (error == null) {
        _pending.removeWhere((f) => f.path == file.path);
      } else {
        firstError ??= error;
      }
    }
    return firstError;
  }

  Future<void> _removeSample(MasterWorkSample sample) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.t.professional.deleteSampleTitle),
        content: Text(context.t.professional.deleteSampleMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.t.common.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final removed = await _api.deleteWorkSample(sample.id);
    if (!mounted) return;
    if (!removed) {
      sl<SnackbarService>().showMessage(context.t.professional.deleteFailed);
      return;
    }
    setState(() {
      _samples = _samples.where((s) => s.id != sample.id).toList();
    });
  }

  Widget _specialtyChip(MasterSpecialty specialty) {
    final colors = context.color;
    final selected = _specialtyIds.contains(specialty.id);
    return FilterChip(
      label: Text(specialty.name),
      selected: selected,
      onSelected: _saving
          ? null
          : (value) => setState(() {
                if (value) {
                  _specialtyIds.add(specialty.id);
                } else {
                  _specialtyIds.remove(specialty.id);
                }
              }),
      labelStyle: context.text.body4.copyWith(
        color: selected
            ? colors.categorizedColor.onPrimary
            : colors.neutral.textBody,
      ),
      selectedColor: colors.categorizedColor.primary,
      backgroundColor: colors.neutral.surface,
      side: BorderSide(
        color:
            selected ? colors.categorizedColor.primary : colors.neutral.border,
      ),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.professional;

    return PopScope(
      canPop: !widget.isOnboarding || _allowExit,
      child: Scaffold(
        backgroundColor: colors.neutral.bg,
        appBar: AppBar(
          title: Text(t.title),
          automaticallyImplyLeading: !widget.isOnboarding,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      ChizmaSpace.lg,
                      ChizmaSpace.lg,
                      ChizmaSpace.lg,
                      ChizmaSpace.xxl,
                    ),
                    children: [
                      if (widget.isOnboarding) ...[
                        Text(
                          t.headline,
                          style: context.text.h3
                              .copyWith(color: colors.neutral.textStrong),
                        ),
                        const SizedBox(height: ChizmaSpace.xs),
                        Text(
                          t.headlineHint,
                          style: context.text.body5
                              .copyWith(color: colors.neutral.textMuted),
                        ),
                        const SizedBox(height: ChizmaSpace.xl),
                      ],
                      ChizmaSectionHeader(title: t.specialty),
                      const SizedBox(height: ChizmaSpace.sm),
                      if (_specialties.isEmpty)
                        Text(
                          t.specialtyLoadFailed,
                          style: context.text.body5
                              .copyWith(color: colors.categorizedColor.error),
                        )
                      else ...[
                        Text(
                          t.specialtyHint,
                          style: context.text.body5
                              .copyWith(color: colors.neutral.textMuted),
                        ),
                        const SizedBox(height: ChizmaSpace.sm),
                        for (final specialty in _specialties) ...[
                          if (!specialty.isTexnika)
                            _SpecialtyCard(
                              specialty: specialty,
                              selected: _specialtyIds.contains(specialty.id),
                              answer: _specialtyIds.contains(specialty.id)
                                  ? _answer(specialty)
                                  : '',
                              enabled: !_saving,
                              onTap: () => _toggleSpecialty(specialty),
                              onEdit: _asksSomething(specialty)
                                  ? () => _ask(specialty)
                                  : null,
                            ),
                          if (!specialty.isTexnika)
                            const SizedBox(height: ChizmaSpace.sm),
                        ],

                        if (_specialties.any((s) => s.isTexnika)) ...[
                          const SizedBox(height: ChizmaSpace.xl),
                          const ChizmaSectionHeader(title: 'Polvon texnika'),
                          const SizedBox(height: ChizmaSpace.sm),
                          Text(
                            'Texnikangiz bo\'lsa — qaysilari borligini belgilang.',
                            style: context.text.body5
                                .copyWith(color: colors.neutral.textMuted),
                          ),
                          const SizedBox(height: ChizmaSpace.sm),
                          Wrap(
                            spacing: ChizmaSpace.xs,
                            runSpacing: ChizmaSpace.xs,
                            children: [
                              for (final specialty in _specialties)
                                if (specialty.isTexnika)
                                  _specialtyChip(specialty),
                            ],
                          ),
                          for (final specialty in _specialties)
                            if (specialty.isTexnika &&
                                specialty.unitByMaster &&
                                _specialtyIds.contains(specialty.id)) ...[
                              const SizedBox(height: ChizmaSpace.lg),
                              MachineRateFields(
                                specialty: specialty,
                                units: _machineUnits[specialty.id] ?? const [],
                                onToggleUnit: (unit) =>
                                    _toggleMachineUnit(specialty.id, unit),
                                controllerFor: (unit) =>
                                    _unitRateCtrl(specialty.id, unit),
                                enabled: !_saving,
                              ),
                            ],
                        ],
                      ],
                      const SizedBox(height: ChizmaSpace.xl),
                      ChizmaSectionHeader(title: t.experienceQuestion),
                      const SizedBox(height: ChizmaSpace.sm),
                      TextFormField(
                        controller: _experienceCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        enabled: !_saving,
                        decoration: InputDecoration(
                          hintText: t.experienceHint,
                          counterText: '',
                        ),
                        validator: (value) {
                          final years = int.tryParse((value ?? '').trim());
                          if (years == null) return t.experienceRequired;
                          if (years < 0 || years > 70) {
                            return t.experienceRange;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: ChizmaSpace.lg),
                      ChizmaSectionHeader(title: t.aboutLabel),
                      const SizedBox(height: ChizmaSpace.sm),
                      TextFormField(
                        controller: _bioCtrl,
                        maxLines: 4,
                        maxLength: 500,
                        enabled: !_saving,
                        decoration: InputDecoration(hintText: t.aboutHint),
                      ),
                      const SizedBox(height: ChizmaSpace.lg),
                      ChizmaSectionHeader(title: t.works),
                      const SizedBox(height: ChizmaSpace.xs),
                      Text(
                        t.worksHint,
                        style: context.text.body5
                            .copyWith(color: colors.neutral.textMuted),
                      ),
                      const SizedBox(height: ChizmaSpace.md),
                      _WorkSamples(
                        samples: _samples,
                        pending: _pending,
                        uploading: _uploading,
                        onAdd: _uploading ? null : _addSample,
                        onRemove: _removeSample,
                        onRemovePending: _removePending,
                      ),
                      const SizedBox(height: ChizmaSpace.xxl),
                      BaseButton(
                        onPressed: _saving ? null : _save,
                        isLoading: _saving,
                        text: widget.isOnboarding
                            ? context.t.auth.phone.continueBtn
                            : context.t.common.save,
                        backgroundColor: colors.categorizedColor.primary,
                        textColor: colors.neutral.white,
                      ),
                      if (widget.isOnboarding) ...[
                        const SizedBox(height: ChizmaSpace.sm),
                        TextButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.of(context).pop(false),
                          child: Text(
                            context.t.auth.profile.skip,
                            style: context.text.body3
                                .copyWith(color: colors.neutral.textMuted),
                          ),
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

class _WorkSamples extends StatelessWidget {
  const _WorkSamples({
    required this.samples,
    required this.pending,
    required this.uploading,
    required this.onAdd,
    required this.onRemove,
    required this.onRemovePending,
  });

  final List<MasterWorkSample> samples;

  final List<File> pending;

  final bool uploading;
  final VoidCallback? onAdd;
  final void Function(MasterWorkSample sample) onRemove;
  final void Function(File file) onRemovePending;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: samples.length + pending.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: ChizmaSpace.sm),
        itemBuilder: (context, index) {
          if (index == samples.length + pending.length) {
            return InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(ChizmaRadius.md),
              child: Container(
                width: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.neutral.surface,
                  borderRadius: BorderRadius.circular(ChizmaRadius.md),
                  border: Border.all(color: colors.neutral.border),
                ),
                child: uploading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: colors.neutral.textMuted),
                          const SizedBox(height: ChizmaSpace.xs),
                          Text(
                            context.t.auth.profile.addPhoto,
                            style: context.text.body5
                                .copyWith(color: colors.neutral.textMuted),
                          ),
                        ],
                      ),
              ),
            );
          }

          if (index >= samples.length) {
            final file = pending[index - samples.length];
            return _Thumb(
              image: Image.file(
                file,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
              badge: 'kutmoqda',
              onRemove: () => onRemovePending(file),
            );
          }

          final sample = samples[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(ChizmaRadius.md),
                child: Image.network(
                  sample.imageUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 110,
                    height: 110,
                    color: colors.neutral.surface2,
                    child: Icon(Icons.broken_image_outlined,
                        color: colors.neutral.textMuted),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () => onRemove(sample),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.image, required this.onRemove, this.badge});

  final Widget image;
  final VoidCallback onRemove;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(ChizmaRadius.md),
          child: image,
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 15, color: Colors.white),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(ChizmaRadius.sm),
              ),
              child: Text(
                badge!,
                style: context.text.body5.copyWith(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class SpecialtyRateField extends StatelessWidget {
  const SpecialtyRateField({
    super.key,
    required this.specialty,
    required this.controller,
    required this.enabled,
  });

  final MasterSpecialty specialty;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final question = specialty.unitQuestion.isNotEmpty
        ? specialty.unitQuestion
        : '${specialty.name} — bir ${specialty.unit} qancha?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: context.text.body4.copyWith(color: colors.neutral.textStrong),
        ),
        const SizedBox(height: ChizmaSpace.sm),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Text(
                'so\'m',
                style: context.text.body5
                    .copyWith(color: colors.neutral.textMuted),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0),
            suffixText: '/ ${specialty.unit}',
            suffixStyle:
                context.text.body5.copyWith(color: colors.neutral.textMuted),
          ),
        ),
      ],
    );
  }
}

class SpecialtyNoteField extends StatelessWidget {
  const SpecialtyNoteField({
    super.key,
    required this.specialty,
    required this.controller,
    required this.enabled,
  });

  final MasterSpecialty specialty;
  final TextEditingController controller;
  final bool enabled;

  static const int maxLength = 1000;

  static String exampleFor(String code) => switch (code) {
        'tom' => 'Masalan: sasna + shifer — 1 m² uchun … so\'m, '
            'profnastil — 1 m² uchun … so\'m.',
        'santexnik' => 'Masalan: radiator o\'rnatish — 1 dona … so\'m, '
            'issiq pol — 1 m² … so\'m.',
        'darvoza' => 'Masalan: temir darvoza — 1 m² … so\'m, '
            'panjara — 1 m² … so\'m.',
        'payvand' => 'Masalan: payvand — 1 metr … so\'m, '
            'kunlik ish — … so\'m.',
        'hammom' => 'Masalan: dush kabinasi o\'rnatish — … so\'m, '
            'eskisini olib tashlash — … so\'m.',
        _ => 'Qanday ishlarni qilasiz va narxi qancha — yozing.',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final question = specialty.unitQuestion.isNotEmpty
        ? specialty.unitQuestion
        : '${specialty.name} — qanday ishlarni necha pulga qilasiz?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: context.text.body4.copyWith(color: colors.neutral.textStrong),
        ),
        const SizedBox(height: ChizmaSpace.xs),
        Text(
          'Mijoz buni profilingizda ko\'radi.',
          style: context.text.body5.copyWith(color: colors.neutral.textMuted),
        ),
        const SizedBox(height: ChizmaSpace.sm),
        TextFormField(
          controller: controller,
          enabled: enabled,
          minLines: 3,
          maxLines: 6,
          maxLength: maxLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: uz(exampleFor(specialty.code))),
        ),
      ],
    );
  }
}

class MachineRateFields extends StatelessWidget {
  const MachineRateFields({
    super.key,
    required this.specialty,
    required this.units,
    required this.onToggleUnit,
    required this.controllerFor,
    required this.enabled,
  });

  final MasterSpecialty specialty;

  final List<String> units;
  final ValueChanged<String> onToggleUnit;
  final TextEditingController Function(String unit) controllerFor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final full = units.length >= maxMasterUnits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${specialty.name} — siz qanday ishlaysiz?',
          style: context.text.body4.copyWith(color: colors.neutral.textStrong),
        ),
        const SizedBox(height: 4),
        Text(
          'Narxni qaysi hisobda olishingizni tanlang. Ish soatiga yoki '
          'metriga bo\'lib, masofaga ham bog\'liq bo\'lsa — ikkita birlik '
          'tanlashingiz mumkin (masalan: soat + km).',
          style: context.text.body5.copyWith(color: colors.neutral.textMuted),
        ),
        const SizedBox(height: ChizmaSpace.sm),
        Wrap(
          spacing: ChizmaSpace.xs,
          runSpacing: ChizmaSpace.xs,
          children: [
            for (final unit in masterUnits)
              FilterChip(
                label: Text(unit),
                selected: units.contains(unit),

                onSelected: !enabled || (full && !units.contains(unit))
                    ? null
                    : (_) => onToggleUnit(unit),
                labelStyle: context.text.body5.copyWith(
                  color: units.contains(unit)
                      ? colors.categorizedColor.onPrimary
                      : colors.neutral.textBody,
                ),
                selectedColor: primary,
                backgroundColor: colors.neutral.surface,
                side: BorderSide(
                  color: units.contains(unit) ? primary : colors.neutral.border,
                ),
                showCheckmark: false,
              ),
          ],
        ),
        for (final unit in units) ...[
          const SizedBox(height: ChizmaSpace.sm),
          TextFormField(
            controller: controllerFor(unit),
            enabled: enabled,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '0',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: Text(
                  'so\'m',
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),

              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text(
                  '/ $unit',
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ),
              suffixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
          ),
        ],
      ],
    );
  }
}

class SpecialtyVariantRateFields extends StatelessWidget {
  const SpecialtyVariantRateFields({
    super.key,
    required this.specialty,
    required this.controllerFor,
    required this.enabled,
  });

  final MasterSpecialty specialty;

  final TextEditingController Function(int variantId) controllerFor;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${specialty.name} — qaysi turini qanchadan olasiz?',
          style: context.text.body4.copyWith(color: colors.neutral.textStrong),
        ),
        const SizedBox(height: 4),
        Text(
          'Faqat o\'zingiz qiladigan turlarni to\'ldiring. Bu — ISH HAQINGIZ; '
          'material narxi mijozga alohida ko\'rsatiladi.',
          style: context.text.body5.copyWith(color: colors.neutral.textMuted),
        ),
        for (final variant in specialty.variants) ...[
          const SizedBox(height: ChizmaSpace.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      variant.name,
                      style: context.text.body5.copyWith(
                        color: colors.neutral.textStrong,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (variant.size.isNotEmpty)
                      Text(
                        variant.size,
                        style: context.text.label
                            .copyWith(color: colors.neutral.textMuted),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: ChizmaSpace.md),
              SizedBox(
                width: 170,
                child: TextFormField(
                  controller: controllerFor(variant.id),
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: '0',
                    isDense: true,
                    suffixText: '/ ${specialty.unit}',
                    suffixStyle: context.text.label
                        .copyWith(color: colors.neutral.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SpecialtyCard extends StatelessWidget {
  const _SpecialtyCard({
    required this.specialty,
    required this.selected,
    required this.answer,
    required this.enabled,
    required this.onTap,
    this.onEdit,
  });

  final MasterSpecialty specialty;
  final bool selected;
  final String answer;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;

    return Material(
      color:
          selected ? primary.withValues(alpha: 0.06) : colors.neutral.surface,
      borderRadius: BorderRadius.circular(ChizmaRadius.lg),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(ChizmaRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(ChizmaSpace.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ChizmaRadius.lg),
            border: Border.all(
              color: selected ? primary : colors.neutral.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withValues(alpha: 0.14)
                      : colors.neutral.surface2,
                  borderRadius: BorderRadius.circular(ChizmaRadius.md),
                ),
                child: Icon(
                  specialtyIcon(specialty.code),
                  size: 22,
                  color: selected ? primary : colors.neutral.textMuted,
                ),
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      specialty.name,
                      style: context.text.body3.copyWith(
                        color: colors.neutral.textStrong,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (selected && answer.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        answer,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.label
                            .copyWith(color: colors.neutral.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected && onEdit != null)
                TextButton(
                  onPressed: enabled ? onEdit : null,
                  child: Text(
                    context.t.common.edit,
                    style: context.text.label.copyWith(color: primary),
                  ),
                ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? primary : colors.neutral.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
