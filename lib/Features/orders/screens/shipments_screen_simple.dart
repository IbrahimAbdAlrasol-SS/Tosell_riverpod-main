// lib/Features/shipments/screens/shipments_screen.dart
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/providers/shipments_provider.dart';
import 'package:Tosell/Features/orders/screens/orders_filter_bottom_sheet.dart';
import 'package:Tosell/Features/orders/widgets/shipment_cart_item.dart';

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

class ShipmentsScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const ShipmentsScreen({super.key, this.filter});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShipmentsScreenState();
}

class _ShipmentsScreenState extends ConsumerState<ShipmentsScreen>
    with SingleTickerProviderStateMixin {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> _refresh() async {
    try {
      await ref.read(shipmentsNotifierProvider.notifier).getAll(page: 1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحديث البيانات: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant ShipmentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshKey.currentState?.show();
      });
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsState = ref.watch(shipmentsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpaces.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Gap(10),
                  Expanded(
                    child: CustomTextFormField(
                      label: '',
                      showLabel: false,
                      hint: 'رقم الوصل',
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
              const Gap(5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.filter == null
                      ? 'جميع الشحنات'
                      : 'الشحنات المفلترة',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              shipmentsState.when(
                data: _buildUi,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _buildErrorState(context, err),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildUi(List<Shipment> data) {
    return Expanded(
      child: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refresh,
        child: GenericPagedListView(
          noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
          fetchPage: (pageKey, _) async {
            return await ref.read(shipmentsNotifierProvider.notifier).getAll(
                  page: pageKey,
                  queryParams: widget.filter?.toJson(),
                );
          },
          itemBuilder: (context, shipment, index) => ShipmentCartItem(
            shipment: shipment,
            onTap: () => _navigateToShipmentDetails(shipment), // ✅ الإصلاح هنا
          ),
        ),
      ),
    );
  }

  Widget _buildNoItemsFound() {
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
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const Gap(AppSpaces.medium),
            Text(
              'حدث خطأ في جلب الشحنات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpaces.large),
            FillButton(
              label: "المحاولة مرة أخرى",
              onPressed: () => ref.refresh(shipmentsNotifierProvider),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ الوظيفة الجديدة لعرض تفاصيل الشحنة
  void _navigateToShipmentDetails(Shipment shipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_shipping, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text('تفاصيل الشحنة')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('رقم الشحنة:', shipment.code ?? 'غير محدد'),
              _buildDetailRow('عدد الطلبات:', '${shipment.ordersCount ?? 0}'),
              _buildDetailRow('عدد التجار:', '${shipment.merchantsCount ?? 0}'),
              _buildDetailRow('النوع:', _getShipmentTypeText(shipment.type ?? 0)),
              _buildDetailRow('الحالة:', _getShipmentStatusText(shipment.status ?? 0)),
              if (shipment.creationDate != null)
                _buildDetailRow('تاريخ الإنشاء:', _formatDate(shipment.creationDate!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.orders, extra: OrderFilter(
                shipmentId: shipment.id,
                shipmentCode: shipment.code,
              ));
            },
            child: const Text('عرض الطلبات'),
          ),
        ],
      ),
    );
  }

  // ✅ وظائف مساعدة للعرض
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  String _getShipmentTypeText(int type) {
    switch (type) {
      case 0: return 'استحصال';
      case 1: return 'توصيل';
      default: return 'غير محدد';
    }
  }

  String _getShipmentStatusText(int status) {
    if (status >= 0 && status < orderStatus.length) {
      return orderStatus[status].name ?? 'غير محدد';
    }
    return 'غير محدد';
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}