import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider لإدارة حالة التحديد المتعدد للطلبات
class SelectedOrdersNotifier extends StateNotifier<List<String>> {
  SelectedOrdersNotifier() : super([]);

  /// تفعيل/إلغاء تحديد طلب معين
  void toggleOrder(String orderId) {
    if (state.contains(orderId)) {
      // إزالة الطلب من القائمة
      state = state.where((id) => id != orderId).toList();
    } else {
      // إضافة الطلب للقائمة
      state = [...state, orderId];
    }
  }

  /// تحديد جميع الطلبات
  void selectAll(List<String> orderIds) {
    state = [...orderIds];
  }

  /// إلغاء تحديد جميع الطلبات
  void clearSelection() {
    state = [];
  }

  /// التحقق من تحديد طلب معين
  bool isSelected(String orderId) {
    return state.contains(orderId);
  }

  /// الحصول على عدد الطلبات المحددة
  int get selectedCount => state.length;

  /// التحقق من وجود طلبات محددة
  bool get hasSelection => state.isNotEmpty;

  /// الحصول على قائمة IDs الطلبات المحددة
  List<String> get selectedOrderIds => List.from(state);
}

/// Provider for selected orders
final selectedOrdersProvider = 
    StateNotifierProvider<SelectedOrdersNotifier, List<String>>(
  (ref) => SelectedOrdersNotifier(),
);

/// Provider لحالة وضع التحديد المتعدد
final selectionModeProvider = StateProvider<bool>((ref) => false);

/// Provider لحالة إنشاء الشحنة (loading state)
final createShipmentLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider للتبويب النشط (0 = طلبات, 1 = شحنات)
final activeTabProvider = StateProvider<int>((ref) => 0);