// lib/Features/orders/utils/state_cleanup_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/orders/providers/orders_selection_provider.dart';

/// ✅ مساعد لتنظيف الـ state ومنع التضارب
class StateCleanupHelper {
  
  /// تنظيف جميع providers المتعلقة بالتحديد
  static void cleanupSelectionState(WidgetRef ref) {
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
    cleanupSelectionState(ref);
    cleanupTabState(ref);
  }

  /// التحقق من سلامة الـ state قبل العمليات المهمة
  static bool isStateHealthy(WidgetRef ref) {
    try {
      // فحص أساسي للـ providers
      ref.read(selectionModeProvider);
      ref.read(selectedOrdersProvider);
      ref.read(activeTabProvider);
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
      // محاولة إعادة التهيئة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fullCleanup(ref);
      });
    }
  }
}

/// ✅ Mixin للاستخدام في الصفحات التي تحتاج تنظيف state
mixin StateCleanupMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  
  @override
  void dispose() {
    // تنظيف تلقائي عند dispose
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StateCleanupHelper.fullCleanup(ref);
    });
    super.dispose();
  }

  /// تنظيف آمن يمكن استدعاؤه يدوياً
  void cleanupState() {
    StateCleanupHelper.fullCleanup(ref);
  }

  /// فحص سلامة الـ state
  bool get isStateHealthy => StateCleanupHelper.isStateHealthy(ref);
}