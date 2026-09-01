import 'package:flutter/material.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/schedule_dialog.dart';
import 'checkout_screen.dart';

class ServiceCartScreen extends StatefulWidget {
  final VoidCallback? onExploreServices;

  const ServiceCartScreen({super.key, this.onExploreServices});

  @override
  State<ServiceCartScreen> createState() => _ServiceCartScreenState();
}

class _ServiceCartScreenState extends State<ServiceCartScreen> {
  ShapeBorder get roundedShape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

  void _proceedToBooking(BuildContext context) async {
    final schedule = await showScheduleAppointmentDialog(
      context,
      title: "Schedule Appointment",
      buttonText: "Continue to Checkout",
    );

    if (schedule != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            selectedDate: schedule['date'],
            selectedTime: schedule['time'],
          ),
        ),
      );
    }
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.cleaning_services_rounded,
          color: AppColors.primary,
          size: 36,
        ),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.cleaning_services_rounded,
        color: AppColors.primary,
        size: 36,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: CartService.itemsNotifier,
      builder: (context, items, child) {
        final total = CartService.totalPrice;
        final count = CartService.totalCount;

        // Perfectly Centered Empty Cart View
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Service Cart",
                            style: AppTypography.headlineLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Review and manage selected home services.",
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Vertically & Horizontally Centered Empty Container
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 12,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              "Your Cart is Empty",
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Add cleaning, electrical, painting, or appliance services to schedule your appointment.",
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (widget.onExploreServices != null)
                              SizedBox(
                                width: 200,
                                child: PrimaryButton(
                                  text: "Explore Services",
                                  onPressed: widget.onExploreServices,
                                  height: 44,
                                  borderRadius: 22,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Active Cart List View
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Service Cart",
                          style: AppTypography.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Review and manage selected home services.",
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                  if (items.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        CartService.clearCart();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Clear All",
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // List of Selected Services
              ...items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0E000000),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Thumbnail (80x80)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: AppColors.primaryLight,
                          child: Transform.scale(
                            scale: 1.25,
                            child: _buildImageWidget(item.imageUrl),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Service Information & Unclipped Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      CartService.removeService(item.title),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            if (item.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                                softWrap: true,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              item.price,
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Compact Approx. Time Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 13,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      "Approx. 2-3 Hours",
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Cost Details Summary Card with Perfectly Aligned Coupon Field
              ValueListenableBuilder<double>(
                valueListenable: CartService.discountNotifier,
                builder: (context, discount, child) {
                  final subtotal = CartService.subtotalPrice;
                  final appliedCoupon = CartService.couponCodeNotifier.value;

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cost Details",
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),

                        const SizedBox(height: 4),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Selected Services ($count)",
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                            Text(
                              CartService.formatInr(subtotal),
                              style: AppTypography.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (discount > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      "Promo Discount (${appliedCoupon ?? 'Applied'})",
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () {
                                        CartService.removeCoupon();
                                      },
                                      child: const Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.redAccent,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "-${CartService.formatInr(discount)}",
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Booking & Inspection Fee",
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                            Text(
                              "FREE",
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Total Estimated Cost",
                                style: AppTypography.titleLarge,
                              ),
                            ),
                            Text(
                              CartService.formatInr(total),
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Proceed Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text:
                      "Proceed to Bookings (${CartService.formatInr(total)})",
                  onPressed: () => _proceedToBooking(context),
                  height: 52,
                  borderRadius: 26,
                  leadingIcon: Icons.calendar_month_rounded,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
