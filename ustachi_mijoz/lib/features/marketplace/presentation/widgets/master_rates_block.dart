import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';
import 'package:ustachi/core/design_sytem/widgets/chizma_widgets.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:ustachi/core/utils/localization/specialty_name_helper.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/proposal/proposal_option_card.dart'
    show formatSom;
import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

class MasterRatesBlock extends StatelessWidget {
  const MasterRatesBlock({
    super.key,
    required this.rates,
    this.compact = false,
  });

  final List<MasterRateEntity> rates;

  final bool compact;

  static const int _compactLimit = 2;

  @override
  Widget build(BuildContext context) {
    if (rates.isEmpty) return const SizedBox.shrink();
    final colors = context.color;
    final shown = compact ? rates.take(_compactLimit).toList() : rates;

    if (compact) {
      return Wrap(
        spacing: ChizmaSpace.xs,
        runSpacing: ChizmaSpace.xs,
        children: [
          for (final rate in shown) _RateChip(rate: rate),
          if (rates.length > _compactLimit)
            Text(
              '+${rates.length - _compactLimit}',
              style:
                  context.text.label.copyWith(color: colors.neutral.textMuted),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final rate in shown) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: ChizmaSpace.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizedMasterRate(context, rate),
                    style: context.text.body4
                        .copyWith(color: colors.neutral.textBody)),
                const SizedBox(height: ChizmaSpace.xs),
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text:
                          '${formatSom(rate.price.toDouble())} ${context.t.calculatePage.som}',
                      style: context.text.numeric.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.neutral.textStrong)),
                  TextSpan(
                      text: ' / ${rate.unit}',
                      style: context.text.body5
                          .copyWith(color: colors.neutral.textMuted)),
                ])),
                if (rate != shown.last)
                  Padding(
                      padding: const EdgeInsets.only(top: ChizmaSpace.sm),
                      child: Divider(height: 1, color: colors.neutral.border)),
              ],
            ),
          ),
        ],
        const SizedBox(height: ChizmaSpace.xs),
        Text(
          context.t.masters.estimatedPriceNotice,
          style: context.text.body5.copyWith(color: colors.neutral.textMuted),
        ),
      ],
    );
  }
}

class MasterNotesBlock extends StatelessWidget {
  const MasterNotesBlock({
    super.key,
    required this.notes,
    this.compact = false,
  });

  final List<MasterNoteEntity> notes;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();
    final colors = context.color;

    if (compact) {
      final note = notes.first;
      return Text(
        '${note.name}: ${note.text.replaceAll('\n', ' ')}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.text.label.copyWith(color: colors.neutral.textBody),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final note in notes) ...[
          Text(
            note.name,
            style: context.text.body4.copyWith(
              color: colors.neutral.textStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: ChizmaSpace.xs),
          Text(
            note.text,
            style: context.text.body4
                .copyWith(color: colors.neutral.textBody, height: 1.4),
          ),
          const SizedBox(height: ChizmaSpace.md),
        ],
        Text(
          'Aniq narxni ishni ko\'rib, chatda kelishasiz.',
          style: context.text.body5.copyWith(color: colors.neutral.textMuted),
        ),
      ],
    );
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({required this.rate});

  final MasterRateEntity rate;

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final labelName = localizedMasterRate(context, rate);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ChizmaSpace.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: colors.neutral.surface2,
        borderRadius: BorderRadius.circular(ChizmaRadius.sm),
      ),
      child: Text(
        '$labelName: ${formatSom(rate.price.toDouble())} ${context.t.calculatePage.som}/${rate.unit}',
        style: context.text.label.copyWith(color: colors.neutral.textBody),
      ),
    );
  }
}
