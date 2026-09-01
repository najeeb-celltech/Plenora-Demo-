import 'package:flutter/material.dart';
import '../../../core/services/address_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';

class SavedAddressesScreen extends StatefulWidget {
  final bool selectMode;
  final String? selectedAddressId;
  final ValueChanged<UserAddress>? onAddressSelected;

  const SavedAddressesScreen({
    super.key,
    this.selectMode = false,
    this.selectedAddressId,
    this.onAddressSelected,
  });

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  void _openAddressFormDialog({UserAddress? addressToEdit}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _AddressFormDialog(
        addressToEdit: addressToEdit,
        onSaved: (address) {
          if (addressToEdit == null) {
            AddressService.addAddress(address);
          } else {
            AddressService.updateAddress(address);
          }
          if (widget.selectMode && widget.onAddressSelected != null) {
            widget.onAddressSelected!(address);
          }
        },
      ),
    );
  }

  void _confirmDelete(UserAddress address) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: Text(
          "Delete Address?",
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          "Are you sure you want to remove '${address.typeDisplay}' address (${address.formattedShortAddress})?",
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
              AddressService.deleteAddress(address.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${address.typeDisplay} address deleted"),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Delete"),
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
          widget.selectMode ? "Select Delivery Address" : "Saved Addresses",
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<UserAddress>>(
          valueListenable: AddressService.addressesNotifier,
          builder: (context, addresses, _) {
            if (addresses.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/icons/addresses-icon.png",
                            width: 38,
                            height: 38,
                            color: AppColors.primary,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.location_off_rounded,
                              size: 38,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No Addresses Saved",
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Add your home or office address to book services seamlessly.",
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final address = addresses[index];
                final isSelected = widget.selectMode &&
                    address.id == widget.selectedAddressId;

                return _buildAddressCard(address, isSelected: isSelected);
              },
            );
          },
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
              text: "+ Add New Address",
              onPressed: () => _openAddressFormDialog(),
              height: 50,
              borderRadius: 25,
              leadingIcon: Icons.add_location_alt_rounded,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(UserAddress address, {bool isSelected = false}) {
    String assetIconPath = "assets/icons/addresses-icon.png";
    IconData fallbackIcon = Icons.home_rounded;
    Color typeColor = AppColors.primary;

    if (address.type == AddressType.office) {
      assetIconPath = "assets/icons/office_address-icon.png";
      fallbackIcon = Icons.business_rounded;
      typeColor = const Color(0xFF1E88E5);
    } else if (address.type == AddressType.other) {
      assetIconPath = "assets/icons/addresses-icon.png";
      fallbackIcon = Icons.location_on_rounded;
      typeColor = const Color(0xFFFB8C00);
    }

    return GestureDetector(
      onTap: widget.selectMode
          ? () {
              if (widget.onAddressSelected != null) {
                widget.onAddressSelected!(address);
              }
              Navigator.pop(context, address);
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
                : address.isDefault
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : Colors.grey.shade200,
            width: isSelected || address.isDefault ? 1.5 : 1,
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
            // Top row: Type badge, Default indicator, and action buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              assetIconPath,
                              width: 14,
                              height: 14,
                              color: typeColor,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(fallbackIcon,
                                      size: 14, color: typeColor),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                address.typeDisplay,
                                style: AppTypography.bodySmall.copyWith(
                                  color: typeColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (address.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 12, color: AppColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                "Default",
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
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
                    tooltip: "Edit",
                    onPressed: () =>
                        _openAddressFormDialog(addressToEdit: address),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 19, color: Colors.redAccent),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Delete",
                    onPressed: () => _confirmDelete(address),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Resident Name & Contact
            Row(
              children: [
                Flexible(
                  child: Text(
                    address.fullName,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "• ${address.phoneNumber}",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Full Address description
            Text(
              address.formattedFullAddress,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),

            if (!widget.selectMode && !address.isDefault) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  AddressService.setDefault(address.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "${address.typeDisplay} set as default address"),
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
                        "Set as Default Address",
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
}

class _AddressFormDialog extends StatefulWidget {
  final UserAddress? addressToEdit;
  final ValueChanged<UserAddress> onSaved;

  const _AddressFormDialog({
    this.addressToEdit,
    required this.onSaved,
  });

  @override
  State<_AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<_AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late AddressType _selectedType;
  late final TextEditingController _customLabelController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _houseController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipController;
  late final TextEditingController _landmarkController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final a = widget.addressToEdit;
    _selectedType = a?.type ?? AddressType.home;
    _customLabelController = TextEditingController(text: a?.customLabel ?? '');
    _fullNameController =
        TextEditingController(text: a?.fullName ?? 'Alex Morgan');
    _phoneController =
        TextEditingController(text: a?.phoneNumber ?? '+1 800-555-0199');
    _houseController = TextEditingController(text: a?.houseNumber ?? '');
    _streetController = TextEditingController(text: a?.streetArea ?? '');
    _cityController = TextEditingController(text: a?.city ?? 'New Delhi');
    _stateController = TextEditingController(text: a?.state ?? 'Delhi');
    _zipController = TextEditingController(text: a?.zipCode ?? '110016');
    _landmarkController = TextEditingController(text: a?.landmark ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _customLabelController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _houseController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final newAddress = UserAddress(
      id: widget.addressToEdit?.id ??
          "addr_${DateTime.now().millisecondsSinceEpoch}",
      type: _selectedType,
      customLabel: _selectedType == AddressType.other
          ? _customLabelController.text.trim()
          : null,
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      houseNumber: _houseController.text.trim(),
      streetArea: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipController.text.trim(),
      landmark: _landmarkController.text.trim().isEmpty
          ? null
          : _landmarkController.text.trim(),
      isDefault: _isDefault,
    );

    widget.onSaved(newAddress);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.addressToEdit != null;
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480, maxHeight: maxDialogHeight),
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
                      isEditing ? "Edit Address" : "Add Service Address",
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
                        // 1. Address Type chips
                        Text(
                          "Address Type",
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTypeChip(
                              AddressType.home,
                              "Home",
                              "assets/icons/addresses-icon.png",
                              Icons.home_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildTypeChip(
                              AddressType.office,
                              "Office",
                              "assets/icons/office_address-icon.png",
                              Icons.business_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildTypeChip(
                              AddressType.other,
                              "Other",
                              "assets/icons/addresses-icon.png",
                              Icons.location_on_rounded,
                            ),
                          ],
                        ),
                        if (_selectedType == AddressType.other) ...[
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _customLabelController,
                            label: "Custom Label (e.g. Mom's House, Studio)",
                            hint: "Enter custom label",
                            validator: (v) => v == null || v.trim().isEmpty
                                ? "Please enter label"
                                : null,
                          ),
                        ],
                        const SizedBox(height: 14),

                        // 2. Personal info
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _fullNameController,
                                label: "Full Name",
                                hint: "Alex Morgan",
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? "Required"
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                controller: _phoneController,
                                label: "Phone Number",
                                hint: "+1 800-555-0199",
                                keyboardType: TextInputType.phone,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? "Required"
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 3. House / Flat & Street / Area
                        _buildTextField(
                          controller: _houseController,
                          label: "House / Flat / Building No.",
                          hint: "Flat 402, Block B, Green Heights",
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Please enter house/building info"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _streetController,
                          label: "Street / Area / Locality",
                          hint: "Park Avenue, Sector 15",
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Please enter street/area"
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // 4. City, State, PIN
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildTextField(
                                controller: _cityController,
                                label: "City",
                                hint: "New Delhi",
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? "Required"
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                controller: _stateController,
                                label: "State",
                                hint: "Delhi",
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? "Required"
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                controller: _zipController,
                                label: "PIN Code",
                                hint: "110016",
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? "Required"
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 5. Landmark / Instructions
                        _buildTextField(
                          controller: _landmarkController,
                          label: "Landmark / Additional Instructions (Optional)",
                          hint: "Near Metro Gate 2, Ring bell twice",
                        ),
                        const SizedBox(height: 14),

                        // 6. Default Switch
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
                                "Set as default service address",
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
                  text: isEditing ? "Update Address" : "Save Address",
                  onPressed: _save,
                  height: 48,
                  borderRadius: 24,
                  leadingIcon: Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(
    AddressType type,
    String label,
    String assetPath,
    IconData fallbackIcon,
  ) {
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
                assetPath,
                width: 14,
                height: 14,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                errorBuilder: (context, error, stackTrace) => Icon(
                  fallbackIcon,
                  size: 14,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
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
          keyboardType: keyboardType,
          validator: validator,
          style: AppTypography.bodyMedium.copyWith(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 12.5,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: AppColors.background,
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
