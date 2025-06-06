// lib/Features/orders/screens/shipment_details_screen.dart
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
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';

// استخدام نموذج الشحنة من orders لتجنب التضارب
import 'package:Tosell/Features/orders/models/Shipment.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShipmentDetails();
    });
  }

  void _loadShipmentDetails() {
    // تحديث بيانات الشحنات للتأكد من وجود البيانات الحديثة
    ref.read(shipmentsNotifierProvider.notifier).getAll(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsState = ref.watch(shipmentsNotifierProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              title: "تفاصيل الشحنة",
              showBackButton: true,
              onBackButtonPressed: () => context.pop(),
            ),
            
            Expanded(
              child: shipmentsState.when(
                data: (shipments) {
                  // البحث عن الشحنة بالـ ID أو الكود
                  Shipment? shipment;
                  
                  if (widget.shipmentId.isNotEmpty) {
                    try {
                      shipment = shipments.firstWhere(
                        (s) => s.id == widget.shipmentId || s.code == widget.shipmentId,
                      );
                    } catch (e) {
                      // إذا لم نجد الشحنة، ننشئ واحدة افتراضية
                      shipment = null;
                    }
                  }
                  
                  if (shipment == null && widget.shipmentCode != null) {
                    try {
                      shipment = shipments.firstWhere(
                        (s) => s.code == widget.shipmentCode,
                      );
                    } catch (e) {
                      shipment = null;
                    }
                  }
                  
                  // إذا لم نجد الشحنة، ننشئ واحدة افتراضية بالبيانات المتاحة
                  shipment ??= Shipment(
                    id: widget.shipmentId,
                    code: widget.shipmentCode ?? 'غير محدد',
                    ordersCount: 0,
                    merchantsCount: 0,
                    status: 0,
                    type: 0,
                    creationDate: DateTime.now().toIso8601String(),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات الشحنة الأساسية
          _buildInfoCard(
            context,
            title: "معلومات الشحنة",
            icon: "assets/svg/box.svg",
            children: [
              _buildShipmentInfoSection(context, shipment, date),
            ],
          ),

          const Gap(AppSpaces.medium),

          // إحصائيات الشحنة
          _buildInfoCard(
            context,
            title: "إحصائيات الشحنة",
            icon: "assets/svg/navigation_statstic.svg",
            children: [
              _buildStatisticsSection(context, shipment),
            ],
          ),

          const Gap(AppSpaces.medium),

          // حالة الشحنة
          _buildInfoCard(
            context,
            title: "حالة الشحنة",
            icon: "assets/svg/SpinnerGap.svg",
            children: [
              _buildStatusSection(context, shipment),
            ],
          ),

          const Gap(AppSpaces.large),

          // أزرار العمليات
          _buildActionButtons(context, shipment),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(AppSpaces.small),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
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
            children: [
              _buildInfoItem(
                context,
                "رقم الشحنة",
                "assets/svg/receipt.svg",
                shipment.code ?? "غير محدد",
              ),
              VerticalDivider(
                width: 2,
                thickness: 1,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
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
            children: [
              _buildInfoItem(
                context,
                "نوع الشحنة",
                "assets/svg/navigation_add.svg",
                _getShipmentTypeText(shipment.type ?? 0),
              ),
              VerticalDivider(
                width: 2,
                thickness: 1,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
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
    return IntrinsicHeight(
      child: Row(
        children: [
          _buildInfoItem(
            context,
            "عدد الطلبات",
            "assets/svg/box.svg",
            "${shipment.ordersCount ?? 0}",
          ),
          VerticalDivider(
            width: 2,
            thickness: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          _buildInfoItem(
            context,
            "عدد التجار",
            "assets/svg/User.svg",
            "${shipment.merchantsCount ?? 0}",
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, Shipment shipment) {
    final statusIndex = shipment.status ?? 0;
    final safeIndex = statusIndex < orderStatus.length ? statusIndex : 0;
    final status = orderStatus[safeIndex];
    
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: status.color?.withOpacity(0.2) ?? Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              status.icon ?? "assets/svg/box.svg",
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const Gap(AppSpaces.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.name ?? 'غير محدد',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Gap(4),
              Text(
                status.description ?? 'لا توجد تفاصيل إضافية',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
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
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const Gap(AppSpaces.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const Gap(4),
                if (customWidget != null)
                  customWidget
                else
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, int statusIndex) {
    final safeIndex = statusIndex < orderStatus.length ? statusIndex : 0;
    final status = orderStatus[safeIndex];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name ?? 'غير محدد',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: status.textColor ?? Colors.black,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Shipment shipment) {
    return Column(
      children: [
        // زر عرض الطلبات
        FillButton(
          label: "عرض طلبات الشحنة (${shipment.ordersCount ?? 0})",
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
        
        // زر تواصل مع الدعم (اختياري)
        FillButton(
          label: "تواصل مع الدعم الفني",
          onPressed: () => _contactSupport(),
          reverse: true,
          color: Theme.of(context).colorScheme.secondary,
          icon: SvgPicture.asset(
            "assets/svg/User.svg", // استخدم أيقونة متاحة
            color: Colors.white,
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'يرجى المحاولة مرة أخرى',
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
    // يمكنك إضافة وظيفة التواصل مع الدعم هنا
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ميزة التواصل مع الدعم قيد التطوير')),
    );
  }
}