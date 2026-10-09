import 'package:dio/dio.dart';
import 'package:ustachi/core/api/api_list.dart';
import 'package:ustachi/core/api/api_urls.dart';
import 'package:ustachi/features/profile/data/master_profile_cache.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';

const String texnikaGroup = 'texnika';

const List<String> masterUnits = [
  'soat', 'kun', 'reys', 'metr', 'km', 'm³', 'tonna',
];

const int maxMasterUnits = 2;

const penthouseServerName = 'Penthaus gidro tom';
const penthouseDisplayName = 'Tom gidro izolyatsiya terassa pent haus PVX TPO membrana';

String specialtyDisplayName(String name) => name.trim() == penthouseServerName ? penthouseDisplayName : name;

class MasterSpecialty {
  const MasterSpecialty({
    required this.id,
    required this.name,
    this.code = '',
    this.unit = '',
    this.unitQuestion = '',
    this.variants = const [],
    this.group = '',
    this.unitByMaster = false,
    this.noteByMaster = false,
  });

  final int id;
  final String name;

  final String code;

  final String unit;

  final String unitQuestion;

  final String group;

  final bool unitByMaster;

  final bool noteByMaster;

  bool get isTexnika => group == texnikaGroup;

  static const String romCode = 'rom';

  bool get isRom => code == romCode;

  final List<MasterSpecialtyVariant> variants;

  bool get asksRate =>
      !noteByMaster &&
      (unitByMaster || (code != 'penthaus_gidro_tom' && unit.isNotEmpty));

  bool get asksRatePerVariant => !unitByMaster && asksRate && variants.isNotEmpty;

  factory MasterSpecialty.fromJson(Map<String, dynamic> json) =>
      MasterSpecialty(
        id: json['id'] as int,

        name: json['code'] == 'penthaus_gidro_tom'
            ? penthouseDisplayName
            : specialtyDisplayName(json['name']?.toString() ?? ''),
        code: json['code']?.toString() ?? '',
        unit: json['unit']?.toString() ?? '',
        unitQuestion: json['unit_question']?.toString() ?? '',
        group: json['group']?.toString() ?? '',
        unitByMaster: json['unit_by_master'] == true,
        noteByMaster: json['note_by_master'] == true,
        variants: MasterSpecialtyVariant.listFrom(json['variants'])
            .where((v) =>
                json['code'] != 'tom' ||
                v.name != 'Gidroizolatsiya — penthaus tom yopish')
            .toList(),
      );

  static List<MasterSpecialty> listFrom(Object? data) {
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map)
          MasterSpecialty.fromJson(Map<String, dynamic>.from(row)),
    ];
  }
}

class MasterSpecialtyVariant {
  const MasterSpecialtyVariant({
    required this.id,
    required this.name,
    this.size = '',
  });

  final int id;
  final String name;

  final String size;

  factory MasterSpecialtyVariant.fromJson(Map<String, dynamic> json) =>
      MasterSpecialtyVariant(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse('${json['id']}') ?? 0,
        name: json['name']?.toString() ?? '',
        size: json['size']?.toString() ?? '',
      );

  static List<MasterSpecialtyVariant> listFrom(Object? data) {
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map)
          MasterSpecialtyVariant.fromJson(Map<String, dynamic>.from(row)),
    ];
  }
}

class MasterRate {
  const MasterRate({
    required this.specialtyId,
    required this.price,
    this.variantId,
    this.variantName = '',
    this.code = '',
    this.name = '',
    this.unit = '',
  });

  final int specialtyId;

  final int? variantId;
  final String variantName;
  final int price;
  final String code;
  final String name;
  final String unit;

  factory MasterRate.fromJson(Map<String, dynamic> json) => MasterRate(
        specialtyId: json['specialty'] is int
            ? json['specialty'] as int
            : int.tryParse('${json['specialty']}') ?? 0,
        price: json['price'] is int
            ? json['price'] as int
            : int.tryParse('${json['price']}') ?? 0,
        variantId: json['variant'] is int
            ? json['variant'] as int
            : int.tryParse('${json['variant']}'),
        variantName: json['variant_name']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        name: specialtyDisplayName(json['name']?.toString() ?? ''),
        unit: json['unit']?.toString() ?? '',
      );

  static List<MasterRate> listFrom(Object? data) {
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map) MasterRate.fromJson(Map<String, dynamic>.from(row)),
    ];
  }
}

class MasterWorkSample {
  const MasterWorkSample({
    required this.id,
    required this.imageUrl,
    this.caption = '',
  });

  final int id;
  final String imageUrl;
  final String caption;

  factory MasterWorkSample.fromJson(Map<String, dynamic> json) =>
      MasterWorkSample(
        id: json['id'] as int,
        imageUrl: json['image']?.toString() ?? '',
        caption: json['caption']?.toString() ?? '',
      );
}

class MasterMaterials {
  const MasterMaterials({
    this.plastic = true,
    this.aluminium = true,
    this.termo = true,
  });

  final bool plastic;
  final bool aluminium;
  final bool termo;

  static const all = MasterMaterials();

  bool get anyOn => plastic || aluminium || termo;

  MasterMaterials copyWith({bool? plastic, bool? aluminium, bool? termo}) =>
      MasterMaterials(
        plastic: plastic ?? this.plastic,
        aluminium: aluminium ?? this.aluminium,
        termo: termo ?? this.termo,
      );

  Map<String, dynamic> toJson() => {
        'does_plastic': plastic,
        'does_aluminium': aluminium,
        'does_termo': termo,
      };

  factory MasterMaterials.fromJson(Map<String, dynamic> json) =>
      MasterMaterials(

        plastic: json['does_plastic'] != false,
        aluminium: json['does_aluminium'] != false,
        termo: json['does_termo'] != false,
      );
}

class MasterProfileData {
  const MasterProfileData({
    this.specialtyId,
    this.specialtyName = '',
    this.specialties = const [],
    this.specialtyRates = const [],
    this.specialtyNotes = const {},
    this.experienceYears,
    this.bio = '',
    this.isVerified = false,
    this.acceptsOrders = true,
    this.doesRepairs = false,
    this.materials = MasterMaterials.all,
    this.companyName = '',
    this.companyLogoUrl,
    this.workSamples = const [],
  });

  final int? specialtyId;
  final String specialtyName;

  final List<MasterSpecialty> specialties;

  final List<MasterRate> specialtyRates;

  final Map<int, String> specialtyNotes;

  Map<int, int> get rateBySpecialty => {
        for (final rate in specialtyRates)
          if (rate.variantId == null) rate.specialtyId: rate.price,
      };

  Map<int, int> get rateByVariant => {
        for (final rate in specialtyRates)
          if (rate.variantId != null) rate.variantId!: rate.price,
      };

  bool get hasRom => specialties.isEmpty
      ? specialtyId != null
      : specialties.any((s) => s.isRom);

  final int? experienceYears;
  final String bio;
  final bool isVerified;

  final bool acceptsOrders;

  final bool doesRepairs;

  final MasterMaterials materials;

  final String companyName;

  final String? companyLogoUrl;

  final List<MasterWorkSample> workSamples;

  bool get isComplete => specialtyId != null && experienceYears != null;

  static Map<int, String> _notes(Object? data) => {
        for (final row in apiList(data).whereType<Map>())
          if (row['specialty'] is int)
            row['specialty'] as int: row['text']?.toString() ?? '',
      };

  factory MasterProfileData.fromJson(Map<String, dynamic> json) =>
      MasterProfileData(
        specialtyId: json['specialty'] is int ? json['specialty'] as int : null,
        specialtyName: specialtyDisplayName(json['specialty_name']?.toString() ?? ''),
        specialties: MasterSpecialty.listFrom(json['specialty_list']),
        specialtyRates: MasterRate.listFrom(json['rates']),
        specialtyNotes: _notes(json['notes']),
        experienceYears: json['experience_years'] is int
            ? json['experience_years'] as int
            : null,
        bio: json['bio']?.toString() ?? '',
        isVerified: json['is_verified'] == true,
        acceptsOrders: json['accepts_orders'] != false,
        doesRepairs: json['does_repairs'] == true,
        materials: MasterMaterials.fromJson(json),
        companyName: json['company_name']?.toString() ?? '',
        companyLogoUrl: (json['company_logo']?.toString().isNotEmpty ?? false)
            ? json['company_logo'].toString()
            : null,
        workSamples: apiList(json['work_samples'])
            .whereType<Map>()
            .map((e) => MasterWorkSample.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class MasterProfileApi {
  MasterProfileApi(this._dio, {MasterProfileCache? cache})
      : _cache = cache ?? MasterProfileCache();

  final Dio _dio;

  final MasterProfileCache _cache;

  Future<List<MasterSpecialty>> specialties() async {
    try {
      final response = await _dio.get(ApiUrls.masterSpecialties);
      return apiList(response.data)
          .whereType<Map>()
          .map((e) => MasterSpecialty.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException {
      return const [];
    }
  }

  Future<MasterProfileData?> read() async => (await readWithStatus()).data;

  Future<({MasterProfileData? data, bool reachable})> readWithStatus(
      {bool rejectUnauthorized = false}) async {
    try {
      final response = await _dio.get(ApiUrls.masterProfile);
      final data = response.data;
      if (data is Map) {
        final raw = Map<String, dynamic>.from(data);
        await _cache.save(raw);
        return (data: MasterProfileData.fromJson(raw), reachable: true);
      }
      return (data: null, reachable: true);
    } on DioException catch (e) {
      if (rejectUnauthorized && [401, 403].contains(e.response?.statusCode)) {
        rethrow;
      }
      if (e.response?.statusCode == 404) {
        await _cache.clear();
        return (data: null, reachable: true);
      }
      return (data: _cache.read(), reachable: false);
    }
  }

  Future<String?> save({
    required List<int> specialtyIds,
    required int experienceYears,
    String bio = '',
  }) async {
    if (specialtyIds.isEmpty) return t.professional.pickSpecialty;
    try {
      await _dio.post(
        ApiUrls.masterProfile,
        data: FormData.fromMap({
          'specialty': specialtyIds.first,
          'specialties': specialtyIds,
          'experience_years': experienceYears,
          'bio': bio,
        }),
      );
      return null;
    } on DioException catch (e) {
      return _message(e, t.common.saveFailed);
    }
  }

  Future<String?> saveRates(
    Map<int, int> priceBySpecialty, {
    Map<({int specialtyId, int variantId}), int> variantRates = const {},
    Map<int, Map<String, int>> unitRates = const {},
  }) async {
    try {
      await _dio.put(ApiUrls.masterProfileRates, data: {
        'rates': [
          for (final entry in priceBySpecialty.entries)
            {'specialty': entry.key, 'price': entry.value},
          for (final entry in variantRates.entries)
            {
              'specialty': entry.key.specialtyId,
              'variant': entry.key.variantId,
              'price': entry.value,
            },

          for (final machine in unitRates.entries)
            for (final rate in machine.value.entries)
              {'specialty': machine.key, 'unit': rate.key, 'price': rate.value},
        ],
      });
      return null;
    } on DioException catch (e) {
      return _message(e, t.common.saveFailed);
    }
  }

  Future<String?> saveNotes(Map<int, String> textBySpecialty) async {
    try {
      await _dio.put(ApiUrls.masterProfileNotes, data: {
        'notes': [
          for (final entry in textBySpecialty.entries)
            if (entry.value.trim().isNotEmpty)
              {'specialty': entry.key, 'text': entry.value.trim()},
        ],
      });
      return null;
    } on DioException catch (e) {
      return _message(e, t.common.saveFailed);
    }
  }

  Future<String?> addWorkSample(String imagePath, {String caption = ''}) async {
    try {
      await _dio.post(
        ApiUrls.masterWorkSamples,
        data: FormData.fromMap({
          'image': await MultipartFile.fromFile(imagePath),
          'caption': caption,
        }),
      );
      return null;
    } on DioException catch (e) {
      return _message(e, t.common.saveFailed);
    }
  }

  Future<String?> saveCompany({String? name, String? logoPath}) async {
    try {
      if (logoPath != null) {
        await _dio.patch(
          ApiUrls.masterProfile,
          data: FormData.fromMap({
            if (name != null) 'company_name': name,
            'company_logo': await MultipartFile.fromFile(logoPath),
          }),
        );
      } else {
        await _dio.patch(
          ApiUrls.masterProfile,
          data: {'company_name': name ?? ''},
        );
      }
      return null;
    } on DioException catch (e) {
      return _message(e, t.common.saveFailed);
    }
  }

  Future<String?> saveMaterials(MasterMaterials materials) async {
    try {
      await _dio.patch(ApiUrls.masterProfile, data: materials.toJson());
      return null;
    } on DioException catch (e) {
      return _message(e, t.common.saveFailed);
    }
  }

  Future<bool> setAcceptsOrders(bool value) async {
    try {
      await _dio.patch(ApiUrls.masterProfile, data: {'accepts_orders': value});
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> setDoesRepairs(bool value) async {
    try {
      await _dio.patch(ApiUrls.masterProfile, data: {'does_repairs': value});
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> deleteWorkSample(int id) async {
    try {
      await _dio.delete('${ApiUrls.masterWorkSamples}$id/');
      return true;
    } on DioException {
      return false;
    }
  }

  static String _message(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail != null) return detail.toString();
      for (final value in data.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value is String) return value;
      }
    }
    return fallback;
  }
}
