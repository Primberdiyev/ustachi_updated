import 'dart:async';
import 'package:ustachi/core/design_sytem/widgets/list_loading_placeholder.dart';
import 'package:ustachi/features/marketplace/presentation/widgets/master_rates_block.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/utils/localization/specialty_name_helper.dart';
import 'package:ustachi/features/marketplace/domain/entities/master_profile_entity.dart';
import 'package:ustachi/features/marketplace/domain/repositories/marketplace_repository.dart';

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

  bool _fetching = false;
  Future<void> _load() async {
    if (_fetching) return;
    _fetching = true;
    setState(() {
      _loading = _profile == null;
      _error = null;
    });
    try {
      final result = await sl<MarketplaceRepository>()
          .masterProfile(widget.masterId)
          .timeout(const Duration(seconds: 20));
      if (!mounted) return;
      setState(() {
        if (result.isRight) {
          _profile = result.right;
        } else {
          _error = result.left.errorMessage;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error is TimeoutException
          ? context.t.common.loadingTimeout
          : context.t.common.wentWrong);
    } finally {
      _fetching = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final p = _profile;

    return Scaffold(
      backgroundColor: colors.neutral.black7,
      appBar: AppBar(title: Text(context.t.masters.aboutMaster)),
      bottomNavigationBar: p == null
          ? null
          : _ContactBar(
              phone: p.phoneNumber,
              onChoose: widget.onChoose,
              onChat: widget.onChat),
      body: _loading
          ? const SingleChildScrollView(
              padding: EdgeInsets.all(ChizmaSpace.lg),
              child: ListLoadingPlaceholder(showAvatar: true))
          : p == null
              ? Center(
                  child: SingleChildScrollView(
                      child: ChizmaEmptyState(
                          icon: Icons.wifi_off_rounded,
                          title: context.t.masters.loadFailed,
                          message: _error ?? context.t.common.notFound,
                          actionLabel: context.t.common.retry,
                          onAction: _load)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      ChizmaSpace.lg,
                      ChizmaSpace.lg,
                      ChizmaSpace.lg,
                      ChizmaSpace.xxl + context.viewPaddingBottom,
                    ),
                    children: [
                      if (_error != null) ...[
                        ChizmaSheet(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(_error!),
                              TextButton.icon(
                                  onPressed: _load,
                                  icon: const Icon(Icons.refresh),
                                  label: Text(context.t.common.retry))
                            ])),
                        const SizedBox(height: ChizmaSpace.md),
                      ],
                      _Header(profile: p),
                      const SizedBox(height: ChizmaSpace.lg),
                      _Stats(profile: p),

                      if (p.rates.isNotEmpty) ...[
                        const SizedBox(height: ChizmaSpace.lg),
                        ChizmaEyebrow(context.t.masters.prices),
                        const SizedBox(height: ChizmaSpace.sm),
                        ChizmaSheet(child: MasterRatesBlock(rates: p.rates)),
                      ],

                      if (p.notes.isNotEmpty) ...[
                        const SizedBox(height: ChizmaSpace.lg),
                        ChizmaEyebrow('Xizmat va narxlari'),
                        const SizedBox(height: ChizmaSpace.sm),
                        ChizmaSheet(child: MasterNotesBlock(notes: p.notes)),
                      ],
                      if (p.bio.isNotEmpty) ...[
                        const SizedBox(height: ChizmaSpace.lg),
                        ChizmaEyebrow(context.t.masters.aboutMaster),
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
                        ChizmaEyebrow(context.t.masters.portfolioTitle),
                        const SizedBox(height: ChizmaSpace.sm),
                        _WorkSamples(samples: p.workSamples),
                      ],
                      const SizedBox(height: ChizmaSpace.lg),
                      ChizmaEyebrow(context.t.masters
                          .reviewsCount(count: p.reviewsCount)),
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

class _ContactBar extends StatelessWidget {
  const _ContactBar({this.phone, this.onChoose, this.onChat});
  final String? phone;
  final VoidCallback? onChoose;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final hasPhone = phone?.trim().isNotEmpty ?? false;
    if (!hasPhone && onChoose == null && onChat == null) {
      return const SizedBox.shrink();
    }
    final colors = context.color;
    return Material(
      color: colors.neutral.surface,
      child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(ChizmaSpace.md),
            child: Wrap(
                alignment: WrapAlignment.center,
                spacing: ChizmaSpace.sm,
                runSpacing: ChizmaSpace.sm,
                children: [
                  if (hasPhone)
                    OutlinedButton.icon(
                        onPressed: () => launchUrl(
                            Uri(scheme: 'tel', path: phone!),
                            mode: LaunchMode.externalApplication),
                        icon: const Icon(Icons.call_outlined, size: 18),
                        label: Text(phone!),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48))),
                  if (onChat != null)
                    OutlinedButton.icon(
                        onPressed: onChat,
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 18),
                        label: Text(context.t.marketplace.write)),
                  if (onChoose != null)
                    FilledButton(
                        onPressed: onChoose,
                        style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            backgroundColor: colors.categorizedColor.primary,
                            foregroundColor: colors.neutral.white),
                        child: Text(context.t.marketplace.selectThisMaster)),
                ]),
          )),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});
  final MasterProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final primary = colors.categorizedColor.primary;
    final location = [profile.regionName, profile.districtName]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(', ');
    final name = profile.fullName.trim().isEmpty
        ? context.t.masters.noName
        : profile.fullName;
    final fallback = ColoredBox(
        color: primary.withValues(alpha: 0.08),
        child: Center(
            child: Text(name.characters.first.toUpperCase(),
                style: context.text.h2.copyWith(color: primary))));
    return ChizmaSheet(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(ChizmaRadius.lg),
              child: SizedBox.square(
                  dimension: 76,
                  child: profile.photo?.trim().isNotEmpty == true
                      ? Image.network(profile.photo!,
                          fit: BoxFit.cover,
                          cacheWidth:
                              (76 * MediaQuery.devicePixelRatioOf(context))
                                  .round(),
                          frameBuilder: (_, child, frame, sync) =>
                              sync || frame != null ? child : fallback,
                          errorBuilder: (_, __, ___) => fallback)
                      : fallback)),
          const SizedBox(width: ChizmaSpace.md),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: context.text.h3
                        .copyWith(color: colors.neutral.textStrong)),
                if (profile.isVerified)
                  Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(Icons.verified_rounded,
                          size: 20, color: primary)),
              ])),
        ]),
        const SizedBox(height: ChizmaSpace.lg),
        Text(
            localizedMasterSpecialties(
                context, profile.specialties, profile.specialty),
            style: context.text.body4
                .copyWith(color: primary, fontWeight: FontWeight.w600)),
        if (profile.experienceYears != null) ...[
          const SizedBox(height: ChizmaSpace.sm),
          _InfoLine(
              icon: Icons.work_history_outlined,
              text: context.t.masters
                  .experienceYears(count: profile.experienceYears!)),
        ],
        if (location.isNotEmpty) ...[
          const SizedBox(height: ChizmaSpace.sm),
          _InfoLine(icon: Icons.location_on_outlined, text: location),
        ],
      ],
    ));
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: context.color.neutral.textMuted),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: context.text.body4
                    .copyWith(color: context.color.neutral.textMuted))),
      ]);
}

class _Stats extends StatelessWidget {
  const _Stats({required this.profile});
  final MasterProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        Icons.star_outline_rounded,
        context.t.masters.rating,
        profile.rating?.toStringAsFixed(1) ?? '—'
      ),
      (
        Icons.task_alt_rounded,
        context.t.masters.completed,
        '${profile.completedOrders}'
      ),
      (
        Icons.chat_bubble_outline_rounded,
        context.t.masters.reviews,
        '${profile.reviewsCount}'
      ),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final stacked = constraints.maxWidth < 260 ||
          MediaQuery.textScalerOf(context).scale(14) > 20;
      return Wrap(spacing: 8, runSpacing: 8, children: [
        for (final stat in stats)
          SizedBox(
              width: stacked
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 16) / 3,
              child: ChizmaSheet(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(stat.$1,
                            size: 20,
                            color: context.color.categorizedColor.primary),
                        const SizedBox(height: 8),
                        Text(stat.$3, style: context.text.h3),
                        Text(stat.$2,
                            style: context.text.body5.copyWith(
                                color: context.color.neutral.textMuted)),
                      ]))),
      ]);
    });
  }
}

class _WorkSamples extends StatelessWidget {
  const _WorkSamples({required this.samples});
  final List<WorkSampleEntity> samples;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: samples.length,
          separatorBuilder: (_, __) => const SizedBox(width: ChizmaSpace.md),
          itemBuilder: (context, index) {
            final sample = samples[index];
            return Semantics(
              label: '${context.t.masters.portfolioTitle} ${index + 1}',
              button: true,
              child: SizedBox(
                  width: 230,
                  child: Material(
                    color: context.color.neutral.surface2,
                    borderRadius: BorderRadius.circular(ChizmaRadius.lg),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (_) =>
                                  _WorkSampleViewer(sample: sample))),
                      child: Stack(fit: StackFit.expand, children: [
                        _SampleImage(
                            url: sample.image,
                            fit: BoxFit.cover,
                            cacheWidth:
                                (230 * MediaQuery.devicePixelRatioOf(context))
                                    .round()),
                        Positioned(
                            right: 8,
                            top: 8,
                            child: DecoratedBox(
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(Icons.open_in_full_rounded,
                                        color: Colors.white, size: 18)))),
                        if (sample.caption.trim().isNotEmpty)
                          Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  padding: const EdgeInsets.all(10),
                                  child: Text(sample.caption,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.body5
                                          .copyWith(color: Colors.white)))),
                      ]),
                    ),
                  )),
            );
          },
        ),
      );
}

class _SampleImage extends StatelessWidget {
  const _SampleImage({required this.url, required this.fit, this.cacheWidth});
  final String url;
  final BoxFit fit;
  final int? cacheWidth;
  @override
  Widget build(BuildContext context) => Image.network(
        url,
        fit: fit,
        cacheWidth: cacheWidth,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Center(
                child: SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))),
        errorBuilder: (_, __, ___) => Center(
            child: Icon(Icons.image_not_supported_outlined,
                color: context.color.neutral.textMuted, size: 32)),
      );
}

class _WorkSampleViewer extends StatelessWidget {
  const _WorkSampleViewer({required this.sample});
  final WorkSampleEntity sample;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.t.masters.portfolioTitle)),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                      child: _SampleImage(
                          url: sample.image, fit: BoxFit.contain)))),
          if (sample.caption.trim().isNotEmpty)
            Flexible(
                flex: 0,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.25),
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child:
                            Text(sample.caption, style: context.text.body4)))),
        ])),
      );
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
              Expanded(
                child: Text(
                  review.clientName.isEmpty
                      ? context.t.auth.selection.customerRole
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
          const SizedBox(height: ChizmaSpace.sm),
          Semantics(
              label: '${context.t.masters.rating}: ${review.rating} / 5',
              child: ExcludeSemantics(
                  child: Row(children: [
                for (var i = 1; i <= 5; i++)
                  Icon(
                      i <= review.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 18,
                      color: colors.categorizedColor.accent),
              ]))),
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
