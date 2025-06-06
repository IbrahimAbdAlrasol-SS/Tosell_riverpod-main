// lib/Features/orders/widgets/shipment_cart_item.dart
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';

class ShipmentCartItem extends ConsumerWidget {
  final Shipment shipment;
  final Function? onTap;

  const ShipmentCartItem({
    required this.shipment,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    DateTime date = DateTime.parse(
        shipment.creationDate ?? DateTime.now().toIso8601String());
    
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.only(right: 2, left: 2, bottom: 2),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            color: const Color(0xffEAEEF0),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // أيقونة الشحنة
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1000),
                            color: theme.colorScheme.surface,
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/box.svg", // يمكن استخدام أيقونة شحنة مختلفة
                            width: 24,
                            height: 24,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // معلومات الشحنة
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shipment.code ?? "لايوجد",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tajawal",
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "${date.day}.${date.month}.${date.year}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.secondary,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Tajawal",
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getShipmentTypeText(shipment.type ?? 0),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // حالة الشحنة
                        _buildShipmentStatus(shipment.status ?? 0, theme),
                        const Gap(AppSpaces.small),
                      ],
                    ),
                  ],
                ),
              ),
              
              // تفاصيل الشحنة
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildSection(
                            "الطلبات: ${shipment.ordersCount ?? 0}",
                            "assets/svg/box.svg", 
                            theme,
                            textColor: theme.colorScheme.onSurface,
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: theme.colorScheme.outline,
                          ),
                          const Gap(AppSpaces.small),
                          buildSection(
                            "التجار: ${shipment.merchantsCount ?? 0}",
                            "assets/svg/User.svg",
                            theme,
                            textColor: theme.colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// حالة الشحنة
  Widget _buildShipmentStatus(int statusIndex, ThemeData theme) {
    int safeIndex = statusIndex;
    if (safeIndex < 0 || safeIndex >= orderStatus.length) {
      safeIndex = 0;
    }
    
    return Container(
      width: 90,
      height: 28,
      decoration: BoxDecoration(
        color: orderStatus[safeIndex].color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (orderStatus[safeIndex].textColor ?? Colors.black).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          orderStatus[safeIndex].name ?? 'غير محدد',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: orderStatus[safeIndex].textColor ?? Colors.black,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
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
        return 'عادي';
    }
  }
}

/// widget المقطع
Widget buildSection(
  String title,
  String iconPath,
  ThemeData theme, {
  bool isRed = false,
  bool isGray = false,
  void Function()? onTap,
  EdgeInsets? padding,
  double? textWidth,
  Color? textColor,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Padding(
              padding: padding ?? const EdgeInsets.all(0),
              child: SvgPicture.asset(
                iconPath,
                width: 20,
                height: 20,
                color: isRed
                    ? theme.colorScheme.error
                    : isGray
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                width: textWidth,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? theme.colorScheme.secondary,
                    fontFamily: "Tajawal",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}