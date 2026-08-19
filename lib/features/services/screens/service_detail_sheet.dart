import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';

class ServiceDetailSheet extends StatefulWidget {
  final String title;
  final String description;
  final String price;
  final double rating;
  final String imageUrl;

  const ServiceDetailSheet({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrl,
  });

  @override
  State<ServiceDetailSheet> createState() => _ServiceDetailSheetState();
}

class _ServiceDetailSheetState extends State<ServiceDetailSheet> {
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 0;

  final List<String> _dates = ["Today, Aug 19", "Tomorrow, Aug 20", "Thu, Aug 21"];
  final List<String> _times = ["09:00 AM", "11:30 AM", "02:00 PM", "04:30 PM"];

  void _confirmBooking() {
    Navigator.pop(context); // Close bottom sheet
    showDialog(
      context: context,
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
              "Booking Confirmed!",
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Your booking for '${widget.title}' has been successfully scheduled for ${_dates[_selectedDateIndex]} at ${_times[_selectedTimeIndex]}.",
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: "Great, Thanks!",
                onPressed: () => Navigator.pop(context),
                height: 48,
                borderRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    if (widget.imageUrl.startsWith('assets/')) {
      return Image.asset(
        widget.imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.cleaning_services_rounded,
          size: 60,
          color: AppColors.primary,
        ),
      );
    }
    return Image.network(
      widget.imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.cleaning_services_rounded,
        size: 60,
        color: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar Top
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Service Image Header
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 180,
                width: double.infinity,
                color: AppColors.primaryLight,
                child: _buildImageHeader(),
              ),
            ),
            const SizedBox(height: 16),

            // Title & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTypography.headlineMedium,
                  ),
                ),
                Text(
                  widget.price,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Rating & Verification Row
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: AppColors.starYellow, size: 18),
                const SizedBox(width: 4),
                Text(widget.rating.toStringAsFixed(1),
                    style: AppTypography.ratingText),
                const SizedBox(width: 8),
                Text("• 120+ Completed Bookings",
                    style: AppTypography.bodySmall),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              widget.description,
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: 20),

            // Select Date Section (Borderless Chips)
            Text("Select Date", style: AppTypography.titleMedium),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_dates.length, (index) {
                  final isSelected = _selectedDateIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDateIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x200E5D44),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ]
                            : const [],
                      ),
                      child: Text(
                        _dates[index],
                        style: AppTypography.chipText.copyWith(
                          color: isSelected
                              ? AppColors.textWhite
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),

            // Select Time Slot Section (Borderless Chips)
            Text("Select Time Slot", style: AppTypography.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_times.length, (index) {
                final isSelected = _selectedTimeIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTimeIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x200E5D44),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ]
                          : const [],
                    ),
                    child: Text(
                      _times[index],
                      style: AppTypography.chipText.copyWith(
                        color: isSelected
                            ? AppColors.textWhite
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // Confirm Booking Primary Button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: "Confirm & Schedule",
                onPressed: _confirmBooking,
                height: 54,
                borderRadius: 28,
                leadingIcon: Icons.calendar_month_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
