import 'dart:io';

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/utils/order_date.dart';
import 'package:ustachi/features/auth/domain/entities/auth_user_entity.dart';
import 'package:ustachi/features/auth/domain/entities/location_entity.dart';
import 'package:ustachi/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:ustachi/features/auth/domain/usecases/get_locations_usecases.dart';
import 'package:ustachi/features/auth/domain/usecases/update_me_usecase.dart';
import 'package:ustachi/features/profile/presentation/bloc/profile_bloc.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final _picker = ImagePicker();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  AuthUserEntity? _user;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;

  File? _photo;
  List<LocationEntity> _regions = const [];
  List<LocationEntity> _districts = const [];
  LocationEntity? _region;
  LocationEntity? _district;
  bool _loadingDistricts = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await sl<GetMeUseCase>()(NoParams());
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isRight) _user = result.right;
    });
    if (result.isLeft) {
      sl<SnackbarService>().showMessage(result.left.errorMessage);
    }
  }

  void applyRegion(LocationEntity region) {
    setState(() {
      _region = region;
      _district = null;
      _districts = const [];
    });
    _loadDistricts(region);
  }

  void applyDistrict(LocationEntity? district) =>
      setState(() => _district = district);

  Future<void> _startEditing() async {
    final user = _user;
    if (user == null) return;

    _nameCtrl.text = user.fullName ?? '';
    _addressCtrl.text = user.address ?? '';
    setState(() {
      _editing = true;
      _photo = null;
    });

    final regions = await sl<GetRegionsUseCase>()(NoParams());
    if (!mounted || regions.isLeft) return;
    setState(() {
      _regions = regions.right;
      _region = _regions.where((r) => r.id == user.regionId).firstOrNull;
    });
    if (_region != null) await _loadDistricts(_region!, keepId: user.districtId);
  }

  Future<void> _loadDistricts(LocationEntity region, {int? keepId}) async {
    setState(() => _loadingDistricts = true);
    final result = await sl<GetDistrictsUseCase>()(
      GetDistrictsParams(regionId: region.id),
    );
    if (!mounted) return;
    setState(() {
      _loadingDistricts = false;
      if (result.isRight) {
        _districts = result.right;
        _district = _districts.where((d) => d.id == keepId).firstOrNull;
      }
    });
  }

  Future<void> _pickPhoto() async {

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _photo = File(picked.path));
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      sl<SnackbarService>().showMessage(context.t.auth.profile.requiredName);
      return;
    }

    setState(() => _saving = true);
    final result = await sl<UpdateMeUseCase>()(UpdateMeParams(
      fullName: name,
      photoPath: _photo?.path,
      regionId: _region?.id,
      districtId: _district?.id,
      address: _addressCtrl.text.trim(),
    ));
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.isLeft) {
      sl<SnackbarService>().showMessage(result.left.errorMessage);
      return;
    }
    setState(() {
      _user = result.right;
      _editing = false;
      _photo = null;
    });

    context.read<ProfileBloc>().add(GetUserDataEvent());
    sl<SnackbarService>().showMessage(context.t.common.saved);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.profile;
    final colors = context.color;
    final user = _user;

    return Scaffold(
      backgroundColor: colors.neutral.bg,
      appBar: AppBar(
        title: Text(t.personalData),
        actions: [
          if (user != null && !_editing)
            IconButton(
              tooltip: uz(t.personal.edit),
              onPressed: _startEditing,
              icon: const Icon(Icons.edit_outlined),
            ),
          if (_editing)
            TextButton(
              onPressed: _saving ? null : () => setState(() => _editing = false),
              child: Text(context.t.common.cancel),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? ChizmaEmptyState(
                  icon: Icons.person_off_outlined,
                  title: t.personal.loadFailed,
                  message: '',
                  actionLabel: context.t.common.retry,
                  onAction: () {
                    setState(() => _loading = true);
                    _load();
                  },
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    ChizmaSpace.lg,
                    ChizmaSpace.md,
                    ChizmaSpace.lg,
                    ChizmaSpace.xxl,
                  ),
                  child: _editing
                      ? _EditForm(state: this, user: user)
                      : _ReadView(state: this, user: user),
                ),
    );
  }
}

class _ReadView extends StatelessWidget {
  const _ReadView({required this.state, required this.user});

  final _PersonalDataPageState state;
  final AuthUserEntity user;

  @override
  Widget build(BuildContext context) {
    final t = context.t.profile.personal;
    final colors = context.color;
    final empty = t.empty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Hero(user: user),
        const SizedBox(height: ChizmaSpace.xl),

        ChizmaEyebrow(t.sectionPersonal),
        const SizedBox(height: ChizmaSpace.sm),
        ChizmaSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Row(
                label: context.t.auth.profile.fullNameLabel,
                value: user.fullName,
                empty: empty,
              ),
              _Row(label: t.phoneLabel, value: user.phoneNumber, empty: empty),
              _Row(
                label: t.joinedLabel,
                value: user.dateJoined == null
                    ? null
                    : orderDateLabel(user.dateJoined),
                empty: empty,
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: ChizmaSpace.xs),
        Padding(
          padding: const EdgeInsets.only(left: ChizmaSpace.xs),
          child: Text(
            t.phoneNote,
            style: context.text.label.copyWith(color: colors.neutral.textMuted),
          ),
        ),
        const SizedBox(height: ChizmaSpace.lg),

        ChizmaEyebrow(t.sectionAddress),
        const SizedBox(height: ChizmaSpace.sm),
        ChizmaSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Row(
                label: context.t.auth.profile.regionLabel,
                value: user.regionName,
                empty: empty,
              ),
              _Row(
                label: context.t.auth.profile.districtLabel,
                value: user.districtName,
                empty: empty,
              ),
              _Row(
                label: context.t.auth.profile.addressLabel,
                value: user.address,
                empty: empty,
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: ChizmaSpace.xl),

        OutlinedButton.icon(
          onPressed: state._startEditing,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(t.edit),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.user});

  final AuthUserEntity user;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final name = (user.fullName ?? '').trim();
    final letter = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    return ChizmaSheet(
      child: Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: colors.neutral.surface2,
            backgroundImage:
                user.photo != null ? NetworkImage(user.photo!) : null,
            child: user.photo == null
                ? Text(
                    letter,
                    style: context.text.h3
                        .copyWith(color: colors.neutral.textMuted),
                  )
                : null,
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name.isEmpty ? context.t.profile.personal.empty : name,
                  style:
                      context.text.h4.copyWith(color: colors.neutral.textStrong),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.phoneNumber,
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

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.empty,
    this.last = false,
  });

  final String label;
  final String? value;
  final String empty;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final text = (value ?? '').trim();
    final isEmpty = text.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChizmaSpace.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 116,
                child: Text(
                  label,
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ),
              Expanded(
                child: Text(
                  isEmpty ? empty : text,
                  style: context.text.body5.copyWith(
                    color: isEmpty
                        ? colors.neutral.textMuted
                        : colors.neutral.textStrong,
                    fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!last) Divider(height: 1, color: colors.neutral.border),
      ],
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({required this.state, required this.user});

  final _PersonalDataPageState state;
  final AuthUserEntity user;

  @override
  Widget build(BuildContext context) {
    final t = context.t.auth.profile;
    final colors = context.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: GestureDetector(
            onTap: state._saving ? null : state._pickPhoto,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: colors.neutral.surface2,
                  backgroundImage: state._photo != null
                      ? FileImage(state._photo!)
                      : (user.photo != null
                          ? NetworkImage(user.photo!) as ImageProvider
                          : null),
                  child: state._photo == null && user.photo == null
                      ? Icon(Icons.add_a_photo_outlined,
                          color: colors.neutral.textMuted)
                      : null,
                ),
                const SizedBox(height: ChizmaSpace.sm),
                Text(
                  user.photo == null ? t.addPhoto : t.changePhoto,
                  style: context.text.body5
                      .copyWith(color: colors.categorizedColor.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: ChizmaSpace.xl),

        ChizmaEyebrow(context.t.profile.personal.sectionPersonal),
        const SizedBox(height: ChizmaSpace.sm),
        TextField(
          controller: state._nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: uz(t.fullNameLabel),
            hintText: uz(t.fullNameHint),
          ),
        ),
        const SizedBox(height: ChizmaSpace.lg),

        ChizmaEyebrow(context.t.profile.personal.sectionAddress),
        const SizedBox(height: ChizmaSpace.sm),
        DropdownButtonFormField<LocationEntity>(
          initialValue: state._region,
          isExpanded: true,
          menuMaxHeight: 360,
          decoration: InputDecoration(labelText: uz(t.regionLabel)),
          hint: Text(t.regionHint),
          items: [
            for (final r in state._regions)
              DropdownMenuItem(value: r, child: Text(r.name, maxLines: 1)),
          ],
          onChanged: state._saving
              ? null
              : (region) {
                  if (region == null) return;
                  state.applyRegion(region);
                },
        ),
        const SizedBox(height: ChizmaSpace.md),
        DropdownButtonFormField<LocationEntity>(
          initialValue: state._district,
          isExpanded: true,
          menuMaxHeight: 360,
          decoration: InputDecoration(
            labelText: uz(t.districtLabel),
            suffixIcon: state._loadingDistricts
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          hint: Text(t.districtHint),
          items: [
            for (final d in state._districts)
              DropdownMenuItem(value: d, child: Text(d.name, maxLines: 1)),
          ],
          onChanged: (state._districts.isEmpty || state._saving)
              ? null
              : state.applyDistrict,
        ),
        const SizedBox(height: ChizmaSpace.md),
        TextField(
          controller: state._addressCtrl,
          decoration: InputDecoration(
            labelText: uz(t.addressLabel),
            hintText: uz(t.addressHint),
          ),
        ),
        const SizedBox(height: ChizmaSpace.xl),

        ElevatedButton(
          onPressed: state._saving ? null : state._save,
          child: state._saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.t.common.save),
        ),
      ],
    );
  }
}
