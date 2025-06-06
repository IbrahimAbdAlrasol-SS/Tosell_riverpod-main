import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/Features/order/models/add_order_form.dart';

class OrdersService {
  final BaseClient<Order> baseClient;

  OrdersService()
      : baseClient =
            BaseClient<Order>(fromJson: (json) => Order.fromJson(json));

  // For delegate/shipment orders (استحصال)
  Future<ApiResponse<Order>> getOrders(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/order/delegate', page: page, queryParams: queryParams);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // For merchant orders (original)
  Future<ApiResponse<Order>> getMerchantOrders(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/order/merchant', page: page, queryParams: queryParams);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // ✅ تم إصلاح المشكلة - تغيير id إلى code
  Future<(Order?, String?)> changeOrderState({required String code}) async {
    try {
      var result = await baseClient.update(endpoint: '/order/$code/status/received');
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  // Advance order step (for merchants)
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

  // ✅ تم إصلاح المشكلة - إضافة / قبل code
  Future<bool> validateCode({required String code}) async {
    try {
      var result =
          await BaseClient<bool>().get(endpoint: '/order/$code/available');
      return result.singleData ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order? order, String? error)> addOrder(
      {required AddOrderForm orderForm}) async {
    try {
      var result =
          await baseClient.create(endpoint: '/order', data: orderForm.toJson());
      if (result.singleData == null) return (null, result.message);

      return (result.singleData, null);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createShipment(Map<String, dynamic> shipmentData) async {
    try {
      var result = await baseClient.create(
        endpoint: '/shipment/pick-up', 
        data: shipmentData
      );
      
      return result.code == 200 || result.code == 201;
    } catch (e) {
      rethrow;
    }
  }
}