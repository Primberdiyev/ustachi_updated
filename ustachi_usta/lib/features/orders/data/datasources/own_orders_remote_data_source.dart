import 'package:dio/dio.dart';
import 'package:ustachi/core/api/api_urls.dart';
import 'package:ustachi/features/orders/data/models/own_order_model.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_entity.dart';
import 'package:ustachi/features/orders/domain/entities/own_order_payload.dart';

abstract class OwnOrdersRemoteDataSource {
  Future<List<OwnOrderEntity>> list({OwnOrderStatus? status});
  Future<OwnOrderEntity> detail(int id);
  Future<OwnOrderEntity> create(OwnOrderPayload payload);
  Future<OwnOrderEntity> update(int id, OwnOrderPayload payload);
  Future<OwnOrderEntity> setStatus(int id, OwnOrderStatus status);
  Future<void> remove(int id);
}

class OwnOrdersRemoteDataSourceImpl implements OwnOrdersRemoteDataSource {
  OwnOrdersRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  OwnOrderEntity _one(Object? data) =>
      OwnOrderModel.fromJson(Map<String, dynamic>.from(data as Map));

  @override
  Future<List<OwnOrderEntity>> list({OwnOrderStatus? status}) async {
    final response = await _dio.get(
      ApiUrls.myOrders,
      queryParameters: status == null ? null : {'status': status.wire},
    );
    return OwnOrderModel.listFrom(response.data);
  }

  @override
  Future<OwnOrderEntity> detail(int id) async {
    final response = await _dio.get(ApiUrls.myOrderDetail(id));
    return _one(response.data);
  }

  @override
  Future<OwnOrderEntity> create(OwnOrderPayload payload) async {
    final response = await _dio.post(ApiUrls.myOrders, data: payload.toJson());
    return _one(response.data);
  }

  @override
  Future<OwnOrderEntity> update(int id, OwnOrderPayload payload) async {
    final response =
        await _dio.put(ApiUrls.myOrderDetail(id), data: payload.toJson());
    return _one(response.data);
  }

  @override
  Future<OwnOrderEntity> setStatus(int id, OwnOrderStatus status) async {
    final response = await _dio.post(
      ApiUrls.myOrderStatus(id),
      data: {'status': status.wire},
    );
    return _one(response.data);
  }

  @override
  Future<void> remove(int id) => _dio.delete(ApiUrls.myOrderDetail(id));
}
