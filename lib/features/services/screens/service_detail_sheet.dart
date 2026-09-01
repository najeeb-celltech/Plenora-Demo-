import 'package:flutter/material.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/schedule_dialog.dart';
import '../../cart/screens/checkout_screen.dart';

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
  void _confirmBooking() async {
    final schedule = await showScheduleAppointmentDialog(
      context,
      title: "Schedule Appointment",
      buttonText: "Confirm & Continue",
    );

    if (schedule != null && mounted) {
      final directItem = CartItem(
        title: widget.title,
        description: widget.description,
        price: widget.price,
        priceNumeric: CartService.parsePrice(widget.price),
        rating: widget.rating,
        imageUrl: widget.imageUrl,
        category: "Service",
      );

      final nav = Navigator.of(context);
      nav.pop(); // Close bottom sheet

      nav.push(
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            directItem: directItem,
            selectedDate: schedule['date'],
            selectedTime: schedule['time'],
          ),
        ),
      );
    }
  }

  void _addToCart() {
    CartService.addService(
      title: widget.title,
      description: widget.description,
      price: widget.price,
      rating: widget.rating,
      imageUrl: widget.imageUrl,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added '${widget.title}' to Service Cart!"),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
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

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getWorkIncluded() {
    final titleLower = widget.title.toLowerCase();
    if (titleLower.contains('kitchen')) {
      return [
        "Deep countertop grease & oil stain removal",
        "Inside & outside oven, stove & hood cleaning",
        "Cabinet exterior polishing & sanitization",
        "Sink descaling & anti-bacterial disinfections",
      ];
    } else if (titleLower.contains('bathroom')) {
      return [
        "Tile gunk scrubbing & hard water stain removal",
        "Mirror, glass shower screen & chrome polishing",
        "Toilet & bathtub deep sanitization",
        "Drain unclogging & mold prevention treatment",
      ];
    } else if (titleLower.contains('carpet') || titleLower.contains('sofa')) {
      return [
        "Hot water extraction & steam sanitization",
        "Stain & odor removal treatment",
        "Dust mite & allergen extraction",
        "Fabric protector application",
      ];
    } else if (titleLower.contains('wiring') || titleLower.contains('electrical')) {
      return [
        "Circuit & breaker safety inspection",
        "Grounding & voltage stability check",
        "Faulty wire replacement & safe insulation",
        "Post-fix load testing & guarantee report",
      ];
    } else if (titleLower.contains('paint')) {
      return [
        "Surface sanding & hole patching prep",
        "Furniture & floor protective masking",
        "2 coats of premium washable paint",
        "Post-paint cleanup & edge inspection",
      ];
    }
    return [
      "Complete area inspection & surface prep",
      "Deep specialized treatment & sanitization",
      "Eco-friendly, child & pet safe materials",
      "Final quality check & 30-day guarantee",
    ];
  }

  List<Map<String, String>> _getTechnicianSteps() {
    return [
      {
        "title": "1. Assessment & Setup",
        "desc": "Inspects work site, measures scope, and protects furniture.",
      },
      {
        "title": "2. Deep Treatment",
        "desc": "Applies professional grade tools and eco-friendly solutions.",
      },
      {
        "title": "3. Quality Sanitization",
        "desc": "Ensures anti-bacterial protection and clean finishing.",
      },
      {
        "title": "4. Final Inspection",
        "desc": "Reviews completed work with you for 100% satisfaction.",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Column(
                children: [
                  // Unified Drag Handle Top Bar (Same AppColors.background color)
                  Container(
                    width: double.infinity,
                    color: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  // Vertically Scrollable Details Body (Generous 140dp bottom padding)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              color: AppColors.primaryLight,
                              child: _buildImageHeader(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title & Price Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: AppTypography.headlineMedium
                                      .copyWith(fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                widget.price,
                                style: AppTypography.headlineMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
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
                              Flexible(
                                child: Text(
                                  "• 120+ Completed Bookings",
                                  style: AppTypography.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Perfectly Spaced & Unclipped Info/Feature Boxes
                          SizedBox(
                            height: 44,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
                              child: Row(
                                children: [
                                  _buildBadge(
                                      Icons.timer_outlined, "2-3 Hours"),
                                  const SizedBox(width: 8),
                                  _buildBadge(Icons.verified_outlined,
                                      "30-Day Guarantee"),
                                  const SizedBox(width: 8),
                                  _buildBadge(
                                      Icons.eco_outlined, "Eco-Friendly"),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // About Service Description
                          Text(
                            "About Service",
                            style:
                                AppTypography.titleLarge.copyWith(fontSize: 17),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Work Included Checklist
                          Text(
                            "Work Included",
                            style:
                                AppTypography.titleLarge.copyWith(fontSize: 17),
                          ),
                          const SizedBox(height: 12),
                          ..._getWorkIncluded().map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppColors.primary, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                          const SizedBox(height: 20),

                          // What Technician Will Do
                          Text(
                            "What Technician Will Do",
                            style:
                                AppTypography.titleLarge.copyWith(fontSize: 17),
                          ),
                          const SizedBox(height: 12),
                          ..._getTechnicianSteps().map((step) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x08000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.engineering_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          step["title"]!,
                                          style: AppTypography.titleMedium
                                              .copyWith(fontSize: 14.5),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          step["desc"]!,
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                  color:
                                                      AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Directly Positioned Floating Action Buttons (0px overflow, responsive flex)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppColors.background.withValues(alpha: 0.96),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        // Add to Service Floating Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            icon: const Icon(Icons.add_shopping_cart_rounded,
                                size: 16),
                            label: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Add to Service',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Schedule Now Floating Button (0px overflow guarantee)
                        Expanded(
                          child: PrimaryButton(
                            text: "Schedule Now",
                            onPressed: _confirmBooking,
                            height: 48,
                            borderRadius: 24,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            leadingIcon: Icons.calendar_month_rounded,
                          ),
                        ),
                      ],
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
}
