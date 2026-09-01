import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/service_card.dart';
import 'service_detail_sheet.dart';

class PaintingServicesScreen extends StatefulWidget {
  const PaintingServicesScreen({super.key});

  @override
  State<PaintingServicesScreen> createState() => _PaintingServicesScreenState();
}

class _PaintingServicesScreenState extends State<PaintingServicesScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    "All",
    "Top Rated",
    "Interior",
    "Exterior"
  ];

  final List<Map<String, dynamic>> _professionals = const [
    {
      "title": "Interior Room Painting",
      "description":
          "Wall priming, precision edging, premium matte/satin coats, and furniture protection.",
      "price": "₹849/hr",
      "rating": 4.9,
      "imageUrl":
          "https://images.unsplash.com/photo-1562259949-e8e7689d7828?q=80&w=400&auto=format&fit=crop",
      "tags": ["Interior", "Top Rated", "Under ₹999"],
    },
    {
      "title": "Exterior Wall Coating",
      "description":
          "Weatherproof acrylic finish, pressure wash surface prep, and crack filling.",
      "price": "₹1,099/hr",
      "rating": 4.8,
      "imageUrl":
          "https://images.unsplash.com/photo-1589939705384-5185137a7f0f?q=80&w=400&auto=format&fit=crop",
      "tags": ["Exterior", "Wall"],
    },
    {
      "title": "Accent Wall Design",
      "description":
          "Textured finish, geometric patterns, wallpaper installation, and custom color matching.",
      "price": "₹999/hr",
      "rating": 5.0,
      "imageUrl":
          "https://images.unsplash.com/photo-1513694203232-719a280e022f?q=80&w=400&auto=format&fit=crop",
      "tags": ["Interior", "Top Rated", "Under ₹999"],
    },
    {
      "title": "Cabinet & Wood Polishing",
      "description":
          "Sanding, stain application, polyurethane protective sealant, and trim restoration.",
      "price": "₹749/hr",
      "rating": 4.7,
      "imageUrl":
          "https://images.unsplash.com/photo-1538688525198-9b88f6f53126?q=80&w=400&auto=format&fit=crop",
      "tags": ["Interior", "Under ₹999", "Wood"],
    },
    {
      "title": "Weatherproof Terrace Paint",
      "description":
          "Waterproof elastomeric wall coatings, UV heat protection, and anti-fungal barrier.",
      "price": "₹1,199/hr",
      "rating": 4.9,
      "imageUrl":
          "https://images.unsplash.com/photo-1595846519845-68e298c2edd8?q=80&w=400&auto=format&fit=crop",
      "tags": ["Exterior", "Top Rated", "Waterproof"],
    },
  ];

  List<Map<String, dynamic>> get _filteredProfessionals {
    if (_selectedFilterIndex >= _filters.length) return _professionals;
    final selectedFilter = _filters[_selectedFilterIndex].trim();

    if (selectedFilter.toLowerCase() == "all") {
      return _professionals;
    }

    if (selectedFilter.toLowerCase() == "top rated") {
      final list = _professionals.where((service) {
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
        return _professionals.where((service) {
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
    return _professionals.where((service) {
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
        rating: service["rating"],
        imageUrl: service["imageUrl"],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedServices = _filteredProfessionals;

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
                    "Painting",
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
                        _selectedFilterIndex == 0
                            ? "16 Verified pros available today"
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
