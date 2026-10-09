import 'dart:io';

import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ustachi/core/components/base_button.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/usecases/usecase.dart';
import 'package:ustachi/features/auth/domain/entities/location_entity.dart';
import 'package:ustachi/features/auth/domain/usecases/get_locations_usecases.dart';
import 'package:ustachi/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:ustachi/features/auth/presentation/router/auth_router.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({
    super.key,
    required this.router,
  });

  final AuthRouter router;

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _picker = ImagePicker();

  File? _photo;

  List<LocationEntity> _regions = const [];
  List<LocationEntity> _districts = const [];
  LocationEntity? _region;
  LocationEntity? _district;
  bool _loadingRegions = true;
  bool _loadingDistricts = false;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    final result = await sl<GetRegionsUseCase>()(NoParams());
    if (!mounted) return;
    setState(() {
      _loadingRegions = false;
      if (result.isRight) _regions = result.right;
    });
    if (result.isLeft) {
      sl<SnackbarService>().showMessage(result.left.errorMessage);
    }
  }

  Future<void> _onRegionChanged(LocationEntity? region) async {
    setState(() {
      _region = region;
      _district = null;
      _districts = const [];
      _loadingDistricts = region != null;
    });
    if (region == null) return;

    final result = await sl<GetDistrictsUseCase>()(
      GetDistrictsParams(regionId: region.id),
    );
    if (!mounted) return;
    setState(() {
      _loadingDistricts = false;
      if (result.isRight) _districts = result.right;
    });
    if (result.isLeft) {
      sl<SnackbarService>().showMessage(result.left.errorMessage);
    }
  }

  Future<void> _pickPhoto() async {

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() => _photo = File(picked.path));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          AuthProfileSubmitted(
            fullName: _nameController.text.trim(),
            photoPath: _photo?.path,
            regionId: _region?.id,
            districtId: _district?.id,
            address: _addressController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final t = context.t.auth.profile;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.updateProfileStatus != current.updateProfileStatus,
      listener: (context, state) {
        if (state.updateProfileStatus.isSuccess) {
          widget.router.replaceWithHome(context);
          return;
        }

        if (state.updateProfileStatus.isFailure && state.failure != null) {
          sl<SnackbarService>().showMessage(state.failure!.errorMessage);
        }
      },
      builder: (context, state) {
        final isSaving = state.updateProfileStatus.isLoading;

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
                    Text(
                      t.title,
                      style: context.text.h1.copyWith(
                        color: colors.neutral.textStrong,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.subtitle,
                      style: context.text.body2.copyWith(
                        color: colors.neutral.textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: _PhotoPicker(
                        photo: _photo,
                        onTap: isSaving ? null : _pickPhoto,
                        label: _photo == null ? t.addPhoto : t.changePhoto,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(t.fullNameLabel, style: context.text.h4),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 100,
                      autofocus: true,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return t.requiredName;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: uz(t.fullNameHint),
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: context.text.body1,
                    ),
                    const SizedBox(height: 20),

                    Text(t.regionLabel, style: context.text.h4),
                    const SizedBox(height: 8),
                    _LocationDropdown(
                      value: _region,
                      items: _regions,
                      hint: t.regionHint,
                      isLoading: _loadingRegions,
                      enabled: !isSaving,
                      validatorMessage: t.requiredRegion,
                      onChanged: _onRegionChanged,
                    ),
                    const SizedBox(height: 20),
                    Text(t.districtLabel, style: context.text.h4),
                    const SizedBox(height: 8),
                    _LocationDropdown(
                      value: _district,
                      items: _districts,
                      hint: t.districtHint,
                      isLoading: _loadingDistricts,

                      enabled: !isSaving && _region != null,
                      validatorMessage: t.requiredDistrict,
                      onChanged: (value) => setState(() => _district = value),
                    ),
                    const SizedBox(height: 20),
                    Text(t.addressLabel, style: context.text.h4),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      maxLength: 255,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: uz(t.addressHint),
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: context.text.body1,
                      onFieldSubmitted: (_) => isSaving ? null : _submit(),
                    ),
                    const SizedBox(height: 24),
                    BaseButton.primary(
                      text: t.saveBtn,
                      isLoading: isSaving,
                      onPressed: isSaving ? null : _submit,
                      backgroundColor: colors.categorizedColor.primary,
                      textColor: colors.neutral.white,
                      textStyle: context.text.body2.copyWith(
                        color: colors.neutral.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(

                      onPressed: isSaving
                          ? null
                          : () => widget.router.replaceWithHome(context),
                      child: Text(
                        t.skip,
                        style: context.text.body3.copyWith(
                          color: colors.neutral.textMuted,
                        ),
                      ),
                    ),
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

class _LocationDropdown extends StatelessWidget {
  const _LocationDropdown({
    required this.value,
    required this.items,
    required this.hint,
    required this.isLoading,
    required this.enabled,
    required this.validatorMessage,
    required this.onChanged,
  });

  final LocationEntity? value;
  final List<LocationEntity> items;
  final String hint;
  final bool isLoading;
  final bool enabled;
  final String validatorMessage;
  final ValueChanged<LocationEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<LocationEntity>(
      initialValue: value,
      isExpanded: true,

      menuMaxHeight: 360,
      items: items
          .map(
            (e) => DropdownMenuItem<LocationEntity>(
              value: e,
              child: Text(
                e.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.body1,
              ),
            ),
          )
          .toList(),
      onChanged: (enabled && !isLoading) ? onChanged : null,
      validator: (selected) => selected == null ? validatorMessage : null,
      hint: Text(
        hint,
        style: context.text.body1.copyWith(
          color: context.color.neutral.textMuted,
        ),
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photo,
    required this.onTap,
    required this.label,
  });

  final File? photo;
  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colors.neutral.bg,
              shape: BoxShape.circle,
              border: Border.all(color: colors.neutral.border),
              image: photo == null
                  ? null
                  : DecorationImage(
                      image: FileImage(photo!),
                      fit: BoxFit.cover,
                    ),
            ),
            child: photo != null
                ? null
                : Icon(
                    Icons.add_a_photo_outlined,
                    color: colors.neutral.textMuted,
                    size: 28,
                  ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onTap,
          child: Text(
            label,
            style: context.text.body3.copyWith(
              color: colors.categorizedColor.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
