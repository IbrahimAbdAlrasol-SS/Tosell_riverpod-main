// lib/Features/orders/services/shipments_service.dart - محسن
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';

class ShipmentsService {
  final BaseClient<Shipment> baseClient;

  ShipmentsService()
      : baseClient =
            BaseClient<Shipment>(fromJson: (json) => Shipment.fromJson(json));

  /// ✅ جلب جميع الشحنات - محدث
  Future<ApiResponse<Shipment>> getAll({
    int page = 1, 
    Map<String, dynamic>? queryParams
  }) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/shipment/merchant/my-shipments', 
          page: page,
          queryParams: queryParams);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ جلب شحنة معينة بالـ ID
  Future<Shipment?> getShipmentById(String shipmentId) async {
    try {
      var result = await baseClient.getById(
        endpoint: '/shipment', 
        id: shipmentId
      );
      return result.singleData;
    } catch (e) {
      // في حالة عدم وجود endpoint محدد، نعيد null
      return null;
    }
  }

  /// ✅ جلب شحنة معينة بالكود
  Future<Shipment?> getShipmentByCode(String shipmentCode) async {
    try {
      // يمكن استخدام endpoint مختلف للبحث بالكود
      var result = await baseClient.get(
        endpoint: '/shipment/code/$shipmentCode'
      );
      return result.singleData;
    } catch (e) {
      return null;
    }
  }

  /// ✅ إنشاء شحنة جديدة - محسن
  Future<(Shipment?, String?)> createShipment(Map<String, dynamic> shipmentData) async {
    try {
      var result = await baseClient.create(
        endpoint: '/shipment/pick-up', 
        data: shipmentData
      );
      
      if (result.code == 200 || result.code == 201) {
        return (result.singleData, null);
      } else {
        return (null, result.message ?? 'فشل في إنشاء الشحنة');
      }
    } catch (e) {
      return (null, e.toString());
    }
  }

  /// ✅ تحديث حالة الشحنة
  Future<(Shipment?, String?)> updateShipmentStatus({
    required String shipmentId,
    required int newStatus,
  }) async {
    try {
      var result = await baseClient.update(
        endpoint: '/shipment/$shipmentId/status',
        data: {'status': newStatus}
      );
      
      if (result.code == 200) {
        return (result.singleData, null);
      } else {
        return (null, result.message ?? 'فشل في تحديث حالة الشحنة');
      }
    } catch (e) {
      return (null, e.toString());
    }
  }

  /// ✅ جلب طلبات شحنة معينة
  Future<ApiResponse<dynamic>> getShipmentOrders({
    required String shipmentId,
    int page = 1,
  }) async {
    try {
      var result = await BaseClient().getAll(
        endpoint: '/shipment/$shipmentId/orders',
        page: page,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ إحصائيات الشحنة
  Future<Map<String, dynamic>?> getShipmentStatistics(String shipmentId) async {
    try {
      var result = await BaseClient().get(
        endpoint: '/shipment/$shipmentId/statistics'
      );
      return result.singleData;
    } catch (e) {
      return null;
    }
  }

  /// ✅ حذف شحنة
  Future<bool> deleteShipment(String shipmentId) async {
    try {
      var result = await baseClient.delete('/shipment/$shipmentId');
      return result.code == 200;
    } catch (e) {
      return false;
    }
  }

  /// ✅ البحث في الشحنات
  Future<ApiResponse<Shipment>> searchShipments({
    required String searchTerm,
    int page = 1,
  }) async {
    try {
      var result = await baseClient.getAll(
        endpoint: '/shipment/search',
        page: page,
        queryParams: {'q': searchTerm}
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }
}