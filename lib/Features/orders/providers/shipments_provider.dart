// lib/Features/orders/providers/shipments_provider.dart - مصحح
import 'dart:async';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/services/shipments_service.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shipments_provider.g.dart';

@riverpod
class ShipmentsNotifier extends _$ShipmentsNotifier {
  final ShipmentsService _service = ShipmentsService();
  List<Shipment> _cachedShipments = []; // ✅ cache للبيانات

  Future<ApiResponse<Shipment>> getAll({
    int page = 1,
    Map<String, dynamic>? queryParams,
    bool forceRefresh = false, // ✅ خيار لإجبار التحديث
  }) async {
    try {
      final result = await _service.getAll(
        queryParams: queryParams, 
        page: page
      );
      
      // ✅ تحديث الـ cache
      if (page == 1 || forceRefresh) {
        _cachedShipments = result.data ?? [];
      } else {
        _cachedShipments.addAll(result.data ?? []);
      }
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ جلب شحنة معينة بالـ ID
  Shipment? getShipmentById(String shipmentId) {
    try {
      return _cachedShipments.firstWhere(
        (shipment) => shipment.id == shipmentId,
      );
    } catch (e) {
      return null;
    }
  }

  /// ✅ جلب شحنة معينة بالكود
  Shipment? getShipmentByCode(String shipmentCode) {
    try {
      return _cachedShipments.firstWhere(
        (shipment) => shipment.code == shipmentCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// ✅ تحديث شحنة معينة في الـ cache
  void updateShipmentInCache(Shipment updatedShipment) {
    final index = _cachedShipments.indexWhere(
      (shipment) => shipment.id == updatedShipment.id,
    );
    
    if (index != -1) {
      _cachedShipments[index] = updatedShipment;
      // تحديث الـ state
      state = AsyncValue.data(_cachedShipments);
    }
  }

  /// ✅ إضافة شحنة جديدة للـ cache
  void addShipmentToCache(Shipment newShipment) {
    _cachedShipments.insert(0, newShipment); // إضافة في المقدمة
    state = AsyncValue.data(_cachedShipments);
  }

  /// ✅ مسح الـ cache
  void clearCache() {
    _cachedShipments.clear();
  }

  /// ✅ إحصائيات سريعة
  Map<String, int> getQuickStats() {
    final totalShipments = _cachedShipments.length;
    final totalOrders = _cachedShipments.fold<int>(
      0, 
      (sum, shipment) => sum + (shipment.ordersCount ?? 0),
    );
    final totalMerchants = _cachedShipments.fold<int>(
      0, 
      (sum, shipment) => sum + (shipment.merchantsCount ?? 0),
    );

    return {
      'totalShipments': totalShipments,
      'totalOrders': totalOrders,
      'totalMerchants': totalMerchants,
    };
  }

  @override
  FutureOr<List<Shipment>> build() async {
    try {
      var result = await getAll();
      return result.data ?? [];
    } catch (e) {
      throw e;
    }
  }
}