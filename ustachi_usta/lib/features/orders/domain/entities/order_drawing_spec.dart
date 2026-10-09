import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';

typedef OrderDrawingSpec = ({FramePreviewSpec spec, int? frameArgb});

List<OrderDrawingSpec> orderDrawingsOf(Iterable<FramePreviewSpec> specs) =>
    [for (final spec in specs) (spec: spec, frameArgb: null)];
