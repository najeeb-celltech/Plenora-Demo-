import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/service_card.dart';
import 'service_detail_sheet.dart';

class ApplianceServicesScreen extends StatefulWidget {
  const ApplianceServicesScreen({super.key});

  @override
  State<ApplianceServicesScreen> createState() => _ApplianceServicesScreenState();
}

class _ApplianceServicesScreenState extends State<ApplianceServicesScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const ["All", "Top Rated", "Under ₹999", "Same Day"];

  final List<Map<String, dynamic>> _professionals = const [
    {
      "title": "Refrigerator & Freezer Repair",
      "description":
          "Compressor diagnostics, coolant refill, defrosting issue fix, and seal checks.",
      "price": "₹949/hr",
      "rating": 4.9,
      "imageUrl":
          "https://images.unsplash.com/photo-1581092921461-eab62e97a780?q=80&w=400&auto=format&fit=crop",
    },
    {
      "title": "Washing Machine & Dryer Care",
      "description":
          "Drum belt replacement, drain pump unclogging, and vibration dampening.",
      "price": "₹799/hr",
      "rating": 4.8,
      "imageUrl":
          "https://images.unsplash.com/photo-1610557892470-55d9e80c0bce?q=80&w=400&auto=format&fit=crop",
    },
    {
      "title": "Oven & Stove Servicing",
      "description":
          "Igniter replacement, heating element calibration, and gas burner cleaning.",
      "price": "₹699/hr",
      "rating": 4.7,
      "imageUrl":
          "https://images.unsplash.com/photo-1556911220-e15b29be8c8f?q=80&w=400&auto=format&fit=crop",
    },
    {
      "title": "Dishwasher Repair & Clean",
      "description":
          "Water pump repair, spray arm unclogging, and anti-leak gasket installation.",
      "price": "₹849/hr",
      "rating": 4.9,
      "imageUrl":
          "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=400&auto=format&fit=crop",
    },
  ];

  void _openServiceModal(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailSheet(
        title: service["title"],
        description: service["description"],
        price: service["price"],
        rating: service["rating"],
        imageUrl: service["imageUrl"],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Custom Navigation Bar (Filter icon removed, title centered)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow Circle Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  // Title
                  Text(
                    "Appliance",
                    style: AppTypography.headlineMedium.copyWith(fontSize: 20),
                  ),
                  // Symmetric Spacer Placeholder
                  const SizedBox(width: 44, height: 44),
                ],
              ),
            ),

            // Perfectly Aligned & Unclipped Filter Chip Buttons Row
            SizedBox(
              height: 58,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilterIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(
                          right: index == _filters.length - 1 ? 0 : 10,
                        ),
                        height: 38,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x220E5D44),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                              : const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Text(
                          filter,
                          style: AppTypography.chipText.copyWith(
                            color: isSelected
                                ? AppColors.textWhite
                                : AppColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Main Service List Area
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Section Header: Top Professionals
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Top Professionals",
                        style: AppTypography.headlineMedium
                            .copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "24 Verified pros available today",
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Cards List (Full Borderless Cards)
                  ..._professionals.map((service) {
                    return ServiceCard(
                      title: service["title"],
                      description: service["description"],
                      price: service["price"],
                      rating: service["rating"],
                      imageUrl: service["imageUrl"],
                      onBookNow: () => _openServiceModal(service),
                      onViewDetails: () => _openServiceModal(service),
                    );
                  }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
