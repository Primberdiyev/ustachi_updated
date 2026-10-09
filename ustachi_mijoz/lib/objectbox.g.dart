
import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; 
import 'package:objectbox/objectbox.dart' as obx;

import 'core/local/objectbox/app_cache_entry.dart';

export 'package:objectbox/objectbox.dart'; 

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
    id: const obx_int.IdUid(1, 9008614968043148791),
    name: 'AppCacheEntry',
    lastPropertyId: const obx_int.IdUid(4, 2135522685203600902),
    flags: 0,
    properties: <obx_int.ModelProperty>[
      obx_int.ModelProperty(
        id: const obx_int.IdUid(1, 4716184387998563793),
        name: 'id',
        type: 6,
        flags: 1,
      ),
      obx_int.ModelProperty(
        id: const obx_int.IdUid(2, 412531470573369305),
        name: 'key',
        type: 9,
        flags: 2080,
        indexId: const obx_int.IdUid(1, 2687854768547039603),
      ),
      obx_int.ModelProperty(
        id: const obx_int.IdUid(3, 1931753384719971289),
        name: 'value',
        type: 9,
        flags: 0,
      ),
      obx_int.ModelProperty(
        id: const obx_int.IdUid(4, 2135522685203600902),
        name: 'updatedAt',
        type: 10,
        flags: 0,
      ),
    ],
    relations: <obx_int.ModelRelation>[],
    backlinks: <obx_int.ModelBacklink>[],
  ),
];

obx.Store openStore({
  String? directory,
  int? maxDBSizeInKB,
  int? maxDataSizeInKB,
  int? fileMode,
  int? maxReaders,
  bool queriesCaseSensitiveDefault = true,
  String? macosApplicationGroup,
}) {
  return obx.Store(
    getObjectBoxModel(),
    directory: directory,
    maxDBSizeInKB: maxDBSizeInKB,
    maxDataSizeInKB: maxDataSizeInKB,
    fileMode: fileMode,
    maxReaders: maxReaders,
    queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
    macosApplicationGroup: macosApplicationGroup,
  );
}

obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(

    generatorVersion: obx_int.GeneratorVersion.v2025_12_16,
    entities: _entities,
    lastEntityId: const obx_int.IdUid(1, 9008614968043148791),
    lastIndexId: const obx_int.IdUid(1, 2687854768547039603),
    lastRelationId: const obx_int.IdUid(0, 0),
    lastSequenceId: const obx_int.IdUid(0, 0),
    retiredEntityUids: const [],
    retiredIndexUids: const [],
    retiredPropertyUids: const [],
    retiredRelationUids: const [],
    modelVersion: 5,
    modelVersionParserMinimum: 5,
    version: 1,
  );

  final bindings = <Type, obx_int.EntityDefinition>{
    AppCacheEntry: obx_int.EntityDefinition<AppCacheEntry>(
      model: _entities[0],
      toOneRelations: (AppCacheEntry object) => [],
      toManyRelations: (AppCacheEntry object) => {},
      getId: (AppCacheEntry object) => object.id,
      setId: (AppCacheEntry object, int id) {
        object.id = id;
      },
      objectToFB: (AppCacheEntry object, fb.Builder fbb) {
        final keyOffset = fbb.writeString(object.key);
        final valueOffset = fbb.writeString(object.value);
        fbb.startTable(5);
        fbb.addInt64(0, object.id);
        fbb.addOffset(1, keyOffset);
        fbb.addOffset(2, valueOffset);
        fbb.addInt64(3, object.updatedAt.millisecondsSinceEpoch);
        fbb.finish(fbb.endTable());
        return object.id;
      },
      objectFromFB: (obx.Store store, ByteData fbData) {
        final buffer = fb.BufferContext(fbData);
        final rootOffset = buffer.derefObject(0);
        final idParam = const fb.Int64Reader().vTableGet(
          buffer,
          rootOffset,
          4,
          0,
        );
        final keyParam = const fb.StringReader(
          asciiOptimization: true,
        ).vTableGet(buffer, rootOffset, 6, '');
        final valueParam = const fb.StringReader(
          asciiOptimization: true,
        ).vTableGet(buffer, rootOffset, 8, '');
        final updatedAtParam = DateTime.fromMillisecondsSinceEpoch(
          const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0),
          isUtc: true,
        );
        final object = AppCacheEntry(
          id: idParam,
          key: keyParam,
          value: valueParam,
          updatedAt: updatedAtParam,
        );

        return object;
      },
    ),
  };

  return obx_int.ModelDefinition(model, bindings);
}

class AppCacheEntry_ {

  static final id = obx.QueryIntegerProperty<AppCacheEntry>(
    _entities[0].properties[0],
  );

  static final key = obx.QueryStringProperty<AppCacheEntry>(
    _entities[0].properties[1],
  );

  static final value = obx.QueryStringProperty<AppCacheEntry>(
    _entities[0].properties[2],
  );

  static final updatedAt = obx.QueryDateProperty<AppCacheEntry>(
    _entities[0].properties[3],
  );
}
