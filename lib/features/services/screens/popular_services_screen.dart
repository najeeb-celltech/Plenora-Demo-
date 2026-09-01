import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/service_card.dart';
import 'service_detail_sheet.dart';

class PopularServicesScreen extends StatefulWidget {
  const PopularServicesScreen({super.key});

  @override
  State<PopularServicesScreen> createState() => _PopularServicesScreenState();
}

class _PopularServicesScreenState extends State<PopularServicesScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    "All",
    "Top Rated",
    "Under ₹999",
    "Cleaning",
    "Electrical",
    "Painting",
    "Appliances",
  ];

  final List<Map<String, dynamic>> _popularServices = const [
    {
      "title": "Carpet Cleaning",
      "category": "Cleaning",
      "description":
          "Deep steam sanitization, stain removal, and fabric refresh for living room furniture and carpets.",
      "price": "₹799/hr",
      "rating": 4.9,
      "imageUrl":
          "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=400&auto=format&fit=crop",
      "tags": ["Cleaning", "Top Rated", "Under ₹999", "Carpet"],
    },
    {
      "title": "Kitchen Sparkle Service",
      "category": "Cleaning",
      "description":
          "Heavy grease removal, cabinet polishing, exhaust chimney scrub, and counter shine.",
      "price": "₹999/hr",
      "rating": 4.8,
      "imageUrl": "assets/image/kitchen-service.png",
      "tags": ["Cleaning", "Under ₹999", "Kitchen"],
    },
    {
      "title": "Bathroom Cleaning & Disinfection",
      "category": "Cleaning",
      "description":
          "Tile scale scrub, mirror shine, bathtub sanitization, and anti-bacterial deep cleaning.",
      "price": "₹699/hr",
      "rating": 4.9,
      "imageUrl": "assets/image/bathroom-service.png",
      "tags": ["Cleaning", "Top Rated", "Under ₹999", "Bathroom"],
    },
    {
      "title": "Full House Deep Sanitation",
      "category": "Cleaning",
      "description":
          "Whole home eco-friendly disinfection, floor scrubbing, window cleaning, and trash clearance.",
      "price": "₹1,499/hr",
      "rating": 5.0,
      "imageUrl":
          "https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?q=80&w=400&auto=format&fit=crop",
      "tags": ["Cleaning", "Top Rated", "Deep Clean", "Sanitation"],
    },
    {
      "title": "Wiring & Short-Circuit Fix",
      "category": "Electrical",
      "description":
          "Full home circuit inspection, spark leak troubleshooting, and breaker box maintenance.",
      "price": "₹899/hr",
      "rating": 4.9,
      "imageUrl":
          "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=400&auto=format&fit=crop",
      "tags": ["Electrical", "Emergency", "Top Rated", "Under ₹999", "Wiring"],
    },
    {
      "title": "Light Fixture & Fan Mounting",
      "category": "Electrical",
      "description":
          "Chandelier, LED recessed lights, ceiling fan wiring, and smart dimmers setup.",
      "price": "₹749/hr",
      "rating": 4.8,
      "imageUrl":
          "https://images.unsplash.com/photo-1565814636199-ae8133055c1c?q=80&w=400&auto=format&fit=crop",
      "tags": ["Electrical", "Under ₹999", "Lighting", "Installation"],
    },
    {
      "title": "Interior Room Painting",
      "category": "Painting",
      "description":
          "Wall priming, precision edging, premium matte coats, and complete furniture protection.",
      "price": "₹849/hr",
      "rating": 4.9,
      "imageUrl":
          "https://images.unsplash.com/photo-1562259949-e8e7689d7828?q=80&w=400&auto=format&fit=crop",
      "tags": ["Painting", "Interior", "Top Rated", "Under ₹999"],
    },
    {
      "title": "Accent Wall & Texture Art",
      "category": "Painting",
      "description":
          "Textured artistic finish, geometric patterns, wallpaper installation, and custom color matching.",
      "price": "₹999/hr",
      "rating": 5.0,
      "imageUrl":
          "https://images.unsplash.com/photo-1513694203232-719a280e022f?q=80&w=400&auto=format&fit=crop",
      "tags": ["Painting", "Interior", "Top Rated", "Under ₹999"],
    },
    {
      "title": "AC Maintenance & Gas Refill",
      "category": "Appliances",
      "description":
          "Filter cleaning, cooling coil foam wash, gas pressure check, and drain line unclogging.",
      "price": "₹899/hr",
      "rating": 4.9,
      "imageUrl":
          "https://images.unsplash.com/photo-1621905252507-b35492cc74b4?q=80&w=400&auto=format&fit=crop",
      "tags": ["Appliances", "Top Rated", "Under ₹999", "AC", "Cooling"],
    },
    {
      "title": "Refrigerator & Freezer Repair",
      "category": "Appliances",
      "description":
          "Compressor testing, refrigerant leak detection, thermostat fix, and gasket seal replacement.",
      "price": "₹749/hr",
      "rating": 4.8,
      "imageUrl":
          "https://images.unsplash.com/photo-1584622781564-1d987f7333c1?q=80&w=400&auto=format&fit=crop",
      "tags": ["Appliances", "Under ₹999", "Refrigerator"],
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    if (_selectedFilterIndex >= _filters.length) return _popularServices;
    final selectedFilter = _filters[_selectedFilterIndex].trim();

    if (selectedFilter.toLowerCase() == "all") {
      return _popularServices;
    }

    if (selectedFilter.toLowerCase() == "top rated") {
      final list = _popularServices.where((service) {
        final rating = (service["rating"] as num?)?.toDouble() ?? 0.0;
        return rating >= 4.9;
      }).toList();
      list.sort((a, b) => ((b["rating"] as num?)?.toDouble() ?? 0.0)
          .compareTo((a["rating"] as num?)?.toDouble() ?? 0.0));
      return list;
    }

    // Dynamic price match: e.g. "Under ₹999", "Under ₹30", "Under ₹1000", "< ₹999"
    final priceFilterRegex =
        RegExp(r'under\s*([₹$€£]?\s*[\d,]+)', caseSensitive: false);
    final match = priceFilterRegex.firstMatch(selectedFilter);
    if (match != null) {
      final numStr = match.group(1)!.replaceAll(RegExp(r'[^\d.]'), '');
      final threshold = double.tryParse(numStr);
      if (threshold != null) {
        return _popularServices.where((service) {
          final priceStr = service["price"]?.toString() ?? '';
          final cleanPrice = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
          final priceVal = double.tryParse(cleanPrice);
          if (priceVal != null) {
            return priceVal <= threshold;
          }
          return false;
        }).toList();
      }
    }

    // Category / Tag / Keyword matching
    final filterLower = selectedFilter.toLowerCase();
    return _popularServices.where((service) {
      final category = (service["category"]?.toString() ?? '').toLowerCase();
      if (category == filterLower) return true;

      final tags = (service["tags"] as List<dynamic>?)
              ?.map((t) => t.toString().toLowerCase())
              .toList() ??
          [];
      if (tags.contains(filterLower)) return true;

      final title = (service["title"]?.toString() ?? '').toLowerCase();
      final description =
          (service["description"]?.toString() ?? '').toLowerCase();
      if (title.contains(filterLower) || description.contains(filterLower)) {
        return true;
      }

      return false;
    }).toList();
  }

  void _openServiceModal(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailSheet(
        title: service["title"],
        description: service["description"],
        price: service["price"],
        rating: (service["rating"] as num).toDouble(),
        imageUrl: service["imageUrl"],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedServices = _filteredServices;

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
                  Expanded(
                    child: Text(
                      "Popular Services",
                      style: AppTypography.headlineMedium.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Symmetric Spacer Placeholder
                  const SizedBox(width: 44, height: 44),
                ],
              ),
            ),

            // Perfectly Aligned & Unclipped Filter Chip Buttons Row (Identical to other service pages)
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
                        _selectedFilterIndex == 0
                            ? "${_popularServices.length} Top Rated Services Available"
                            : "${displayedServices.length} pros available for \"${_filters[_selectedFilterIndex]}\"",
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Cards List or Empty State
                  if (displayedServices.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 40, horizontal: 20),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              color: AppColors.primary,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No services found",
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "No services match the \"${_filters[_selectedFilterIndex]}\" filter.",
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilterIndex = 0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Show All Services",
                                style: AppTypography.chipText.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...displayedServices.map((service) {
                      return ServiceCard(
                        title: service["title"],
                        description: service["description"],
                        price: service["price"],
                        rating: (service["rating"] as num).toDouble(),
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
