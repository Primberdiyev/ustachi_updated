
library;

import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

enum HisobKind {
  window('Deraza', 1500, 1400),
  door('Eshik', 900, 2100);

  const HisobKind(this.label, this.defaultWidthMm, this.defaultHeightMm);

  final String label;
  final double defaultWidthMm;
  final double defaultHeightMm;

  hisob.FrameDesign blankDesign() => hisob.FrameDesign(
        widthMm: defaultWidthMm,
        heightMm: defaultHeightMm,
        root: this == HisobKind.door ? const hisob.Wing(hisob.WingKind.door) : const hisob.Zone(),
      );
}

class ItemSettings {
  const ItemSettings({
    this.material = 0,
    this.colorName = '',
    this.colorArgb,
    this.balconyDoor = false,
    this.qty = 1,
  });

  static const fresh = ItemSettings(material: 1);

  final int material;

  final String colorName;
  final int? colorArgb;

  final bool balconyDoor;

  final int qty;

  bool get isColored => colorArgb != null;

  ItemSettings copyWith({
    int? material,
    String? colorName,
    int? colorArgb,
    bool clearColor = false,
    bool? balconyDoor,
    int? qty,
  }) =>
      ItemSettings(
        material: material ?? this.material,
        colorName: clearColor ? '' : (colorName ?? this.colorName),
        colorArgb: clearColor ? null : (colorArgb ?? this.colorArgb),
        balconyDoor: balconyDoor ?? this.balconyDoor,
        qty: qty ?? this.qty,
      );

  Map<String, dynamic> toJson() => {
        'material': material,
        if (colorName.isNotEmpty) 'colorName': colorName,
        if (colorArgb != null) 'colorArgb': colorArgb,
        'balcony': balconyDoor,
        'qty': qty,
      };

  factory ItemSettings.fromJson(Map<String, dynamic> j) {
    final argb = (j['colorArgb'] as num?)?.toInt();
    return ItemSettings(
      material: ((j['material'] as num?)?.toInt() ?? 0).clamp(0, 2),
      colorName: argb == null ? '' : (j['colorName'] ?? '').toString(),
      colorArgb: argb,
      balconyDoor: j['balcony'] == true,
      qty: ((j['qty'] as num?)?.toInt() ?? 1).clamp(1, 999),
    );
  }
}

class HisobItem {
  const HisobItem({
    required this.id,
    required this.kind,
    required this.design,
    this.settings = const ItemSettings(),
  });

  final String id;
  final HisobKind kind;
  final hisob.FrameDesign design;
  final ItemSettings settings;

  String get sizeLabel => '${design.widthMm.round()} × ${design.heightMm.round()}';

  HisobItem copyWith({hisob.FrameDesign? design, ItemSettings? settings, HisobKind? kind}) => HisobItem(
        id: id,
        kind: kind ?? this.kind,
        design: design ?? this.design,
        settings: settings ?? this.settings,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'design': hisob.designToJson(design),
        'settings': settings.toJson(),
      };

  factory HisobItem.fromJson(Map<String, dynamic> j) => HisobItem(
        id: j['id'].toString(),
        kind: HisobKind.values.firstWhere((k) => k.name == j['kind'], orElse: () => HisobKind.window),
        design: hisob.designFromJson(Map<String, dynamic>.from(j['design'] as Map)),
        settings: ItemSettings.fromJson(Map<String, dynamic>.from((j['settings'] ?? const {}) as Map)),
      );
}

class HisobOrder {
  const HisobOrder({this.phone = '', this.address = '', this.deadline});

  final String phone;
  final String address;

  final DateTime? deadline;

  bool get isEmpty => phone.isEmpty && address.isEmpty && deadline == null;

  Map<String, dynamic> toJson() => {
        if (phone.isNotEmpty) 'phone': phone,
        if (address.isNotEmpty) 'address': address,
        if (deadline != null) 'deadline': deadline!.toIso8601String(),
      };

  factory HisobOrder.fromJson(Map<String, dynamic> j) => HisobOrder(
        phone: (j['phone'] ?? '').toString(),
        address: (j['address'] ?? '').toString(),
        deadline: DateTime.tryParse('${j['deadline'] ?? ''}'),
      );
}

class HisobProject {
  const HisobProject({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.client = '',
    this.items = const [],
    this.order = const HisobOrder(),
  });

  final String id;

  final String client;
  final List<HisobItem> items;

  final HisobOrder order;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isEmpty => items.isEmpty;
  int get pieceCount => items.fold(0, (s, i) => s + i.settings.qty);

  HisobProject copyWith({
    String? client,
    List<HisobItem>? items,
    HisobOrder? order,
    DateTime? updatedAt,
  }) =>
      HisobProject(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        client: client ?? this.client,
        items: items ?? this.items,
        order: order ?? this.order,
      );

  HisobProject upsertItem(HisobItem item) {
    final exists = items.any((i) => i.id == item.id);
    return copyWith(
      items: exists ? [for (final i in items) i.id == item.id ? item : i] : [...items, item],
    );
  }

  HisobProject removeItem(String itemId) => copyWith(items: items.where((i) => i.id != itemId).toList());

  Map<String, dynamic> toJson() => {
        'id': id,
        'client': client,
        'items': [for (final i in items) i.toJson()],
        if (!order.isEmpty) 'order': order.toJson(),
        'created': createdAt.toIso8601String(),
        'updated': updatedAt.toIso8601String(),
      };

  factory HisobProject.fromJson(Map<String, dynamic> j) => HisobProject(
        id: j['id'].toString(),
        client: (j['client'] ?? '').toString(),
        items: [
          for (final i in (j['items'] as List? ?? const []))
            HisobItem.fromJson(Map<String, dynamic>.from(i as Map)),
        ],
        order: j['order'] is Map ? HisobOrder.fromJson(Map<String, dynamic>.from(j['order'] as Map)) : const HisobOrder(),
        createdAt: DateTime.tryParse('${j['created']}') ?? DateTime.now(),
        updatedAt: DateTime.tryParse('${j['updated']}') ?? DateTime.now(),
      );
}

String newHisobId() => '${DateTime.now().microsecondsSinceEpoch}-${_idSeq++}';

int _idSeq = 0;
