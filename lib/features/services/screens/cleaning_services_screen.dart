import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/service_card.dart';
import 'service_detail_sheet.dart';

class CleaningServicesScreen extends StatefulWidget {
  const CleaningServicesScreen({super.key});

  @override
  State<CleaningServicesScreen> createState() => _CleaningServicesScreenState();
}

class _CleaningServicesScreenState extends State<CleaningServicesScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const ["All", "Top Rated", "Under \$30", "Nearby"];

  final List<Map<String, dynamic>> _professionals = const [
    {
      "title": "Kitchen Sparkle Service",
      "description":
          "Detailed grease and appliance cleaning, inside oven/fridge treatment, and counter shine.",
      "price": "\$35/hr",
      "rating": 4.8,
      "imageUrl": "assets/image/kitchen-service.png",
    },
    {
      "title": "Bathroom Cleaning",
      "description":
          "Tile gunk scrubbing, mirror shine, bathtub sanitization, and anti-bacterial disinfections.",
      "price": "\$25/hr",
      "rating": 4.9,
      "imageUrl": "assets/image/bathroom-service.png",
    },
    {
      "title": "Carpet Cleaning",
      "description":
          "Stain removal and full upholstery cleaning using hot water extraction techniques.",
      "price": "\$29/hr",
      "rating": 4.9,
      "imageUrl":
          "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=400&auto=format&fit=crop",
    },
    {
      "title": "Full House Deep Sanitation",
      "description":
          "Whole home eco-friendly disinfection, floor scrubbing, window cleaning, and trash clearance.",
      "price": "\$42/hr",
      "rating": 5.0,
      "imageUrl":
          "https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?q=80&w=400&auto=format&fit=crop",
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
            // Top Custom Navigation Bar (Borderless Buttons)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow Circle Button (Borderless)
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
                    "Cleaning",
                    style: AppTypography.headlineMedium.copyWith(fontSize: 20),
                  ),
                  // Filter Sliders Button (Borderless)
                  Container(
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
                      Icons.tune_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Scrollable Filter Chips (Borderless)
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
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
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x200E5D44),
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Main Service List Area
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Section Header: Top Professionals
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
                            "28 Verified pros available today",
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Sort: ",
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            "Top",
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
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
