// lib/Features/orders/screens/orders_screen.dart
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/Features/auth/models/User.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/widgets/order_card_item.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';
import 'package:Tosell/Features/orders/screens/orders_filter_bottom_sheet.dart';
import 'package:Tosell/Features/orders/services/orders_service.dart';
// تأكد من وجود هذا في orders_screen.dart
import 'package:Tosell/Features/orders/services/orders_service.dart';
// ✅ إضافة providers بسيطة للتحديد المتعدد
final selectedOrdersProvider = StateProvider<Set<String>>((ref) => {});
final selectionModeProvider = StateProvider<bool>((ref) => false);
final createShipmentLoadingProvider = StateProvider<bool>((ref) => false);

class OrdersScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersScreen({super.key, this.filter});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  late OrderFilter? _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    _fetchInitialOrders();
  }

  void _fetchInitialOrders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersNotifierProvider.notifier).getAll(
        page: 1,
        queryParams: _currentFilter?.toJson(),
      );
    });
  }

  @override
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
      _fetchInitialOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersNotifierProvider);
    final selectedOrders = ref.watch(selectedOrdersProvider);
    final isSelectionMode = ref.watch(selectionModeProvider);
    final isCreatingShipment = ref.watch(createShipmentLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpaces.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط البحث والفلترة الموجود
              Row(
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
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // ✅ شريط التحكم بالتحديد المتعدد
              if (isSelectionMode)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.checklist,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تم تحديد ${selectedOrders.length} طلب',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      
                      // زر تحديد الكل / إلغاء تحديد الكل
                      if (selectedOrders.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            ref.read(selectedOrdersProvider.notifier).state = {};
                          },
                          child: Text(
                            'إلغاء الكل',
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      
                      TextButton(
                        onPressed: () {
                          ref.read(selectedOrdersProvider.notifier).state = {};
                          ref.read(selectionModeProvider.notifier).state = false;
                        },
                        child: const Text('إنهاء التحديد'),
                      ),
                    ],
                  ),
                ),

              const Gap(5),
              
              // العنوان مع زر التحديد المتعدد
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.filter == null
                            ? 'جميع الطلبات'
                            : 'جميع الطلبات "${orderStatus[widget.filter?.status ?? 0].name}"',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    // ✅ زر تفعيل وضع التحديد المتعدد
                    GestureDetector(
                      onTap: () {
                        final currentMode = ref.read(selectionModeProvider);
                        ref.read(selectionModeProvider.notifier).state = !currentMode;
                        if (!currentMode) {
                          // مسح التحديدات عند تفعيل الوضع
                          ref.read(selectedOrdersProvider.notifier).state = {};
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelectionMode 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
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
                          isSelectionMode ? Icons.close : Icons.checklist,
                          color: isSelectionMode 
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // المحتوى
              ordersState.when(
                data: (data) => _buildUi(data, isSelectionMode),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text(err.toString())),
              ),
              
              // ✅ زر إنشاء الشحنة (يظهر عند تحديد طلبات)
              if (isSelectionMode && selectedOrders.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: FillButton(
                    label: "إنشاء شحنة (${selectedOrders.length})",
                    isLoading: isCreatingShipment,
                    onPressed: isCreatingShipment ? null : () => _createShipment(),
                    icon: SvgPicture.asset(
                      "assets/svg/box.svg",
                      color: Colors.white,
                      width: 24,
                      height: 24,
                    ),
                    reverse: true,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildUi(List<Order> data, bool isSelectionMode) {
    return Expanded(
      child: GenericPagedListView(
        key: ValueKey(widget.filter?.toJson()),
        noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
        fetchPage: (pageKey, _) async {
          return await ref.read(ordersNotifierProvider.notifier).getAll(
            page: pageKey,
            queryParams: _currentFilter?.toJson(),
          );
        },
        itemBuilder: (context, order, index) => OrderCardItem(
          order: order,
          isSelectionMode: isSelectionMode, // ✅ تمرير وضع التحديد
          onTap: () {
            if (!isSelectionMode) {
              context.push(AppRoutes.orderDetails, extra: order.code);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNoItemsFound() {
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

  // ✅ وظيفة إنشاء الشحنة
  Future<void> _createShipment() async {
    final selectedOrderIds = ref.read(selectedOrdersProvider).toList();
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
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text("تم إنشاء الشحنة بنجاح (${selectedOrderIds.length} طلبات)"),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        // إعادة تعيين الحالة
        ref.read(selectionModeProvider.notifier).state = false;
        ref.read(selectedOrdersProvider.notifier).state = {};
        
        // تحديث البيانات
        ref.refresh(ordersNotifierProvider);
        
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text("فشل في إنشاء الشحنة"),
                ],
              ),
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
}