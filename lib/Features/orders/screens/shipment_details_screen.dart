// lib/Features/orders/screens/shipment_details_screen.dart
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
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/widgets/order_card_item.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';
import 'package:Tosell/Features/orders/services/shipments_service.dart';

class ShipmentDetailsScreen extends ConsumerStatefulWidget {
  final String shipmentId;
  final String? shipmentCode;
  
  const ShipmentDetailsScreen({
    super.key, 
    required this.shipmentId,
    this.shipmentCode,
  });

  @override
  ConsumerState<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends ConsumerState<ShipmentDetailsScreen> {
  Shipment? _shipment;
  bool _isLoadingShipment = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadShipmentDetails();
  }

  Future<void> _loadShipmentDetails() async {
    setState(() {
      _isLoadingShipment = true;
      _error = null;
    });

    try {
      final shipmentsService = ShipmentsService();
      final shipment = await shipmentsService.getShipmentById(widget.shipmentId);
      
      if (mounted) {
        setState(() {
          _shipment = shipment;
          _isLoadingShipment = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingShipment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // شريط التطبيق المخصص
            CustomAppBar(
              title: "تفاصيل الشحنة",
              subtitle: widget.shipmentCode ?? widget.shipmentId,
              showBackButton: true,
            ),
            
            // محتوى الصفحة
            Expanded(
              child: _isLoadingShipment
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState()
                      : _buildShipmentContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            'حدث خطأ في جلب تفاصيل الشحنة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(AppSpaces.small),
          Text(
            _error ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(AppSpaces.large),
          FillButton(
            label: "المحاولة مرة أخرى",
            onPressed: _loadShipmentDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentContent() {
    if (_shipment == null) {
      return const Center(
        child: Text('لم يتم العثور على تفاصيل الشحنة'),
      );
    }

    return Column(
      children: [
        // تفاصيل الشحنة
        _buildShipmentInfo(),
        
        const Gap(AppSpaces.medium),
        
        // عنوان الطلبات
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpaces.medium),
          child: Row(
            children: [
              Icon(
                Icons.list_alt,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const Gap(AppSpaces.small),
              Text(
                'طلبات الشحنة (${_shipment!.ordersCount ?? 0})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        const Gap(AppSpaces.small),
        
        // قائمة الطلبات
        Expanded(
          child: _buildShipmentOrders(),
        ),
      ],
    );
  }

  Widget _buildShipmentInfo() {
    final theme = Theme.of(context);
    DateTime? date;
    try {
      date = _shipment!.creationDate != null 
          ? DateTime.parse(_shipment!.creationDate!)
          : null;
    } catch (e) {
      date = null;
    }

    return Container(
      margin: const EdgeInsets.all(AppSpaces.medium),
      padding: const EdgeInsets.all(AppSpaces.medium),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // العنوان الرئيسي
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const Gap(AppSpaces.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shipment!.code ?? 'غير محدد',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (date != null)
                      Text(
                        "${date.day}/${date.month}/${date.year}",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ),
              // حالة الشحنة
              _buildShipmentStatus(_shipment!.status ?? 0),
            ],
          ),
          
          const Gap(AppSpaces.medium),
          
          // تفاصيل إضافية
          Container(
            padding: const EdgeInsets.all(AppSpaces.medium),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'عدد الطلبات:',
                  '${_shipment!.ordersCount ?? 0}',
                  Icons.receipt_long,
                ),
                const Gap(AppSpaces.small),
                _buildDetailRow(
                  'عدد التجار:',
                  '${_shipment!.merchantsCount ?? 0}',
                  Icons.people,
                ),
                const Gap(AppSpaces.small),
                _buildDetailRow(
                  'نوع الشحنة:',
                  _getShipmentTypeText(_shipment!.type ?? 0),
                  Icons.category,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const Gap(AppSpaces.small),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const Gap(AppSpaces.small),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShipmentStatus(int statusIndex) {
    // التأكد من صحة الفهرس
    int safeIndex = statusIndex;
    if (safeIndex < 0 || safeIndex >= orderStatus.length) {
      safeIndex = 0;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: orderStatus[safeIndex].color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        orderStatus[safeIndex].name ?? 'غير محدد',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: orderStatus[safeIndex].textColor ?? Colors.black,
        ),
      ),
    );
  }

  Widget _buildShipmentOrders() {
    final ordersState = ref.watch(ordersNotifierProvider);
    
    return ordersState.when(
      data: (data) => GenericPagedListView(
        noItemsFoundIndicatorBuilder: _buildNoOrdersFound(),
        fetchPage: (pageKey, _) async {
          return await ref.read(ordersNotifierProvider.notifier).getAll(
            page: pageKey,
            queryParams: OrderFilter(
              shipmentId: widget.shipmentId,
              shipmentCode: widget.shipmentCode,
            ).toJson(),
          );
        },
        itemBuilder: (context, order, index) => OrderCardItem(
          order: order,
          isSelectionMode: false,
          onTap: () {
            context.push(AppRoutes.orderDetails, extra: order.code);
          },
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
              'حدث خطأ في جلب طلبات الشحنة',
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

  Widget _buildNoOrdersFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/svg/NoItemsFound.gif',
          width: 200,
          height: 200,
        ),
        const Gap(AppSpaces.medium),
        Text(
          'لا توجد طلبات في هذه الشحنة',
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.primary,
            fontSize: 18,
          ),
        ),
        const Gap(AppSpaces.small),
        Text(
          'يبدو أن هذه الشحنة فارغة أو حدث خطأ في التحميل',
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

  String _getShipmentTypeText(int type) {
    switch (type) {
      case 0:
        return 'استحصال';
      case 1:
        return 'توصيل';
      default:
        return 'غير محدد';
    }
  }
}