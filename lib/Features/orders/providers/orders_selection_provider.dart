// lib/Features/orders/providers/orders_selection_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ✅ Provider لإدارة حالة التحديد المتعدد للطلبات 
class SelectedOrdersNotifier extends StateNotifier<List<String>> {
  SelectedOrdersNotifier() : super([]);

  /// تفعيل/إلغاء تحديد طلب معين
  void toggleOrder(String orderId) {
    if (orderId.isEmpty) return;
    
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
    final validIds = orderIds.where((id) => id.isNotEmpty).toList();
    state = [...validIds];
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

/// ✅ Provider for selected orders - النسخة الرئيسية الوحيدة
final selectedOrdersProvider = 
    StateNotifierProvider<SelectedOrdersNotifier, List<String>>(
  (ref) => SelectedOrdersNotifier(),
);

/// ✅ Provider لحالة وضع التحديد المتعدد
final selectionModeProvider = StateProvider<bool>((ref) => false);

/// ✅ Provider لحالة إنشاء الشحنة (loading state)
final createShipmentLoadingProvider = StateProvider<bool>((ref) => false);

/// ✅ Provider للتبويب النشط (0 = طلبات, 1 = شحنات)
final activeTabProvider = StateProvider<int>((ref) => 0);

/// ✅ Helper لتنظيف جميع Providers
class SelectionProvidersHelper {
  
  /// تنظيف جميع حالات التحديد
  static void cleanupAllSelectionState(WidgetRef ref) {
    try {
      ref.read(selectionModeProvider.notifier).state = false;
      ref.read(selectedOrdersProvider.notifier).clearSelection();
      ref.read(createShipmentLoadingProvider.notifier).state = false;
    } catch (e) {
      debugPrint('Selection cleanup error (safe to ignore): $e');
    }
  }

  /// تنظيف حالة التبويبات
  static void cleanupTabState(WidgetRef ref) {
    try {
      ref.read(activeTabProvider.notifier).state = 0;
    } catch (e) {
      debugPrint('Tab cleanup error (safe to ignore): $e');
    }
  }

  /// تنظيف شامل لجميع الحالات
  static void fullCleanup(WidgetRef ref) {
    cleanupAllSelectionState(ref);
    cleanupTabState(ref);
  }

  /// التحقق من سلامة الـ state قبل العمليات المهمة
  static bool isStateHealthy(WidgetRef ref) {
    try {
      // فحص أساسي للـ providers
      ref.read(selectionModeProvider);
      ref.read(selectedOrdersProvider);
      ref.read(activeTabProvider);
      ref.read(createShipmentLoadingProvider);
      return true;
    } catch (e) {
      debugPrint('State health check failed: $e');
      return false;
    }
  }

  /// إعادة تهيئة آمنة للـ state
  static void safeStateReset(WidgetRef ref) {
    if (!isStateHealthy(ref)) {
      debugPrint('State unhealthy, performing safe reset...');
      // محاولة إعادة التهيئة بعد فريم واحد
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fullCleanup(ref);
      });
    }
  }

  /// تفعيل وضع التحديد بأمان
  static void enableSelectionMode(WidgetRef ref) {
    try {
      ref.read(selectionModeProvider.notifier).state = true;
      ref.read(selectedOrdersProvider.notifier).clearSelection();
    } catch (e) {
      debugPrint('Enable selection mode error: $e');
    }
  }

  /// إلغاء وضع التحديد بأمان
  static void disableSelectionMode(WidgetRef ref) {
    try {
      ref.read(selectionModeProvider.notifier).state = false;
      ref.read(selectedOrdersProvider.notifier).clearSelection();
    } catch (e) {
      debugPrint('Disable selection mode error: $e');
    }
  }
}

/// ✅ Mixin للاستخدام في الصفحات التي تحتاج تنظيف state
mixin SelectionStateCleanupMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  
  @override
  void dispose() {
    // تنظيف تلقائي عند dispose
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SelectionProvidersHelper.fullCleanup(ref);
    });
    super.dispose();
  }

  /// تنظيف آمن يمكن استدعاؤه يدوياً
  void cleanupSelectionState() {
    SelectionProvidersHelper.fullCleanup(ref);
  }

  /// فحص سلامة الـ state
  bool get isSelectionStateHealthy => SelectionProvidersHelper.isStateHealthy(ref);

  /// تفعيل وضع التحديد
  void enableSelectionMode() {
    SelectionProvidersHelper.enableSelectionMode(ref);
  }

  /// إلغاء وضع التحديد
  void disableSelectionMode() {
    SelectionProvidersHelper.disableSelectionMode(ref);
  }
}