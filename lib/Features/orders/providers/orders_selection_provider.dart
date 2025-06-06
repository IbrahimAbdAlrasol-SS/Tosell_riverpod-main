// lib/Features/orders/providers/orders_selection_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedOrdersNotifier extends StateNotifier<List<String>> {
  SelectedOrdersNotifier() : super([]);

  /// تبديل حالة تحديد طلب معين
  void toggleOrder(String orderId) {
    if (orderId.isEmpty) return;
    
    if (state.contains(orderId)) {
      state = state.where((id) => id != orderId).toList();
    } else {
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

  /// تحديد طلب واحد فقط
  void selectSingle(String orderId) {
    if (orderId.isEmpty) return;
    state = [orderId];
  }

  /// إزالة طلبات معينة من التحديد
  void removeOrders(List<String> orderIds) {
    state = state.where((id) => !orderIds.contains(id)).toList();
  }

  /// إضافة طلبات متعددة للتحديد
  void addOrders(List<String> orderIds) {
    final validIds = orderIds.where((id) => id.isNotEmpty && !state.contains(id)).toList();
    state = [...state, ...validIds];
  }

  /// التحقق من تحديد طلب معين
  bool isSelected(String orderId) {
    return state.contains(orderId);
  }

  /// الحصول على عدد الطلبات المحددة
  int get selectedCount => state.length;

  /// التحقق من وجود طلبات محددة
  bool get hasSelection => state.isNotEmpty;

  /// التحقق من تحديد جميع الطلبات
  bool isAllSelected(List<String> allOrderIds) {
    if (allOrderIds.isEmpty) return false;
    return allOrderIds.every((id) => state.contains(id));
  }

  List<String> get selectedOrderIds => List.from(state);

  bool get canCreateShipment => state.isNotEmpty;
}

final selectedOrdersProvider = 
    StateNotifierProvider<SelectedOrdersNotifier, List<String>>(
  (ref) => SelectedOrdersNotifier(),
);

final selectionModeProvider = StateProvider<bool>((ref) => false);

final createShipmentLoadingProvider = StateProvider<bool>((ref) => false);

final activeTabProvider = StateProvider<int>((ref) => 0);

final selectAllModeProvider = StateProvider<bool>((ref) => false);

final selectionInfoProvider = Provider<SelectionInfo>((ref) {
  final selectedOrders = ref.watch(selectedOrdersProvider);
  final selectionMode = ref.watch(selectionModeProvider);
  final createShipmentLoading = ref.watch(createShipmentLoadingProvider);
  
  return SelectionInfo(
    selectedCount: selectedOrders.length,
    hasSelection: selectedOrders.isNotEmpty,
    isSelectionMode: selectionMode,
    isCreatingShipment: createShipmentLoading,
    canCreateShipment: selectedOrders.isNotEmpty && !createShipmentLoading,
  );
});

class SelectionInfo {
  final int selectedCount;
  final bool hasSelection;
  final bool isSelectionMode;
  final bool isCreatingShipment;
  final bool canCreateShipment;

  const SelectionInfo({
    required this.selectedCount,
    required this.hasSelection,
    required this.isSelectionMode,
    required this.isCreatingShipment,
    required this.canCreateShipment,
  });
}

extension SelectedOrdersProviderExtension on WidgetRef {
  SelectedOrdersNotifier get selectedOrdersNotifier => 
      read(selectedOrdersProvider.notifier);

  bool isOrderSelected(String orderId) => 
      read(selectedOrdersProvider).contains(orderId);

  void toggleSelectionMode() {
    final currentMode = read(selectionModeProvider);
    read(selectionModeProvider.notifier).state = !currentMode;
    
    if (currentMode) {
      selectedOrdersNotifier.clearSelection();
    }
  }

  void toggleSelectAll(List<String> allOrderIds) {
    final currentSelection = read(selectedOrdersProvider);
    final isAllSelected = allOrderIds.every((id) => currentSelection.contains(id));
    
    if (isAllSelected) {
      selectedOrdersNotifier.clearSelection();
    } else {
      selectedOrdersNotifier.selectAll(allOrderIds);
    }
  }
}