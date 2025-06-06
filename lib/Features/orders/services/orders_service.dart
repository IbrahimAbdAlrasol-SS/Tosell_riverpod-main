// lib/Features/orders/services/orders_service.dart
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/Features/order/models/add_order_form.dart';

class OrdersService {
  final BaseClient<Order> baseClient;

  OrdersService()
      : baseClient =
            BaseClient<Order>(fromJson: (json) => Order.fromJson(json));

  Future<ApiResponse<Order>> getOrders(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/order/merchant', page: page, queryParams: queryParams);
      return result;
    } catch (e) {
      rethrow;
    }
  }


  // For delegate/shipment orders (استحصال)
  Future<ApiResponse<Order>> getDelegateOrders(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/order/delegate', page: page, queryParams: queryParams);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // تغيير حالة الطلب
  Future<(Order?, String?)> changeOrderState({required String code}) async {
    try {
      var result = await baseClient.update(endpoint: '/order/$code/status/received');
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  // تقدم خطوة الطلب (للتجار)
  Future<(Order?, String?)> advanceOrderStep({required String code}) async {
    try {
      var result = await baseClient.update(endpoint: '/order/$code/advance-step');
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<Order?>? getOrderById({required String id}) async {
    try {
      var result = await baseClient.getById(endpoint: '/order', id: id);
      return result.singleData;
    } catch (e) {
      rethrow;
    }
  }

  Future<Order?>? getOrderByCode({required String code}) async {
    try {
      var result = await baseClient.getById(endpoint: '/order', id: code);
      return result.singleData;
    } catch (e) {
      rethrow;
    }
  }

  // التحقق من توفر الكود
  Future<bool> validateCode({required String code}) async {
    try {
      var result =
          await BaseClient<bool>().get(endpoint: '/order/$code/available');
      return result.singleData ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order? order, String? error)> addOrder(AddOrderForm form) async {
    try {
      var result =
          await baseClient.create(endpoint: '/order', data: form.toJson());
      if (result.singleData == null) return (null, result.message);
      return (result.singleData, null);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createShipment({
    required List<String> orderIds,
    String? delegateId,
    String? merchantId,
    bool delivered = true,
  }) async {
    try {
      // تحضير البيانات حسب ما طلبه الباك إند
      Map<String, dynamic> shipmentData = {
        "orders": orderIds.map((id) => {"orderId": id}).toList(),
      };

      // إضافة البيانات الاختيارية فقط إذا كانت موجودة
      if (delivered) {
        shipmentData["delivered"] = delivered;
      }
      
      if (delegateId != null && delegateId.isNotEmpty) {
        shipmentData["delegateId"] = delegateId;
      }
      
      if (merchantId != null && merchantId.isNotEmpty) {
        shipmentData["merchantId"] = merchantId;
      }

      var result = await baseClient.create(
        endpoint: '/shipment/pick-up', 
        data: shipmentData
      );
      
      return result.code == 200 || result.code == 201;
    } catch (e) {
      rethrow;
    }
  }


  // ✅ إنشاء شحنة محسنة مع إرجاع بيانات الشحنة
  Future<(bool success, String? shipmentId, String? error)> createShipmentAdvanced({
    required List<String> orderIds,
    String? delegateId,
    String? merchantId,
    bool delivered = true,
  }) async {
    try {
      Map<String, dynamic> shipmentData = {
        "orders": orderIds.map((id) => {"orderId": id}).toList(),
      };

      if (delivered) {
        shipmentData["delivered"] = delivered;
      }
      
      if (delegateId != null && delegateId.isNotEmpty) {
        shipmentData["delegateId"] = delegateId;
      }
      
      if (merchantId != null && merchantId.isNotEmpty) {
        shipmentData["merchantId"] = merchantId;
      }

      var result = await baseClient.create(
        endpoint: '/shipment/pick-up', 
        data: shipmentData
      );
      
      if (result.code == 200 || result.code == 201) {
        return (true, result.singleData?.id, null);
      } else {
        return (false, null, result.message ?? 'فشل في إنشاء الشحنة');
      }
    } catch (e) {
      return (false, null, e.toString());
    }
  }
}