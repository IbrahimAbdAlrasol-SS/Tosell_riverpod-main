// lib/Features/orders/widgets/shipment_cart_item.dart - محدث
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
      onTap: () => onTap?.call(), // ✅ استخدام onTap الذي تم تمريره من الصفحة الرئيسية
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), // ✅ إضافة animation للتفاعل
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.only(right: 2, left: 2, bottom: 2),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            color: const Color(0xffEAEEF0),
            borderRadius: BorderRadius.circular(24),
            // ✅ إضافة shadow خفيف للتحسين البصري
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
                        // أيقونة الشحنة مع تحسين بصري
                        Container(
                          padding: const EdgeInsets.all(6), // ✅ حجم أكبر قليلاً
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1000),
                            color: theme.colorScheme.surface,
                            // ✅ إضافة border خفيف
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/navigation_box.svg", // ✅ أيقونة شحنة أوضح
                            width: 24,
                            height: 24,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10), // ✅ مسافة أوضح
                        
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
                              // ✅ إضافة معلومة إضافية عن نوع الشحنة
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
                        
                        // حالة الشحنة مع تحسين
                        _buildShipmentStatus(shipment.status ?? 0, theme),
                        const Gap(AppSpaces.small),
                      ],
                    ),
                  ],
                ),
              ),
              
              // تفاصيل الشحنة مع تحسين التصميم
              Container(
                padding: const EdgeInsets.all(12), // ✅ حجم أكبر قليلاً
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  // ✅ إضافة border خفيف
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
                            textColor: theme.colorScheme.onSurface, // ✅ لون أوضح
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
                            textColor: theme.colorScheme.onSurface, // ✅ لون أوضح
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

  /// ✅ تحسين مظهر حالة الشحنة
  Widget _buildShipmentStatus(int statusIndex, ThemeData theme) {
    int safeIndex = statusIndex;
    if (safeIndex < 0 || safeIndex >= orderStatus.length) {
      safeIndex = 0;
    }
    
    return Container(
      width: 90, // ✅ عرض أصغر قليلاً
      height: 28, // ✅ ارتفاع أكبر قليلاً
      decoration: BoxDecoration(
        color: orderStatus[safeIndex].color,
        borderRadius: BorderRadius.circular(20),
        // ✅ إضافة border للوضوح
        border: Border.all(
          color: (orderStatus[safeIndex].textColor ?? Colors.black).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          orderStatus[safeIndex].name ?? 'غير محدد',
          style: TextStyle(
            fontSize: 11, // ✅ خط أصغر قليلاً ليتناسب
            fontWeight: FontWeight.w600,
            color: orderStatus[safeIndex].textColor ?? Colors.black,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis, // ✅ منع الطفح
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

/// ✅ تحسين widget المقطع مع ألوان أوضح
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
                width: 20, // ✅ حجم أصغر قليلاً للتوازن
                height: 20,
                color: isRed
                    ? theme.colorScheme.error
                    : isGray
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8), // ✅ مسافة أصغر
            Expanded(
              child: SizedBox(
                width: textWidth,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, // ✅ خط أوضح
                    fontWeight: FontWeight.w500, // ✅ وزن أوضح
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