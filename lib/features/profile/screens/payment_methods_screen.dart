import 'package:flutter/material.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final bool selectMode;
  final String? selectedPaymentKey;
  final ValueChanged<PaymentCard>? onCardSelected;

  const PaymentMethodsScreen({
    super.key,
    this.selectMode = false,
    this.selectedPaymentKey,
    this.onCardSelected,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  void _openCardFormDialog({PaymentCard? cardToEdit}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _CardFormDialog(
        cardToEdit: cardToEdit,
        onSaved: (card) {
          if (cardToEdit == null) {
            PaymentMethodService.addCard(card);
          } else {
            PaymentMethodService.updateCard(card);
          }
          if (widget.selectMode && widget.onCardSelected != null) {
            widget.onCardSelected!(card);
          }
        },
      ),
    );
  }

  void _confirmDelete(PaymentCard card) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: Text(
          "Remove Card?",
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          "Are you sure you want to remove ${card.maskedNumber} (${card.brandDisplay})?",
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              "Cancel",
              style: AppTypography.titleSmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              PaymentMethodService.deleteCard(card.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${card.brandDisplay} card removed"),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          widget.selectMode ? "Select Payment Card" : "Payment Methods",
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Saved Debit & Credit Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Saved Cards (Debit & Credit)",
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_rounded,
                            size: 11, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          "Tokenized & Encrypted",
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ValueListenableBuilder<List<PaymentCard>>(
                valueListenable: PaymentMethodService.cardsNotifier,
                builder: (context, cards, _) {
                  if (cards.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/icons/cards-icon.png",
                                width: 28,
                                height: 28,
                                color: AppColors.primary,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.credit_card_off_rounded,
                                  size: 28,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No Saved Cards",
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Save your Visa, Mastercard, RuPay, or Amex card for faster, 100% tokenized checkouts.",
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cards.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final isSelected = widget.selectMode &&
                          widget.selectedPaymentKey == "card_${card.id}";

                      return _buildCardItem(card, isSelected: isSelected);
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // Section 2: Other Payment Options (UPI & Cash)
              Text(
                "Other Payment Modes",
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 12),

              _buildOtherOptionCard(
                assetIcon: "assets/icons/upi-icon.png",
                fallbackIcon: Icons.account_balance_wallet_rounded,
                title: "UPI / QR Code",
                subtitle: "Instant payment via Google Pay, PhonePe, Paytm, or BHIM",
                badge: "Instant",
              ),
              const SizedBox(height: 10),
              _buildOtherOptionCard(
                assetIcon: "assets/icons/cash_after_service-icon.png",
                fallbackIcon: Icons.payments_rounded,
                title: "Cash After Service",
                subtitle: "Pay conveniently in cash directly to your service professional upon completion",
                badge: "Pay on Delivery",
              ),

              const SizedBox(height: 24),

              // Section 3: Security Assurance Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FBF7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PCI-DSS Level 1 & RBI Compliant",
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Plenora never stores your 16-digit card number or CVV in plain text. All transactions are end-to-end tokenized and secured via 256-bit encryption.",
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11.5,
                              color: const Color(0xFF388E3C),
                              height: 1.35,
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
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: "+ Add New Card",
              onPressed: () => _openCardFormDialog(),
              height: 50,
              borderRadius: 25,
              leadingIcon: Icons.add_card_rounded,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem(PaymentCard card, {bool isSelected = false}) {
    IconData brandIcon = Icons.credit_card_rounded;
    Color brandColor = AppColors.primary;

    if (card.cardBrand == CardBrand.visa) {
      brandColor = const Color(0xFF1A1F71);
    } else if (card.cardBrand == CardBrand.mastercard) {
      brandColor = const Color(0xFFEB001B);
    } else if (card.cardBrand == CardBrand.rupay) {
      brandColor = const Color(0xFF006699);
    }

    return GestureDetector(
      onTap: widget.selectMode
          ? () {
              if (widget.onCardSelected != null) {
                widget.onCardSelected!(card);
              }
              Navigator.pop(context, card);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : card.isDefault
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : Colors.grey.shade200,
            width: isSelected || card.isDefault ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Brand Icon Container
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "assets/icons/cards-icon.png",
                              width: 14,
                              height: 14,
                              color: brandColor,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(brandIcon,
                                      size: 14, color: brandColor),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                card.brandDisplay,
                                style: AppTypography.bodySmall.copyWith(
                                  color: brandColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Card Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          card.typeDisplay,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      if (card.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 11, color: AppColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                "Default",
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                if (widget.selectMode)
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 22,
                  )
                else ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 19, color: AppColors.textSecondary),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Edit Card",
                    onPressed: () => _openCardFormDialog(cardToEdit: card),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 19, color: Colors.redAccent),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Remove Card",
                    onPressed: () => _confirmDelete(card),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Card Number display
            Text(
              card.maskedNumber,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),

            // Cardholder and Expiry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    card.cardHolderName.toUpperCase(),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Expires ${card.expiryDisplay}",
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),

            if (!widget.selectMode && !card.isDefault) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  PaymentMethodService.setDefault(card.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${card.brandDisplay} card set as default"),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_border_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "Set as Default Card",
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOtherOptionCard({
    required String assetIcon,
    required IconData fallbackIcon,
    required String title,
    required String subtitle,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              assetIcon,
              width: 20,
              height: 20,
              color: AppColors.primary,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(fallbackIcon, size: 20, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFormDialog extends StatefulWidget {
  final PaymentCard? cardToEdit;
  final ValueChanged<PaymentCard> onSaved;

  const _CardFormDialog({
    this.cardToEdit,
    required this.onSaved,
  });

  @override
  State<_CardFormDialog> createState() => _CardFormDialogState();
}

class _CardFormDialogState extends State<_CardFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late CardType _selectedType;
  late CardBrand _detectedBrand;
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final c = widget.cardToEdit;
    _selectedType = c?.cardType ?? CardType.debit;
    _detectedBrand = c?.cardBrand ?? CardBrand.visa;
    _nameController =
        TextEditingController(text: c?.cardHolderName ?? 'Alex Morgan');
    _numberController =
        TextEditingController(text: c != null ? "•••• •••• •••• ${c.last4Digits}" : '');
    _expiryController = TextEditingController(text: c?.expiryDisplay ?? '');
    _cvvController = TextEditingController();
    _isDefault = c?.isDefault ?? false;

    _numberController.addListener(_onNumberChanged);
  }

  void _onNumberChanged() {
    final text = _numberController.text.replaceAll(' ', '');
    if (text.isNotEmpty) {
      final brand = PaymentMethodService.detectBrand(text);
      if (brand != _detectedBrand) {
        setState(() => _detectedBrand = brand);
      }
    }
  }

  @override
  void dispose() {
    _numberController.removeListener(_onNumberChanged);
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.cardToEdit != null;
    String month = "12";
    String year = "28";

    final expParts = _expiryController.text.trim().split('/');
    if (expParts.isNotEmpty) month = expParts[0].padLeft(2, '0');
    if (expParts.length > 1) year = expParts[1].padLeft(2, '0');

    if (isEditing) {
      final updated = widget.cardToEdit!.copyWith(
        cardType: _selectedType,
        cardHolderName: _nameController.text.trim(),
        expiryMonth: month,
        expiryYear: year,
        isDefault: _isDefault,
      );
      widget.onSaved(updated);
    } else {
      final tokenized = PaymentMethodService.tokenizeAndSaveCard(
        rawCardNumber: _numberController.text,
        cardHolderName: _nameController.text,
        expiryMonth: month,
        expiryYear: year,
        cvv: _cvvController.text,
        cardType: _selectedType,
        isDefault: _isDefault,
      );
      widget.onSaved(tokenized);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cardToEdit != null;
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 460, maxHeight: maxDialogHeight),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? "Edit Card Info" : "Add Payment Card",
                      style: AppTypography.titleLarge.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Type Selector
                        Text(
                          "Card Type",
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTypeChip(CardType.debit, "Debit Card"),
                            const SizedBox(width: 10),
                            _buildTypeChip(CardType.credit, "Credit Card"),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Cardholder Name
                        _buildTextField(
                          controller: _nameController,
                          label: "Name on Card",
                          hint: "Alex Morgan",
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Please enter cardholder name"
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Card Number
                        _buildTextField(
                          controller: _numberController,
                          label: "Card Number",
                          hint: "4532 •••• •••• 8920",
                          keyboardType: TextInputType.number,
                          readOnly: isEditing,
                          suffix: _buildBrandBadge(),
                          validator: (v) {
                            if (isEditing) return null;
                            if (v == null || v.replaceAll(' ', '').length < 13) {
                              return "Please enter a valid card number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Expiry & CVV
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _expiryController,
                                label: "Expiry (MM/YY)",
                                hint: "08/28",
                                keyboardType: TextInputType.datetime,
                                validator: (v) {
                                  if (v == null || !v.contains('/')) {
                                    return "e.g. 08/28";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _cvvController,
                                label: isEditing ? "CVV (Unchanged)" : "CVV / CVC",
                                hint: isEditing ? "•••" : "123",
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                readOnly: isEditing,
                                validator: (v) {
                                  if (isEditing) return null;
                                  if (v == null || v.trim().length < 3) {
                                    return "3 or 4 digits";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Security Tokenization Note
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user_rounded,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Your CVV is never stored. Card details are tokenized securely.",
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Set Default
                        Row(
                          children: [
                            Switch(
                              value: _isDefault,
                              onChanged: (val) =>
                                  setState(() => _isDefault = val),
                              activeThumbColor: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Set as default payment card",
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: isEditing ? "Update Card" : "Save & Tokenize Card",
                  onPressed: _save,
                  height: 48,
                  borderRadius: 24,
                  leadingIcon: Icons.shield_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandBadge() {
    String brandName = "Card";
    Color brandColor = AppColors.primary;

    if (_detectedBrand == CardBrand.visa) {
      brandName = "VISA";
      brandColor = const Color(0xFF1A1F71);
    } else if (_detectedBrand == CardBrand.mastercard) {
      brandName = "Mastercard";
      brandColor = const Color(0xFFEB001B);
    } else if (_detectedBrand == CardBrand.rupay) {
      brandName = "RuPay";
      brandColor = const Color(0xFF006699);
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: brandColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        brandName,
        style: AppTypography.bodySmall.copyWith(
          color: brandColor,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildTypeChip(CardType type, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/cards-icon.png",
                width: 14,
                height: 14,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.credit_card_rounded,
                  size: 14,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    bool readOnly = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTypography.bodyMedium.copyWith(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 12.5,
            ),
            suffixIcon: suffix != null
                ? UnconstrainedBox(child: suffix)
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: readOnly
                ? Colors.grey.shade100
                : AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
