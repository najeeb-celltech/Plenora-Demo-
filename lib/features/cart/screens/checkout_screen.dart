import 'package:flutter/material.dart';
import '../../../core/services/address_service.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/services/datetime_service.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/schedule_dialog.dart';
import '../../profile/screens/payment_methods_screen.dart';
import '../../profile/screens/saved_addresses_screen.dart';

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
  String? _selectedAddressId;
  String _selectedPaymentKey = "card_card_1";
  final TextEditingController _couponController = TextEditingController();
  late String _selectedDate;
  late String _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate =
        widget.selectedDate ?? AppDateTimeUtils.getDefaultBookingDate();
    _selectedTime =
        widget.selectedTime ?? AppDateTimeUtils.getDefaultBookingTime();

    final defAddress = AddressService.defaultAddress;
    if (defAddress != null) {
      _selectedAddressId = defAddress.id;
    } else if (AddressService.addressesNotifier.value.isNotEmpty) {
      _selectedAddressId = AddressService.addressesNotifier.value.first.id;
    }

    final defCard = PaymentMethodService.defaultCard;
    if (defCard != null) {
      _selectedPaymentKey = "card_${defCard.id}";
    } else if (PaymentMethodService.cardsNotifier.value.isNotEmpty) {
      _selectedPaymentKey =
          "card_${PaymentMethodService.cardsNotifier.value.first.id}";
    } else {
      _selectedPaymentKey = "cash";
    }
  }

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  double _parsePrice(String priceStr) {
    final cleaned = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  String _getSelectedAddressString() {
    final addresses = AddressService.addressesNotifier.value;
    if (addresses.isEmpty) {
      return "124 Green Park, Block B, New Delhi";
    }
    final selected = addresses.firstWhere(
      (a) => a.id == _selectedAddressId,
      orElse: () => addresses.first,
    );
    return selected.formattedFullAddress;
  }

  String _getSelectedPaymentMethodString() {
    if (_selectedPaymentKey.startsWith("card_")) {
      final cardId = _selectedPaymentKey.replaceFirst("card_", "");
      final cards = PaymentMethodService.cardsNotifier.value;
      if (cards.isNotEmpty) {
        final card = cards.firstWhere(
          (c) => c.id == cardId,
          orElse: () => cards.first,
        );
        return card.maskedNumber;
      }
      return "Visa •••• 4521";
    } else if (_selectedPaymentKey == "upi") {
      return "UPI / GPay / PhonePe";
    } else {
      return "Cash After Service";
    }
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

    final selectedAddressString = _getSelectedAddressString();
    final selectedPaymentMethodString = _getSelectedPaymentMethodString();
    final bookingDate = _selectedDate;
    final bookingTime = _selectedTime;

    // Record all confirmed bookings in BookingService with address and payment method
    for (var item in items) {
      BookingService.addBooking(
        title: item.title,
        price: item.price,
        date: bookingDate,
        time: bookingTime,
        imageUrl: item.imageUrl,
        status: "CONFIRMED",
        address: selectedAddressString,
        paymentMethod: selectedPaymentMethodString,
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
              "Your service has been confirmed for $selectedAddressString ($bookingDate at $bookingTime) via $selectedPaymentMethodString. Total amount: ${CartService.formatInr(total)}.",
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
      width: 20,
      height: 20,
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
                width: 10,
                height: 10,
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
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Service Summary Box
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

                    // Section 2: Saved Service Address Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Service Address",
                            style: AppTypography.titleLarge.copyWith(fontSize: 17),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final selected = await Navigator.push<UserAddress>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SavedAddressesScreen(
                                  selectMode: true,
                                  selectedAddressId: _selectedAddressId,
                                ),
                              ),
                            );
                            if (selected != null) {
                              setState(() => _selectedAddressId = selected.id);
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.add_location_alt_outlined,
                                  size: 15, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                "Manage / Add",
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ValueListenableBuilder<List<UserAddress>>(
                      valueListenable: AddressService.addressesNotifier,
                      builder: (context, addresses, _) {
                        if (addresses.isEmpty) {
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SavedAddressesScreen(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.add_location_rounded,
                                      color: AppColors.primary, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Add a delivery address",
                                      style: AppTypography.titleMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: List.generate(addresses.length, (index) {
                            final addr = addresses[index];
                            final isSelected = _selectedAddressId == addr.id ||
                                (_selectedAddressId == null && index == 0);

                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedAddressId = addr.id),
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
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryLight
                                            : AppColors.background,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        addr.type == AddressType.office
                                            ? "assets/icons/office_address-icon.png"
                                            : "assets/icons/addresses-icon.png",
                                        width: 20,
                                        height: 20,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          addr.type == AddressType.home
                                              ? Icons.home_rounded
                                              : addr.type == AddressType.office
                                                  ? Icons.business_rounded
                                                  : Icons.location_on_rounded,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  addr.typeDisplay,
                                                  style: AppTypography.titleMedium
                                                      .copyWith(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (addr.isDefault) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryLight,
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    "Default",
                                                    style: AppTypography
                                                        .bodySmall
                                                        .copyWith(
                                                      color: AppColors.primary,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            addr.formattedShortAddress,
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
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
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Section 3: Payment Options (Saved Cards + UPI + Cash)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Payment Options",
                            style: AppTypography.titleLarge.copyWith(fontSize: 17),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final card = await Navigator.push<PaymentCard>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PaymentMethodsScreen(selectMode: true),
                              ),
                            );
                            if (card != null) {
                              setState(
                                  () => _selectedPaymentKey = "card_${card.id}");
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.add_card_rounded,
                                  size: 15, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                "Add Card",
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Saved Cards list
                    ValueListenableBuilder<List<PaymentCard>>(
                      valueListenable: PaymentMethodService.cardsNotifier,
                      builder: (context, cards, _) {
                        return Column(
                          children: [
                            ...cards.map((card) {
                              final isSelected =
                                  _selectedPaymentKey == "card_${card.id}";
                              return GestureDetector(
                                onTap: () => setState(() =>
                                    _selectedPaymentKey = "card_${card.id}"),
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
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryLight
                                              : AppColors.background,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          "assets/icons/cards-icon.png",
                                          width: 20,
                                          height: 20,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                            Icons.credit_card_rounded,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    card.maskedNumber,
                                                    style: AppTypography
                                                        .titleMedium
                                                        .copyWith(
                                                      fontSize: 14.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (card.isDefault) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.primaryLight,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      "Default",
                                                      style: AppTypography
                                                          .bodySmall
                                                          .copyWith(
                                                        color:
                                                            AppColors.primary,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${card.typeDisplay} • Expires ${card.expiryDisplay}",
                                              style: AppTypography.bodySmall
                                                  .copyWith(
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

                            // UPI Option
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPaymentKey = "upi"),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _selectedPaymentKey == "upi"
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
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _selectedPaymentKey == "upi"
                                            ? AppColors.primaryLight
                                            : AppColors.background,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        "assets/icons/upi-icon.png",
                                        width: 20,
                                        height: 20,
                                        color: _selectedPaymentKey == "upi"
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          Icons.account_balance_wallet_rounded,
                                          color: _selectedPaymentKey == "upi"
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "UPI / GPay / PhonePe",
                                            style: AppTypography.titleMedium
                                                .copyWith(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Instant & secure payment via any UPI app.",
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildRadioCircle(
                                        _selectedPaymentKey == "upi"),
                                  ],
                                ),
                              ),
                            ),

                            // Cash After Service Option
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedPaymentKey = "cash"),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _selectedPaymentKey == "cash"
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
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _selectedPaymentKey == "cash"
                                            ? AppColors.primaryLight
                                            : AppColors.background,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        "assets/icons/cash_after_service-icon.png",
                                        width: 20,
                                        height: 20,
                                        color: _selectedPaymentKey == "cash"
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          Icons.payments_rounded,
                                          color: _selectedPaymentKey == "cash"
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Cash After Service",
                                            style: AppTypography.titleMedium
                                                .copyWith(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Pay cash or UPI directly to technician after job completion.",
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildRadioCircle(
                                        _selectedPaymentKey == "cash"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Section 4: Booking Summary
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

                              GestureDetector(
                                onTap: () async {
                                  final schedule =
                                      await showScheduleAppointmentDialog(
                                    context,
                                    title: "Reschedule Appointment",
                                    buttonText: "Update Date & Time",
                                    initialDate: _selectedDate,
                                    initialTime: _selectedTime,
                                  );
                                  if (schedule != null) {
                                    setState(() {
                                      _selectedDate = schedule['date']!;
                                      _selectedTime = schedule['time']!;
                                    });
                                  }
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Scheduled Date & Time",
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "$_selectedDate • $_selectedTime",
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
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Selected Address",
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _getSelectedAddressString(),
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
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
                                    child: Text(
                                      "Payment Method",
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _getSelectedPaymentMethodString(),
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
