import 'package:flutter/material.dart' hide Text;
import 'package:ustachi/core/script/script_text.dart';

class PriceEstimateNotice extends StatelessWidget {
  const PriceEstimateNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        'Ushbu narxlar hududingizga qarab biroz farq qilishi mumkin. '
        'Ilova usta va mijoz o‘rtasidagi aniq summaga javobgar emas. '
        '100 foiz to‘liq narxni ustangiz kelganida kelishasiz.',
        textAlign: TextAlign.center,

        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 15,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
