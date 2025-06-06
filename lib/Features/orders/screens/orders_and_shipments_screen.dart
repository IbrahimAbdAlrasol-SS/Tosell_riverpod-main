// lib/Features/orders/screens/orders_and_shipments_screen.dart
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/widgets/order_card_item.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';
import 'package:Tosell/Features/orders/providers/orders_selection_provider.dart';
import 'package:Tosell/Features/orders/providers/shipments_provider.dart';
import 'package:Tosell/Features/orders/widgets/shipment_cart_item.dart';
import 'package:Tosell/Features/orders/screens/orders_filter_bottom_sheet.dart';
import 'package:Tosell/Features/orders/services/orders_service.dart';

class OrdersAndShipmentsScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersAndShipmentsScreen({super.key, this.filter});

  @override
  ConsumerState<OrdersAndShipmentsScreen> createState() => _OrdersAndShipmentsScreenState();
}

class _OrdersAndShipmentsScreenState extends ConsumerState<OrdersAndShipmentsScreen> {
  late OrderFilter? _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    _fetchInitialData();
  }

  void _fetchInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // جلب الطلبات
      ref.read(ordersNotifierProvider.notifier).getAll(
        page: 1,
        queryParams: _currentFilter?.toJson(),
      );
      
      // جلب الشحنات إذا كان التبويب نشط
      if (ref.read(activeTabProvider) == 1) {
        ref.read(shipmentsNotifierProvider.notifier).getAll(page: 1);
      }
    });
  }

  @override
  void didUpdateWidget(covariant OrdersAndShipmentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
      _fetchInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(activeTabProvider);
    final selectionMode = ref.watch(selectionModeProvider);
    final selectedOrders = ref.watch(selectedOrdersProvider);
    final createShipmentLoading = ref.watch(createShipmentLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpaces.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط البحث والفلترة
              _buildSearchAndFilterBar(),
              
              const Gap(8),
              
              // التبويبات المحسنة
              _buildImprovedTabs(activeTab),
              
              const Gap(5),
              
              // عنوان القسم مع أزرار التحكم
              _buildSectionHeader(activeTab, selectionMode, selectedOrders.length),
              
              // المحتوى حسب التبويب النشط
              Expanded(
                child: activeTab == 0 
                  ? _buildOrdersTab(selectionMode)
                  : _buildShipmentsTab(),
              ),
              
              // زر إنشاء الشحنة (يظهر فقط عند تحديد طلبات)
              if (selectionMode && selectedOrders.isNotEmpty)
                _buildCreateShipmentButton(selectedOrders.length, createShipmentLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Row(
      children: [
        const Gap(10),
        Expanded(
          child: CustomTextFormField(
            label: '',
            showLabel: false,
            hint: 'رقم الطلب',
            prefixInner: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/svg/search.svg',
                color: Theme.of(context).colorScheme.primary,
                width: 3,
                height: 3,
              ),
            ),
          ),
        ),
        const Gap(AppSpaces.medium),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (_) => const OrdersFilterBottomSheet(),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.filter?.status == null
                          ? Theme.of(context).colorScheme.outline
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/svg/Funnel.svg',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              if (widget.filter != null)
                Positioned(
                  top: 6,
                  right: 10,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// تبويبات محسنة ومصغرة
  Widget _buildImprovedTabs(int activeTab) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildCompactTabItem(
              title: 'الطلبات',
              isActive: activeTab == 0,
              onTap: () => _switchTab(0),
            ),
            _buildCompactTabItem(
              title: 'الشحنات',
              isActive: activeTab == 1,
              onTap: () => _switchTab(1),
            ),
          ],
        ),
      ),
    );
  }

  /// عنصر تبويب مضغوط
  Widget _buildCompactTabItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive 
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isActive ? [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive 
                  ? Colors.white
                  : Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(int activeTab, bool selectionMode, int selectedCount) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              activeTab == 0
                ? (widget.filter == null
                    ? 'جميع الطلبات'
                    : 'جميع الطلبات "${orderStatus[widget.filter?.status ?? 0].name}"')
                : 'جميع الشحنات',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          
          // أزرار التحكم للطلبات فقط
          if (activeTab == 0) ...[
            // عداد التحديد
            if (selectionMode && selectedCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'تم تحديد $selectedCount طلب',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            
            const Gap(AppSpaces.small),
            
            // قائمة التحكم
            if (selectionMode)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onSelected: (value) {
                  if (value == 'select_all') {
                    _selectAllOrders();
                  } else if (value == 'clear_all') {
                    ref.read(selectedOrdersProvider.notifier).clearSelection();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'select_all',
                    child: Row(
                      children: [
                        Icon(Icons.select_all, size: 20),
                        Gap(AppSpaces.small),
                        Text('تحديد الكل'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, size: 20),
                        Gap(AppSpaces.small),
                        Text('إلغاء التحديد'),
                      ],
                    ),
                  ),
                ],
              ),
            
            // زر التحديد المتعدد
            GestureDetector(
              onTap: _toggleSelectionMode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selectionMode 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  selectionMode ? Icons.close : Icons.checklist,
                  color: selectionMode 
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrdersTab(bool selectionMode) {
    final ordersState = ref.watch(ordersNotifierProvider);
    
    return ordersState.when(
      data: (data) => GenericPagedListView(
        key: ValueKey(widget.filter?.toJson()),
        noItemsFoundIndicatorBuilder: _buildNoOrdersFound(),
        fetchPage: (pageKey, _) async {
          return await ref.read(ordersNotifierProvider.notifier).getAll(
            page: pageKey,
            queryParams: _currentFilter?.toJson(),
          );
        },
        itemBuilder: (context, order, index) => OrderCardItem(
          order: order,
          isSelectionMode: selectionMode,
          onTap: () {
            if (!selectionMode) {
              context.push(AppRoutes.orderDetails, extra: order.code);
            }
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(err.toString())),
    );
  }

  Widget _buildShipmentsTab() {
    final shipmentsState = ref.watch(shipmentsNotifierProvider);
    
    return shipmentsState.when(
      data: (data) => GenericPagedListView(
        noItemsFoundIndicatorBuilder: _buildNoShipmentsFound(),
        fetchPage: (pageKey, _) async {
          return await ref.read(shipmentsNotifierProvider.notifier).getAll(
            page: pageKey,
          );
        },
        itemBuilder: (context, shipment, index) => ShipmentCartItem(
          shipment: shipment,
          onTap: () => _navigateToShipmentDetails(shipment),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const Gap(AppSpaces.medium),
            Text(
              'حدث خطأ في جلب الشحنات',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(AppSpaces.small),
            Text(
              err.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateShipmentButton(int selectedCount, bool isLoading) {
    return Container(
      padding: AppSpaces.allMedium,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: FillButton(
        label: "إنشاء شحنة ($selectedCount)",
        isLoading: isLoading,
        onPressed: _createShipment,
        icon: SvgPicture.asset(
          "assets/svg/box.svg", // استخدام أيقونة متاحة
          color: Colors.white,
          width: 24,
          height: 24,
        ),
        reverse: true,
      ),
    );
  }

  Widget _buildNoOrdersFound() {
    return Column(
      children: [
        Image.asset('assets/svg/NoItemsFound.gif', width: 240, height: 240),
        Text(
          'لا توجد طلبات مضافة',
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xffE96363),
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'اضغط على زر "جديد" لإضافة طلب جديد و ارساله الى زبونك',
          style: context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xff698596),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: FillButton(
            label: 'إضافة اول طلب',
            onPressed: () => context.push(AppRoutes.addOrder),
            icon: SvgPicture.asset('assets/svg/navigation_add.svg',
                color: const Color(0xffFAFEFD)),
            reverse: true,
          ),
        )
      ],
    );
  }

  Widget _buildNoShipmentsFound() {
    return Column(
      children: [
        Image.asset(
          'assets/svg/NoItemsFound.gif',
          width: 240,
          height: 240,
        ),
        const Gap(AppSpaces.medium),
        Text(
          'لاتوجد شحنات',
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.primary,
            fontSize: 24,
          ),
        ),
        const Gap(AppSpaces.small),
        Text(
          'يمكنك إنشاء شحنات من خلال تحديد طلبات في تبويب الطلبات',
          style: context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w400,
            color: context.colorScheme.secondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _switchTab(int tabIndex) {
    ref.read(activeTabProvider.notifier).state = tabIndex;
    
    // إلغاء وضع التحديد عند تغيير التبويب
    if (tabIndex == 1) {
      ref.read(selectionModeProvider.notifier).state = false;
      ref.read(selectedOrdersProvider.notifier).clearSelection();
      
      // جلب بيانات الشحنات إذا لم تكن محملة
      ref.read(shipmentsNotifierProvider.notifier).getAll(page: 1);
    }
  }

  void _toggleSelectionMode() {
    final currentMode = ref.read(selectionModeProvider);
    ref.read(selectionModeProvider.notifier).state = !currentMode;
    
    // مسح التحديدات عند إلغاء الوضع
    if (currentMode) {
      ref.read(selectedOrdersProvider.notifier).clearSelection();
    }
  }

  void _selectAllOrders() {
    final ordersState = ref.read(ordersNotifierProvider);
    ordersState.whenData((orders) {
      final orderIds = orders
          .map((order) => order.id ?? order.code ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      ref.read(selectedOrdersProvider.notifier).selectAll(orderIds);
    });
  }

  /// إنشاء الشحنة
  Future<void> _createShipment() async {
    final selectedOrderIds = ref.read(selectedOrdersProvider);
    if (selectedOrderIds.isEmpty) return;

    ref.read(createShipmentLoadingProvider.notifier).state = true;
    
    try {
      final success = await OrdersService().createShipment(
        orderIds: selectedOrderIds,
        delivered: true,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم إنشاء الشحنة بنجاح"),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // إعادة تعيين الحالة
        ref.read(selectionModeProvider.notifier).state = false;
        ref.read(selectedOrdersProvider.notifier).clearSelection();
        
        // تحديث البيانات
        _fetchInitialData();
        
        // التنقل لتبويب الشحنات
        _switchTab(1);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("فشل في إنشاء الشحنة"),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ: ${e.toString()}"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      ref.read(createShipmentLoadingProvider.notifier).state = false;
    }
  }

  /// التنقل لتفاصيل الشحنة
  void _navigateToShipmentDetails(shipment) {
    try {
      // يمكن إضافة route مخصص هنا
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('تفاصيل الشحنة ${shipment.code}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رقم الشحنة: ${shipment.code ?? "غير محدد"}'),
              Text('عدد الطلبات: ${shipment.ordersCount ?? 0}'),
              Text('عدد التجار: ${shipment.merchantsCount ?? 0}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.orders,
                    extra: OrderFilter(
                        shipmentId: shipment.id, 
                        shipmentCode: shipment.code));
              },
              child: const Text('عرض الطلبات'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في فتح تفاصيل الشحنة: $e')),
      );
    }
  }
}