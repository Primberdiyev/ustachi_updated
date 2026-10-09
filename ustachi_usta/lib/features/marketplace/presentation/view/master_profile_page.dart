import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_profile_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

class MasterProfilePage extends StatefulWidget {
  const MasterProfilePage({
    super.key,
    required this.masterId,
    this.onChoose,
    this.onChat,
  });

  final int masterId;

  final VoidCallback? onChoose;
  final VoidCallback? onChat;

  @override
  State<MasterProfilePage> createState() => _MasterProfilePageState();
}

class _MasterProfilePageState extends State<MasterProfilePage> {
  MasterProfileEntity? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result =
        await sl<MarketplaceRepository>().masterProfile(widget.masterId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isRight) {
        _profile = result.right;
        _error = null;
      } else {
        _error = result.left.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final p = _profile;

    return Scaffold(
      backgroundColor: colors.neutral.black7,
      appBar: AppBar(title: Text(context.t.masters.title)),
      bottomNavigationBar: (p == null || widget.onChoose == null)
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(ChizmaSpace.lg),
                child: Row(
                  children: [
                    if (widget.onChat != null) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onChat,
                          icon: const Icon(Icons.chat_bubble_outline_rounded,
                              size: 18),
                          label: Text(context.t.masters.write),
                        ),
                      ),
                      const SizedBox(width: ChizmaSpace.md),
                    ],
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: widget.onChoose,
                        child: Text(context.t.masters.chooseThis),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : p == null
              ? Center(child: Text(_error ?? context.t.masters.notFound))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      ChizmaSpace.lg,
                      ChizmaSpace.lg,
                      ChizmaSpace.lg,
                      ChizmaSpace.xxl + context.viewPaddingBottom,
                    ),
                    children: [
                      _Header(profile: p),
                      const SizedBox(height: ChizmaSpace.lg),
                      _Stats(profile: p),
                      if (p.bio.isNotEmpty) ...[
                        const SizedBox(height: ChizmaSpace.lg),
                        ChizmaEyebrow(context.t.masters.title),
                        const SizedBox(height: ChizmaSpace.sm),
                        ChizmaSheet(
                          child: Text(
                            p.bio,
                            style: context.text.body4
                                .copyWith(color: colors.neutral.textBody),
                          ),
                        ),
                      ],
                      if (p.workSamples.isNotEmpty) ...[
                        const SizedBox(height: ChizmaSpace.lg),
                        ChizmaEyebrow(context.t.masters.works),
                        const SizedBox(height: ChizmaSpace.sm),
                        _WorkSamples(samples: p.workSamples),
                      ],
                      const SizedBox(height: ChizmaSpace.lg),
                      ChizmaEyebrow(context.t.masters
                          .reviews(count: p.reviewsCount.toString())),
                      const SizedBox(height: ChizmaSpace.sm),
                      if (p.reviews.isEmpty)
                        ChizmaSheet(
                          child: Text(
                            context.t.masters.noReviews,
                            style: context.text.body5
                                .copyWith(color: colors.neutral.textMuted),
                          ),
                        )
                      else
                        for (final r in p.reviews) ...[
                          _ReviewTile(review: r),
                          const SizedBox(height: ChizmaSpace.sm),
                        ],
                    ],
                  ),
                ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});
  final MasterProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ChizmaSheet(
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: colors.neutral.surface2,
            backgroundImage:
                profile.photo != null ? NetworkImage(profile.photo!) : null,
            child: profile.photo == null
                ? Icon(Icons.person_outline,
                    size: 30, color: colors.neutral.textMuted)
                : null,
          ),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.displayName.isEmpty
                            ? context.t.masters.master
                            : profile.displayName,
                        style: context.text.h3
                            .copyWith(color: colors.neutral.textStrong),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (profile.isVerified) ...[
                      const SizedBox(width: ChizmaSpace.xs),
                      Icon(Icons.verified_rounded,
                          size: 18, color: colors.categorizedColor.info),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (profile.specialties.isNotEmpty)
                      profile.specialties.join(', ')
                    else if (profile.specialty != null)
                      profile.specialty!,
                    if (profile.experienceYears != null)
                      context.t.masters
                          .experienceYears(years: '${profile.experienceYears}'),
                  ].join(' · '),
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                ),
                if (profile.regionName != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: colors.neutral.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        [profile.regionName, profile.districtName]
                            .whereType<String>()
                            .join(', '),
                        style: context.text.body5
                            .copyWith(color: colors.neutral.textMuted),
                      ),
                    ],
                  ),
                ],
                if (profile.phoneNumber != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.phoneNumber!,
                    style: context.text.body4
                        .copyWith(color: colors.categorizedColor.primary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.profile});
  final MasterProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChizmaStatTile(
            label: context.t.masters.rating,
            value: profile.rating?.toStringAsFixed(1) ?? '—',
          ),
        ),
        const SizedBox(width: ChizmaSpace.md),
        Expanded(
          child: ChizmaStatTile(
            label: context.t.masters.completed,
            value: '${profile.completedOrders}',
          ),
        ),
        const SizedBox(width: ChizmaSpace.md),
        Expanded(
          child: ChizmaStatTile(
            label: context.t.masters.reviewsLabel,
            value: '${profile.reviewsCount}',
          ),
        ),
      ],
    );
  }
}

class _WorkSamples extends StatelessWidget {
  const _WorkSamples({required this.samples});
  final List<WorkSampleEntity> samples;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: samples.length,
        separatorBuilder: (_, __) => const SizedBox(width: ChizmaSpace.md),
        itemBuilder: (context, i) {
          final s = samples[i];
          return ClipRRect(
            borderRadius: BorderRadius.circular(ChizmaRadius.md),
            child: Container(
              width: 160,
              color: colors.neutral.surface2,
              child: Image.network(
                s.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: colors.neutral.textMuted),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final PublicReviewEntity review;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    return ChizmaSheet(
      padding: const EdgeInsets.all(ChizmaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: colors.categorizedColor.accent,
                ),
              const SizedBox(width: ChizmaSpace.sm),
              Expanded(
                child: Text(
                  review.clientName.isEmpty
                      ? context.t.masters.client
                      : review.clientName,
                  style: context.text.body5
                      .copyWith(color: colors.neutral.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (review.createdAt != null)
                Text(
                  review.createdAt!.formatDate,
                  style: context.text.label
                      .copyWith(color: colors.neutral.textMuted),
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: ChizmaSpace.sm),
            Text(
              review.comment,
              style:
                  context.text.body4.copyWith(color: colors.neutral.textBody),
            ),
          ],
          if (review.orderTitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              review.orderTitle,
              style:
                  context.text.label.copyWith(color: colors.neutral.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
