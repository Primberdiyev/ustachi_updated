import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/marketplace/domain/entities/order_entity.dart';

class InvitedMastersBlock extends StatelessWidget {
  const InvitedMastersBlock({
    super.key,
    required this.order,
    required this.onInviteMore,
    required this.onProfile,
    this.onOpenToEveryone,
    this.busy = false,
  });

  final OrderEntity order;
  final VoidCallback onInviteMore;
  final ValueChanged<int> onProfile;

  final VoidCallback? onOpenToEveryone;

  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final invites = order.invites;
    final waiting = order.pendingInvites.length;
    final declined = order.declinedInvites.length;
    final allDeclined = invites.isNotEmpty && declined == invites.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChizmaSectionHeader(title: 'Siz tanlagan ustalar (${invites.length})'),
        const SizedBox(height: ChizmaSpace.md),

        for (final invite in invites) ...[
          _InviteCard(invite: invite, onProfile: () => onProfile(invite.master.id)),
          const SizedBox(height: ChizmaSpace.sm),
        ],

        const SizedBox(height: ChizmaSpace.xs),

        _StateLine(
          text: allDeclined
              ? 'Taklif qilgan ustalaringiz rad etdi. Boshqa usta tanlang '
                  'yoki e\'lonni hamma ustaga oching.'
              : (waiting > 0
                  ? (order.isDirect
                      ? 'Buyurtma faqat shu ustalarga ko\'rinadi. Javob '
                          'kelishi bilan sizga bildirishnoma keladi.'
                      : 'Bu ustalarga shaxsan taklif yubordingiz. E\'lon '
                          'boshqa ustalarga ham ochiq.')
                  : 'Javoblar quyida — profilini ko\'rib, chatda kelishasiz.'),
          tone: allDeclined ? _Tone.warning : _Tone.muted,
        ),

        const SizedBox(height: ChizmaSpace.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : onInviteMore,
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                label: const Text('Yana usta'),
              ),
            ),
            if (onOpenToEveryone != null) ...[
              const SizedBox(width: ChizmaSpace.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: busy ? null : onOpenToEveryone,
                  icon: const Icon(Icons.campaign_outlined, size: 18),
                  label: const Text('Hammaga ochish'),
                ),
              ),
            ],
          ],
        ),
        if (onOpenToEveryone != null) ...[
          const SizedBox(height: ChizmaSpace.sm),
          Text(
            'Hammaga ochsangiz e\'lon hududingizdagi barcha ustalarga '
            'ko\'rinadi. Orqaga qaytarib bo\'lmaydi.',
            style: context.text.label.copyWith(color: colors.neutral.textMuted),
          ),
        ],
      ],
    );
  }
}

enum _Tone { muted, warning }

class _StateLine extends StatelessWidget {
  const _StateLine({required this.text, required this.tone});

  final String text;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final color = tone == _Tone.warning
        ? colors.categorizedColor.warning
        : colors.neutral.textMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            tone == _Tone.warning
                ? Icons.error_outline_rounded
                : Icons.info_outline_rounded,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: ChizmaSpace.sm),
        Expanded(
          child: Text(
            text,
            style: context.text.body5.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.invite, required this.onProfile});

  final OrderInviteEntity invite;
  final VoidCallback onProfile;

  ChizmaStatus get _pillStatus => switch (invite.status) {
        InviteStatus.pending => ChizmaStatus.progress,
        InviteStatus.accepted => ChizmaStatus.done,
        InviteStatus.declined => ChizmaStatus.danger,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final master = invite.master;
    final letter = master.displayName.trim().isEmpty
        ? '?'
        : master.displayName.trim()[0].toUpperCase();

    return ChizmaSheet(
      onTap: onProfile,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.neutral.surface2,
                  borderRadius: BorderRadius.circular(ChizmaRadius.md),
                  border: Border.all(color: colors.neutral.border),
                ),
                child: Text(
                  letter,
                  style: context.text.body4
                      .copyWith(color: colors.neutral.textMuted),
                ),
              ),
              const SizedBox(width: ChizmaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      master.displayName,
                      style: context.text.body4.copyWith(
                        color: colors.neutral.textStrong,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (master.specialty != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        master.specialty!,
                        style: context.text.body5
                            .copyWith(color: colors.neutral.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: ChizmaSpace.sm),
              ChizmaStatusPill(invite.status.label, status: _pillStatus),
            ],
          ),

          if (invite.declineReason.isNotEmpty) ...[
            const SizedBox(height: ChizmaSpace.sm),
            Text(
              '«${invite.declineReason}»',
              style: context.text.body5.copyWith(
                color: colors.neutral.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
