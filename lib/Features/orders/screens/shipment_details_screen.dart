// lib/Features/orders/screens/shipment_details_screen.dart - مصحح
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/core/widgets/custom_section.dart';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/providers/shipments_provider.dart';

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
  
  @override
  void initState() {
    super.initState();
    // جلب تفاصيل الشحنة إذا لزم الأمر
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShipmentDetails();
    });
  }

  void _loadShipmentDetails() {
    // يمكن إضافة API call هنا لجلب تفاصيل أكثر للشحنة إذا لزم الأمر
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsState = ref.watch(shipmentsNotifierProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomAppBar(
              title: "تفاصيل الشحنة",
              showBackButton: true,
              onBackButtonPressed: () => context.pop(),
            ),
            
            Expanded(
              child: shipmentsState.when(
                data: (shipments) {
                  // ✅ البحث عن الشحنة بالـ ID باستخدام الـ notifier
                  final shipment = ref.read(shipmentsNotifierProvider.notifier)
                      .getShipmentById(widget.shipmentId) ?? 
                      Shipment(
                        id: widget.shipmentId,
                        code: widget.shipmentCode ?? 'غير محدد',
                      );
                  
                  return _buildShipmentDetails(context, shipment);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(context, error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentDetails(BuildContext context, Shipment shipment) {
    final date = shipment.creationDate != null 
        ? DateTime.parse(shipment.creationDate!)
        : DateTime.now();

    return SingleChildScrollView(
      child: Column(
        children: [
          // معلومات الشحنة الأساسية
          CustomSection(
            title: "معلومات الشحنة",
            icon: SvgPicture.asset(
              "assets/svg/navigation_box.svg",
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            childrenRadius: const BorderRadius.all(Radius.circular(16)),
            children: [
              _buildShipmentInfoSection(context, shipment, date),
            ],
          ),

          // إحصائيات الشحنة
          CustomSection(
            title: "إحصائيات الشحنة",
            icon: SvgPicture.asset(
              "assets/svg/navigation_statstic.svg",
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            childrenRadius: const BorderRadius.all(Radius.circular(16)),
            children: [
              _buildStatisticsSection(context, shipment),
            ],
          ),

          // حالة الشحنة
          CustomSection(
            title: "حالة الشحنة",
            icon: SvgPicture.asset(
              "assets/svg/SpinnerGap.svg",
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            childrenRadius: const BorderRadius.all(Radius.circular(16)),
            children: [
              _buildStatusSection(context, shipment),
            ],
          ),

          const Gap(AppSpaces.medium),

          // أزرار العمليات
          Container(
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
            ),
            child: Column(
              children: [
                // زر عرض الطلبات
                FillButton(
                  label: "عرض طلبات الشحنة",
                  onPressed: () => _viewShipmentOrders(shipment),
                  icon: SvgPicture.asset(
                    "assets/svg/box.svg",
                    color: Colors.white,
                    width: 24,
                    height: 24,
                  ),
                  reverse: true,
                ),
                
                const Gap(AppSpaces.medium),
                
                // زر تواصل مع الدعم
                FillButton(
                  label: "تواصل مع الدعم الفني",
                  onPressed: () => _contactSupport(),
                  reverse: true,
                  color: Theme.of(context).colorScheme.secondary,
                  icon: SvgPicture.asset(
                    "assets/svg/support.svg",
                    color: Colors.white,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentInfoSection(BuildContext context, Shipment shipment, DateTime date) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                context,
                "رقم الشحنة",
                "assets/svg/receipt.svg",
                shipment.code ?? "غير محدد",
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.outline,
              ),
              const Gap(AppSpaces.small),
              _buildInfoItem(
                context,
                "التاريخ",
                "assets/svg/CalendarBlank.svg",
                "${date.day}.${date.month}.${date.year}",
              ),
            ],
          ),
        ),
        const Divider(),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                context,
                "نوع الشحنة",
                "assets/svg/navigation_add.svg",
                _getShipmentTypeText(shipment.type ?? 0),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.outline,
              ),
              const Gap(AppSpaces.small),
              _buildInfoItem(
                context,
                "الحالة",
                "assets/svg/SpinnerGap.svg",
                "",
                customWidget: _buildStatusBadge(context, shipment.status ?? 0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(BuildContext context, Shipment shipment) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                context,
                "عدد الطلبات",
                "assets/svg/box.svg",
                "${shipment.ordersCount ?? 0}",
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.outline,
              ),
              const Gap(AppSpaces.small),
              _buildInfoItem(
                context,
                "عدد التجار",
                "assets/svg/User.svg",
                "${shipment.merchantsCount ?? 0}",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context, Shipment shipment) {
    final statusIndex = shipment.status ?? 0;
    final safeIndex = statusIndex < orderStatus.length ? statusIndex : 0;
    final status = orderStatus[safeIndex];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                status.icon ?? "assets/svg/box.svg",
                color: context.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.name ?? 'غير محدد',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.colorScheme.primary,
                    fontFamily: "Tajawal",
                  ),
                ),
                Text(
                  status.description ?? 'لا توجد تفاصيل',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: "Tajawal",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String title,
    String iconPath,
    String value, {
    Widget? customWidget,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(3),
              child: SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.secondary,
                      fontFamily: "Tajawal",
                    ),
                  ),
                  if (customWidget != null)
                    customWidget
                  else
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: "Tajawal",
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, int statusIndex) {
    final safeIndex = statusIndex < orderStatus.length ? statusIndex : 0;
    final status = orderStatus[safeIndex];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name ?? 'غير محدد',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status.textColor ?? Colors.black,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
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
          ),
          const Gap(AppSpaces.small),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(AppSpaces.large),
          FillButton(
            label: "المحاولة مرة أخرى",
            onPressed: () {
              ref.refresh(shipmentsNotifierProvider);
            },
          ),
        ],
      ),
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

  void _viewShipmentOrders(Shipment shipment) {
    // الذهاب لصفحة الطلبات مع فلتر الشحنة
    context.push(
      AppRoutes.orders,
      extra: OrderFilter(
        shipmentId: shipment.id,
        shipmentCode: shipment.code,
      ),
    );
  }

  void _contactSupport() {
    
  }
}