
enum OrderStage {
  accepted,

  measured,

  production,

  installation,

  handover;

  static const List<OrderStage> romStages = [accepted, measured];

  static const List<OrderStage> otherStages = [accepted];

  static List<OrderStage> stagesFor({required bool isRom}) =>
      isRom ? romStages : otherStages;

  bool get isLegacy => !romStages.contains(this);

  int get step => index + 1;

  bool get isLast => this == OrderStage.handover;

  OrderStage? get next => isLast ? null : OrderStage.values[index + 1];
}
