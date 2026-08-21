import 'package:flutter/material.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';

class CheckoutScreen extends StatefulWidget {
  final CartItem? directItem;
  final String? selectedDate;
  final String? selectedTime;

  const CheckoutScreen({
    super.key,
    this.directItem,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedAddressIndex = 0;
  int _selectedPaymentIndex = 0;
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    final success = CartService.applyCoupon(code);
    if (success) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Coupon '${code.toUpperCase()}' applied successfully!"),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  final List<Map<String, String>> _addresses = [
    {
      "type": "Home Address",
      "address": "124 Green Park, Block B, New Delhi",
      "assetIcon": "assets/icons/addresses-icon.png",
      "fallbackIcon": "home",
    },
    {
      "type": "Office Address",
      "address": "Tower 4, Cyber City, Sector 24",
      "assetIcon": "assets/icons/office_address-icon.png",
      "fallbackIcon": "work",
    },
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      "title": "Cash After Service",
      "subtitle": "Pay cash or UPI directly to technician after job completion.",
      "assetIcon": "assets/icons/cash_after_service-icon.png",
      "fallbackIcon": Icons.payments_rounded,
    },
    {
      "title": "UPI / GPay / PhonePe",
      "subtitle": "Instant & secure payment via any UPI app.",
      "assetIcon": "assets/icons/upi-icon.png",
      "fallbackIcon": Icons.account_balance_wallet_rounded,
    },
    {
      "title": "Credit / Debit Card",
      "subtitle": "Visa, Mastercard, RuPay & Amex supported.",
      "assetIcon": "assets/icons/cards-icon.png",
      "fallbackIcon": Icons.credit_card_rounded,
    },
  ];

  double _parsePrice(String priceStr) {
    final cleaned = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _confirmAndPay() {
    final List<CartItem> items = widget.directItem != null
        ? [widget.directItem!]
        : CartService.itemsNotifier.value;

    if (items.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final subtotal = widget.directItem != null
        ? _parsePrice(widget.directItem!.price)
        : CartService.subtotalPrice;
    final discount = CartService.discountNotifier.value;
    final total = (subtotal - discount).clamp(0.0, double.infinity);

    final selectedAddress = _addresses[_selectedAddressIndex]["address"]!;
    final bookingDate = widget.selectedDate ?? "Today, Aug 19";
    final bookingTime = widget.selectedTime ?? "10:00 AM";

    // Record all confirmed bookings in BookingService
    for (var item in items) {
      BookingService.addBooking(
        title: item.title,
        price: item.price,
        date: bookingDate,
        time: bookingTime,
        imageUrl: item.imageUrl,
        status: "CONFIRMED",
      );
    }

    // Clear cart if this was a cart checkout
    if (widget.directItem == null) {
      CartService.clearCart();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Booking Placed Successfully!",
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Your service has been confirmed for $selectedAddress ($bookingDate at $bookingTime). Total amount: ${CartService.formatInr(total)}.",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: "Back to Home",
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                height: 48,
                borderRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
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
          size: 32,
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
        size: 32,
      ),
    );
  }

  Widget _buildRadioCircle(bool isSelected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: CartService.itemsNotifier,
      builder: (context, cartItems, child) {
        final List<CartItem> items = widget.directItem != null
            ? [widget.directItem!]
            : cartItems;

        final subtotal = widget.directItem != null
            ? _parsePrice(widget.directItem!.price)
            : CartService.subtotalPrice;

        final discount = CartService.discountNotifier.value;
        final total = (subtotal - discount).clamp(0.0, double.infinity);
        final count = items.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Checkout",
              style: AppTypography.headlineMedium.copyWith(fontSize: 20),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              // Scrollable Main Content (Generous 150dp bottom padding for unclipped Booking Summary)
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Clean & Compact Service Summary Box
                    Text(
                      "Service Summary",
                      style: AppTypography.titleLarge.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
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
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(items.length, (index) {
                          final item = items[index];
                          final isLast = index == items.length - 1;

                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Thumbnail (72x72 scaled 1.25x edge-to-edge)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    color: AppColors.primaryLight,
                                    child: Transform.scale(
                                      scale: 1.25,
                                      child: _buildImageWidget(item.imageUrl),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style:
                                            AppTypography.titleMedium.copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        softWrap: true,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "Approx. 2-3 Hours",
                                          style:
                                              AppTypography.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  item.price,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 2: Service Address Selection
                    Text(
                      "Service Address",
                      style: AppTypography.titleLarge.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: List.generate(_addresses.length, (index) {
                        final addr = _addresses[index];
                        final isSelected = _selectedAddressIndex == index;

                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedAddressIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 1.8,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  addr["assetIcon"]!,
                                  width: 22,
                                  height: 22,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                    addr["fallbackIcon"] == "home"
                                        ? Icons.home_rounded
                                        : Icons.work_rounded,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        addr["type"]!,
                                        style:
                                            AppTypography.titleMedium.copyWith(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        addr["address"]!,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildRadioCircle(isSelected),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Section 3: Payment Options Selection
                    Text(
                      "Payment Options",
                      style: AppTypography.titleLarge.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: List.generate(_paymentMethods.length, (index) {
                        final method = _paymentMethods[index];
                        final isSelected = _selectedPaymentIndex == index;

                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedPaymentIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 1.8,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  method["assetIcon"] as String,
                                  width: 22,
                                  height: 22,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                    method["fallbackIcon"] as IconData,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method["title"] as String,
                                        style:
                                            AppTypography.titleMedium.copyWith(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        method["subtitle"] as String,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildRadioCircle(isSelected),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Section 4: Booking Cost Summary with Applied Promo Discount
                    ValueListenableBuilder<double>(
                      valueListenable: CartService.discountNotifier,
                      builder: (context, discount, child) {
                        final appliedCoupon =
                            CartService.couponCodeNotifier.value;

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
                                "Booking Summary",
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Coupon Code Input Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 44,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: TextField(
                                        controller: _couponController,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              "Coupon Code (e.g. PLENORA10)",
                                          hintStyle:
                                              AppTypography.bodySmall.copyWith(
                                            color: AppColors.textMuted,
                                            fontSize: 12,
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _applyCoupon,
                                    child: Container(
                                      height: 44,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        "Apply",
                                        style:
                                            AppTypography.buttonText.copyWith(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Scheduled Date & Time",
                                    style: AppTypography.bodyMedium,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "${widget.selectedDate ?? 'Today, Aug 19'} • ${widget.selectedTime ?? '10:00 AM'}",
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text("Selected Services ($count)",
                                        style: AppTypography.bodyMedium),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(CartService.formatInr(subtotal),
                                      style: AppTypography.titleMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (discount > 0) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "Promo Discount (${appliedCoupon ?? 'Applied'})",
                                              style: AppTypography.bodyMedium
                                                  .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () {
                                              CartService.removeCoupon();
                                              _couponController.clear();
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
                                    const SizedBox(width: 8),
                                    Text(
                                      "-${CartService.formatInr(discount)}",
                                      style:
                                          AppTypography.titleMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text("Booking & Inspection Fee",
                                        style: AppTypography.bodyMedium),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("FREE",
                                      style: AppTypography.titleMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      )),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text("Total Amount to Pay",
                                        style: AppTypography.titleLarge),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    CartService.formatInr(total),
                                    style: AppTypography.headlineMedium
                                        .copyWith(
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

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Section 5: Sticky Confirm Booking & Pay Now Button
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: AppColors.background.withValues(alpha: 0.96),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text:
                            "Confirm Booking & Pay (${CartService.formatInr(total)})",
                        onPressed: _confirmAndPay,
                        height: 52,
                        borderRadius: 26,
                        leadingIcon: Icons.lock_outline_rounded,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
