import 'package:flutter/material.dart';
import '../services/datetime_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'primary_button.dart';

/// Opens a clean, centered date & time selection popup.
/// Returns a map with {'date': selectedDate, 'time': selectedTime} or null if dismissed.
Future<Map<String, String>?> showScheduleAppointmentDialog(
  BuildContext context, {
  String title = "Schedule Appointment",
  String buttonText = "Confirm Date & Time",
  String? initialDate,
  String? initialTime,
}) {
  final dates = AppDateTimeUtils.getAvailableDates(count: 6);
  final times = AppDateTimeUtils.getAvailableTimes();

  int selectedDateIndex = 0;
  if (initialDate != null) {
    final idx = dates.indexOf(initialDate);
    if (idx >= 0) selectedDateIndex = idx;
  }

  int selectedTimeIndex = 0;
  if (initialTime != null) {
    final idx = times.indexOf(initialTime);
    if (idx >= 0) selectedTimeIndex = idx;
  }

  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final selectedDate = dates[selectedDateIndex];
          final selectedTime = times[selectedTimeIndex];

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(22),
            content: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Title and Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.titleLarge.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext, null),
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
                  const SizedBox(height: 6),
                  Text(
                    "Select arrival date and time for your home services.",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Service Date Label
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Service Date",
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Horizontal Scrollable Date Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(dates.length, (index) {
                        final isSelected = selectedDateIndex == index;
                        return GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedDateIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              dates[index],
                              style: AppTypography.bodySmall.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Service Time Label
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Service Time",
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Wrap of Time Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(times.length, (index) {
                      final isSelected = selectedTimeIndex == index;
                      return GestureDetector(
                        onTap: () =>
                            setModalState(() => selectedTimeIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            times[index],
                            style: AppTypography.bodySmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 18),

                  // Selected Slot Summary Preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_available_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "$selectedDate • $selectedTime",
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Confirm & Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: buttonText,
                      onPressed: () {
                        Navigator.pop(dialogContext, {
                          'date': selectedDate,
                          'time': selectedTime,
                        });
                      },
                      height: 48,
                      borderRadius: 24,
                      leadingIcon: Icons.arrow_forward_rounded,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
