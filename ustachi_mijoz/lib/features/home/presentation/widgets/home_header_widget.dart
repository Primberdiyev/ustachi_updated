import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/features/marketplace/presentation/view/notifications_page.dart';
import 'package:ustachi/features/profile/domain/models/user_model.dart';
import 'package:ustachi/features/profile/presentation/bloc/profile_bloc.dart';

class HomeHeaderWidget extends StatefulWidget {
  const HomeHeaderWidget({super.key});

  @override
  State<HomeHeaderWidget> createState() => _HomeHeaderWidgetState();
}

class _HomeHeaderWidgetState extends State<HomeHeaderWidget> {
  @override
  void initState() {
    super.initState();

    final profileBloc = context.read<ProfileBloc>();
    if (profileBloc.state.getUserDataStatus.isInitial) {
      profileBloc.add(GetUserDataEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {

        if (state.getUserDataStatus.isSuccess || state.userModel != null) {
          return _HeaderContent(
            userModel: state.userModel ?? UserModel.empty(),
          );
        }
        if (state.getUserDataStatus.isFailure) {
          return _HeaderError(
            onRetry: () => context.read<ProfileBloc>().add(GetUserDataEvent()),
          );
        }
        return const _HeaderPlaceholder();
      },
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({required this.userModel});

  final UserModel userModel;

  String get _initialLetter {
    final name = userModel.fullName.trim();
    return name.isEmpty ? '?' : name[0];
  }

  String get _firstName {
    final name = userModel.fullName.trim();
    return name.isEmpty ? UserModel.empty().fullName : name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;

    return Row(
      children: [
        _Avatar(photo: userModel.photo, letter: _initialLetter),
        const SizedBox(width: ChizmaSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const ChizmaEyebrow('Xush kelibsiz'),
              const SizedBox(height: 2),
              Text(
                '${context.t.home.hi}, $_firstName',
                style: context.text.h3.copyWith(
                  color: colors.neutral.textStrong,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const NotificationBell(),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photo, required this.letter});

  final String photo;
  final String letter;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final radius = BorderRadius.circular(ChizmaRadius.md);
    if (photo.isNotEmpty) {
      return Container(
        height: 44,
        width: 44,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: colors.neutral.border),
        ),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: photo,
          placeholder: (_, __) => const Center(
            child: CupertinoActivityIndicator(),
          ),
          errorWidget: (_, __, ___) => Center(
            child: Text(letter, style: context.text.h4),
          ),
        ),
      );
    }
    return Container(
      height: 44,
      width: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.categorizedColor.primary,
        borderRadius: radius,
      ),
      child: Text(
        letter.toUpperCase(),
        style: context.text.h4.copyWith(color: colors.neutral.white),
      ),
    );
  }
}

class _HeaderPlaceholder extends StatelessWidget {
  const _HeaderPlaceholder();

  @override
  Widget build(BuildContext context) {
    final grey = context.color.neutral.grey;
    return Row(
      children: [
        Container(
          margin: EdgeInsets.all(8),
          height: 54,
          width: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: grey.withValues(alpha: 0.25),
          ),
          child: const CupertinoActivityIndicator(),
        ),
        Expanded(
          child: Container(
            height: 16,
            margin: EdgeInsets.only(right: 80),
            decoration: BoxDecoration(
              color: grey.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderError extends StatelessWidget {
  const _HeaderError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final error = context.color.categorizedColor.error;
    return Row(
      children: [
        Container(
          margin: EdgeInsets.all(8),
          height: 54,
          width: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: error.withValues(alpha: 0.1),
          ),
          child: Icon(
            Icons.error_outline,
            color: error,
          ),
        ),
        Expanded(
          child: Text(
            context.t.common.wentWrong,
            style: context.text.h3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: onRetry,
          icon: Icon(
            Icons.refresh,
            color: context.color.categorizedColor.primary,
          ),
        ),
      ],
    );
  }
}
