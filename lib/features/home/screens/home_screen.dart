import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/datetime_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/floating_nav_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/service_card.dart';
import '../../auth/screens/login_screen.dart';
import '../../cart/screens/service_cart_screen.dart';
import '../../services/screens/appliance_services_screen.dart';
import '../../services/screens/cleaning_services_screen.dart';
import '../../services/screens/electrical_services_screen.dart';
import '../../services/screens/painting_services_screen.dart';
import '../../services/screens/popular_services_screen.dart';
import '../../services/screens/service_detail_sheet.dart';
import '../../profile/screens/payment_methods_screen.dart';
import '../../profile/screens/saved_addresses_screen.dart';
import 'notifications_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _FaqItemData {
  final String question;
  final String answer;
  bool isExpanded;

  _FaqItemData({
    required this.question,
    required this.answer,
  }) : isExpanded = false;
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  late List<NotificationItemData> _notifications;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() {
    final now = DateTime.now();
    _notifications = [
      NotificationItemData(
        id: "1",
        title: "50% Off Special Discount!",
        message:
            "Enjoy 50% off on your first carpet deep cleaning booking today.",
        timestamp: now.subtract(const Duration(minutes: 10)),
        icon: Icons.local_offer_rounded,
        iconColor: Colors.amber,
        isRead: false,
      ),
      NotificationItemData(
        id: "2",
        title: "Booking Confirmed",
        message:
            "Your Premium Home Cleaning is scheduled for ${AppDateTimeUtils.getTomorrowScheduleFormatted()}.",
        timestamp: now.subtract(const Duration(hours: 1)),
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.primary,
        isRead: false,
      ),
      NotificationItemData(
        id: "3",
        title: "New Appliance Specialist Nearby",
        message:
            "Verified appliance repair experts are now available in your area.",
        timestamp: now.subtract(const Duration(hours: 3)),
        icon: Icons.home_repair_service_rounded,
        iconColor: Colors.blueAccent,
        isRead: true,
      ),
      NotificationItemData(
        id: "4",
        title: "Welcome to Plenora!",
        message:
            "Explore top-rated home cleaning, electrical, painting, and appliance services.",
        timestamp: now.subtract(const Duration(days: 1)),
        icon: Icons.auto_awesome_rounded,
        iconColor: Colors.purpleAccent,
        isRead: true,
      ),
    ];
  }

  final List<CategoryItem> _categories = const [
    CategoryItem(
      name: "Cleaning",
      iconUrl:
          "https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=200&auto=format&fit=crop",
      iconData: Icons.cleaning_services_rounded,
      assetPath: "assets/icons/cleaning-icon.png",
    ),
    CategoryItem(
      name: "Electrical",
      iconUrl:
          "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=200&auto=format&fit=crop",
      iconData: Icons.electrical_services_rounded,
      assetPath: "assets/icons/electrical-icon.png",
    ),
    CategoryItem(
      name: "Painting",
      iconUrl:
          "https://images.unsplash.com/photo-1562259949-e8e7689d7828?q=80&w=200&auto=format&fit=crop",
      iconData: Icons.format_paint_rounded,
      assetPath: "assets/icons/painting-icon.png",
    ),
    CategoryItem(
      name: "Appliance",
      iconUrl:
          "https://images.unsplash.com/photo-1581092921461-eab62e97a780?q=80&w=200&auto=format&fit=crop",
      iconData: Icons.home_repair_service_rounded,
      assetPath: "assets/icons/appliance-icon.png",
    ),
  ];

  final List<Map<String, dynamic>> _popularServices = const [
    {
      "title": "Carpet Cleaning",
      "category": "Cleaning",
      "description":
          "Deep steam sanitization and stain removal for living room furniture and carpets.",
      "price": "₹799/hr",
      "rating": 4.9,
      "imageUrl":
          "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=300&auto=format&fit=crop",
    },
    {
      "title": "Kitchen Service",
      "category": "Cleaning",
      "description":
          "Grease removal, cabinet polishing, and thorough appliance scrubbing.",
      "price": "₹999/hr",
      "rating": 4.8,
      "imageUrl": "assets/image/kitchen-service.png",
    },
    {
      "title": "Bathroom Cleaning",
      "category": "Cleaning",
      "description":
          "Tile gunk scrubbing, mirror shine, and anti-bacterial disinfections.",
      "price": "₹699/hr",
      "rating": 4.9,
      "imageUrl": "assets/image/bathroom-service.png",
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _openNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationsSheet(
        notifications: _notifications,
        onNotificationsChanged: (updatedList) {
          setState(() {
            _notifications = updatedList;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentNavIndex == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (_currentNavIndex != 0) {
          setState(() {
            _currentNavIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentNavIndex,
            children: [
              _buildHomeContent(),
              _buildBookingsTab(),
              ServiceCartScreen(
                onExploreServices: () {
                  setState(() {
                    _currentNavIndex = 0;
                  });
                },
              ),
              _buildProfileTab(),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            alignment: Alignment.bottomCenter,
            height: 76,
            child: FloatingNavBar(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() {
                  _currentNavIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final hasUnread = _notifications.any((element) => !element.isRead);

    // Active real-time search filtering across titles, descriptions, and category tags
    final filteredServices = _popularServices.where((service) {
      final title = service["title"].toString().toLowerCase();
      final description = service["description"].toString().toLowerCase();
      final category = (service["category"] ?? "").toString().toLowerCase();
      final query = _searchQuery.trim().toLowerCase();
      return query.isEmpty ||
          title.contains(query) ||
          description.contains(query) ||
          category.contains(query);
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Welcome Back Text & Notification Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Hello, Palash",
                      style: AppTypography.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Functional Notification Bell Icon Button with dynamic unread state
              GestureDetector(
                onTap: _openNotifications,
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/notifications-icon.png",
                        width: 22,
                        height: 22,
                        color: AppColors.textPrimary,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                      if (hasUnread)
                        Positioned(
                          top: 10,
                          right: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Full-Width Functional Search Input Field
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search for service...",
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                      });
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Categories Header
          Text(
            "Categories",
            style: AppTypography.titleLarge,
          ),

          const SizedBox(height: 14),

          // Perfectly Aligned & Responsive Category Boxes
          LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth = (constraints.maxWidth - (10 * 3)) / 4;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_categories.length, (index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategoryIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                      if (category.name == "Cleaning") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CleaningServicesScreen(),
                          ),
                        );
                      } else if (category.name == "Electrical") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ElectricalServicesScreen(),
                          ),
                        );
                      } else if (category.name == "Painting") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PaintingServicesScreen(),
                          ),
                        );
                      } else if (category.name == "Appliance") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ApplianceServicesScreen(),
                          ),
                        );
                      }
                    },
                    child: SizedBox(
                      width: itemWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Squircle Icon Container (64x64, perfectly aligned)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected
                                  ? const [
                                      BoxShadow(
                                        color: Color(0x1A000000),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : const [
                                      BoxShadow(
                                        color: Color(0x0C000000),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: category.assetPath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.all(7.0),
                                        child: Image.asset(
                                          category.assetPath!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              Icon(
                                            category.iconData,
                                            size: 28,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      category.iconData,
                                      size: 28,
                                      color: AppColors.textPrimary,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category.name,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 24),

          // Smart Home Service Banner Card
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF04261B),
                  Color(0xFF0B533D),
                  Color(0xFF1A8765),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Image responsively positioned and shifted slightly to the left
                Positioned(
                  left: (screenWidth - 40) * 0.28,
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: Image.asset(
                    "assets/image/smart-home-service.png",
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                ),
                // Left side text column layered over the banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Limited offer",
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Banner Title
                      Text(
                        "Smart Home\nService",
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textWhite,
                          height: 1.2,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Sleek Compact Action Button
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: PrimaryButton(
                          text: "Book Now",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CleaningServicesScreen(),
                              ),
                            );
                          },
                          backgroundColor: AppColors.surface,
                          textColor: AppColors.primary,
                          height: 30,
                          borderRadius: 15,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          leadingIcon: Icons.calendar_today_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Popular Services Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Popular services",
                  style: AppTypography.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PopularServicesScreen(),
                    ),
                  );
                },
                child: Text(
                  "View All",
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // List of Popular Service Items or Minimal "No results found" State
          if (filteredServices.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 44,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "No results found",
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "No services match \"$_searchQuery\". Try checking spelling or searching for another service.",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...filteredServices.map((service) {
              return ServiceCard(
                title: service["title"],
                description: service["description"] ?? "",
                price: service["price"],
                rating: service["rating"],
                imageUrl: service["imageUrl"],
                isHorizontalCompact: true,
                onBookNow: () => _openServiceModal(service),
                onViewDetails: () => _openServiceModal(service),
              );
            }),
        ],
      ),
    );
  }

  void _showCancelBookingConfirmation(BookedService item) {
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
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: Colors.redAccent,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Cancel this service?",
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Are you sure you want to cancel '${item.title}' scheduled for ${item.date} at ${item.time}?",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Keep Booking",
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(context);
                      BookingService.cancelBooking(item.id);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text("Booking for '${item.title}' has been cancelled."),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Cancel Service",
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsTab() {
    return ValueListenableBuilder<List<BookedService>>(
      valueListenable: BookingService.bookingsNotifier,
      builder: (context, allBookings, child) {
        final activeBookings =
            allBookings.where((b) => b.status != "CANCELLED").toList();

        // Perfectly Centered Empty Bookings View
        if (activeBookings.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Bookings", style: AppTypography.headlineLarge),
                const SizedBox(height: 4),
                Text(
                  "Track active and past home service appointments.",
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  softWrap: true,
                ),

                // Vertically & Horizontally Centered Empty Container
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 12,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              "No bookings yet",
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Your scheduled home service appointments will appear here.",
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Active Bookings List View
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("My Bookings", style: AppTypography.headlineLarge),
              const SizedBox(height: 4),
              Text(
                "Track active and past home service appointments.",
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                softWrap: true,
              ),
              const SizedBox(height: 24),
              ...activeBookings.map((item) {
                final isConfirmed = item.status == "CONFIRMED";

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0E000000),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              item.status,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            item.price,
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.title,
                        style: AppTypography.titleLarge.copyWith(
                          fontSize: 16.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              size: 15, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            "${item.date} • ${item.time}",
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (item.address != null) ...[
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 15, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.address!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (item.paymentMethod != null) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.payment_rounded,
                                size: 15, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              item.paymentMethod!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isConfirmed) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showCancelBookingConfirmation(item),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.redAccent.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                            ),
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.redAccent,
                              size: 16,
                            ),
                            label: Text(
                              "Cancel Service",
                              style: AppTypography.buttonText.copyWith(
                                color: Colors.redAccent,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  static const String _termsPreview =
      "Welcome to Plenora Cleaning & Home Services (\"Plenora\"). By downloading, accessing, or scheduling home care services through our application, you agree to these Terms & Conditions.\n\n"
      "1. Service Bookings & Availability\n"
      "All service requests submitted represent requests to schedule home care professionals. Bookings are subject to professional availability and confirmation in designated geographic regions.\n\n"
      "2. Pricing, Charges & Payments\n"
      "Prices displayed represent upfront estimates. Payments may be rendered via credit/debit cards, UPI wallets, or cash upon service completion after job inspection.";

  static const String _termsFullText =
      "Welcome to Plenora Cleaning & Home Services (\"Plenora\", \"we\", \"us\", or \"our\"). By downloading, accessing, or using our mobile application and scheduling services, you agree to be bound by these Terms & Conditions.\n\n"
      "1. Service Bookings\n"
      "All service bookings submitted through the Plenora app represent requests to schedule home care professionals. Bookings are subject to professional availability and confirmation.\n\n"
      "2. Service Availability\n"
      "Plenora operates in designated geographic regions. Service availability, time slots, and provider assignment may vary depending on location and demand.\n\n"
      "3. Pricing & Charges\n"
      "All prices displayed in the app are upfront estimates based on selected service parameters. Final charges will reflect agreed-upon service additions or specialized requirements requested on-site.\n\n"
      "4. Payments\n"
      "Payments may be rendered via authorized credit/debit cards, digital UPI wallets, or cash upon service completion. Cash payments must be handed directly to the assigned professional after job inspection.\n\n"
      "5. Coupons & Discounts\n"
      "Promo codes, coupons, and referral credits are subject to specific eligibility rules. Coupons must be applied prior to checkout and cannot be combined unless explicitly stated.\n\n"
      "6. Scheduling & Rescheduling\n"
      "Users may reschedule appointments up to 2 hours prior to the scheduled start time without penalty via the app. Rescheduling requests within 2 hours may incur a nominal re-dispatch fee.\n\n"
      "7. Cancellation & Refunds\n"
      "Cancellations made at least 2 hours before appointment time qualify for a 100% full refund. Cancellations made less than 2 hours prior or upon provider arrival may incur a minimum service cancellation fee.\n\n"
      "8. Service Duration\n"
      "Approximate service durations (e.g., 2–3 hours) are estimates. Actual completion time depends on home size, property condition, and requested add-ons.\n\n"
      "9. Customer Responsibilities\n"
      "Customers must provide a safe, non-hazardous work environment, working electricity, running water, and adequate access to work areas.\n\n"
      "10. Access to Property\n"
      "Customers agree to secure authorized entry to the premises for assigned service professionals at the scheduled appointment time.\n\n"
      "11. Service Quality & 30-Day Guarantee\n"
      "We strive for 100% customer satisfaction. If any cleaned area fails to meet reasonable quality standards, notify us within 30 days for a free re-cleaning of the affected service area.\n\n"
      "12. Damage & Liability Limitations\n"
      "While our service professionals exercise extreme care, Plenora's liability for accidental damage during service is limited to direct proven damages up to ₹25,000 per incident. Plenora is not liable for pre-existing property wear or fragile, unanchored items.\n\n"
      "13. Third-Party Service Professionals\n"
      "Service professionals are independent contractors background-vetted by Plenora. Plenora maintains rigorous quality and safety standards for all onboarded partners.\n\n"
      "14. Account Responsibilities\n"
      "Users are responsible for maintaining the confidentiality of their account credentials and for all activities conducted under their account.\n\n"
      "15. Prohibited Use\n"
      "Users shall not use the app for illegal activities, abusive behavior toward service professionals, or unauthorized commercial exploitation.\n\n"
      "16. Intellectual Property\n"
      "All logos, software code, graphic interfaces, and content within the Plenora app are the exclusive property of Plenora.\n\n"
      "17. Changes to Services & Terms\n"
      "We reserve the right to modify these terms or app services at any time. Continued use of the platform constitutes acceptance of revised terms.\n\n"
      "18. Dispute Resolution\n"
      "Any disputes arising from these terms or services shall first be attempted to be resolved through informal negotiations or binding arbitration.\n\n"
      "19. Termination\n"
      "Plenora reserves the right to suspend or terminate accounts violating safety policies, non-payment terms, or code of conduct guidelines.\n\n"
      "20. Contact Information\n"
      "For any legal inquiries or service questions, contact legal@plenora.com or call +1 800 555-PLENORA.";

  static const String _privacyPreview =
      "Plenora Cleaning Services (\"Plenora\") respects your privacy. This Privacy Policy outlines how we collect, use, and protect your personal information.\n\n"
      "1. Information Collected & Account Data\n"
      "We collect account details (full name, email, phone number) and requested service location addresses to schedule and perform home services.\n\n"
      "2. Usage & Payment Security\n"
      "Payment transactions are processed securely via PCI-DSS compliant providers. Service address and contact notes are shared strictly with dispatched professionals for job fulfillment.";

  static const String _privacyFullText =
      "Plenora Cleaning Services (\"Plenora\", \"we\", \"our\") values your privacy. This Privacy Policy details how we collect, use, store, and protect your personal information when using our app and services.\n\n"
      "1. Information Collected\n"
      "We collect personal information necessary to deliver, manage, and optimize home cleaning and maintenance services.\n\n"
      "2. Account Information\n"
      "When creating an account, we collect your full name, email address, phone number, and password credentials.\n\n"
      "3. Booking & Address Information\n"
      "To perform requested services, we collect service site addresses, access instructions, selected appointment dates/times, and service history logs.\n\n"
      "4. Payment-Related Information\n"
      "Payment details (credit card numbers, UPI IDs) are processed via PCI-DSS compliant payment gateways. Plenora does not store full credit card numbers on its servers.\n\n"
      "5. Device & App Information\n"
      "We collect technical telemetry data, including device IP address, operating system version, app usage analytics, and crash logs to improve app performance.\n\n"
      "6. How Information Is Used\n"
      "Your data is used to process bookings, dispatch verified service professionals, process payments, provide customer support, send booking status updates, and prevent fraud.\n\n"
      "7. Service-Provider Sharing\n"
      "Necessary details (such as your first name, service address, phone contact, and booking notes) are shared only with the assigned service professional for fulfillment purposes.\n\n"
      "8. Payment-Provider Sharing\n"
      "Transaction details are securely transmitted to certified payment processing partners to authenticate payments.\n\n"
      "9. Data Storage & Security\n"
      "We employ industry-standard 256-bit SSL encryption, firewalls, and secure cloud server infrastructure to safeguard your information against unauthorized access.\n\n"
      "10. Cookies & Analytics\n"
      "Our digital platforms use technical cookies and privacy-focused analytics tools to analyze user interactions and streamline app navigation.\n\n"
      "11. Data Retention\n"
      "We retain user account and booking data for as long as your account remains active or as required by financial auditing laws.\n\n"
      "12. User Rights\n"
      "You have the right to inspect, update, or request a copy of your personal data stored in our systems at any time by contacting privacy@plenora.com.\n\n"
      "13. Account Deletion\n"
      "You can permanently delete your account and associated data directly through the Profile & Settings menu in the app or by submitting a deletion request.\n\n"
      "14. Third-Party Services\n"
      "Our app may contain links to third-party payment or mapping services. We are not responsible for the privacy practices of external third-party applications.\n\n"
      "15. Children's Privacy\n"
      "Plenora services are intended exclusively for adults aged 18 and older. We do not knowingly collect personal data from children under 13.\n\n"
      "16. Policy Updates\n"
      "We may periodically update this Privacy Policy. Notification of material policy changes will be communicated via in-app alerts or registered email.\n\n"
      "17. Contact Information\n"
      "For questions regarding your privacy rights or data protection practices, contact our Data Protection Officer at privacy@plenora.com.";

  String _userName = "Palash Sharma";
  String _userEmail = "palash@example.com";

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        title: Text("Edit Profile", style: AppTypography.headlineMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                labelStyle: AppTypography.bodyMedium,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                labelStyle: AppTypography.bodyMedium,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          PrimaryButton(
            text: "Save Changes",
            onPressed: () {
              setState(() {
                _userName = nameController.text.trim();
                _userEmail = emailController.text.trim();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Profile updated successfully!"),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            height: 40,
            borderRadius: 20,
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "Log Out?",
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Are you sure you want to log out of your Plenora account?",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Cancel",
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      nav.pop();
                      await AuthService.logout();
                      nav.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Log Out",
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_forever_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "Delete Account?",
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "This action is permanent and cannot be undone. All your bookings, saved addresses, and profile data will be permanently deleted.",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Cancel",
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      nav.pop();
                      await AuthService.logout();
                      messenger.showSnackBar(
                        SnackBar(
                          content:
                              const Text("Account has been permanently deleted."),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      nav.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Delete",
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFaqDialog() {
    final List<_FaqItemData> faqItems = [
      _FaqItemData(
        question: "How do I book a cleaning service?",
        answer:
            "You can easily book a service by browsing categories on the Home screen or Popular Services. Tap 'Add to Service' to add items to your Service Cart, or tap 'View Details' to choose a time slot and schedule immediately.",
      ),
      _FaqItemData(
        question: "Can I book multiple services at once?",
        answer:
            "Yes! You can add multiple home cleaning, electrical, painting, and appliance services to your Service Cart and checkout all of them together in a single booking.",
      ),
      _FaqItemData(
        question: "How do I choose a date and time?",
        answer:
            "When opening any service detail view, you will find available date and time slot chips (e.g., Morning 09:00 AM, Afternoon 02:00 PM). Simply select your preferred slot before confirming.",
      ),
      _FaqItemData(
        question: "Can I reschedule my booking?",
        answer:
            "Yes. You can reschedule your appointment up to 2 hours before the scheduled start time without any additional fee through the My Bookings tab.",
      ),
      _FaqItemData(
        question: "How do I cancel a booking?",
        answer:
            "You can cancel your booking directly from the My Bookings section. Cancellations made at least 2 hours prior to appointment time receive a 100% full refund.",
      ),
      _FaqItemData(
        question: "How do I apply a coupon code?",
        answer:
            "In your Service Cart under the Cost Details card, enter your promo code (e.g., PLENORA10 or PLENORA50) into the Coupon Code field and tap 'Apply'. Your discount will update immediately.",
      ),
      _FaqItemData(
        question: "How is the final price calculated?",
        answer:
            "The total price includes the sum of all selected services minus any active promo code discounts. Inspection and booking fees are completely FREE for all users.",
      ),
      _FaqItemData(
        question: "What payment methods are available?",
        answer:
            "We accept Cash After Service (pay directly to the technician upon job completion), UPI payments (Google Pay, PhonePe, Paytm), and Credit/Debit Cards (Visa, Mastercard, RuPay).",
      ),
      _FaqItemData(
        question: "How long does a service usually take?",
        answer:
            "Most standard services take approximately 2–3 hours. The exact duration depends on property size, condition, and any specialized add-ons requested.",
      ),
      _FaqItemData(
        question: "Can I change my service address?",
        answer:
            "Yes. During checkout, you can select between your saved Home and Office addresses or enter a new service location before placing your booking.",
      ),
      _FaqItemData(
        question: "What happens if the professional is delayed?",
        answer:
            "Our professionals arrive within the selected 30-minute arrival window. If there is an unexpected traffic delay, you will receive real-time notifications and support assistance.",
      ),
      _FaqItemData(
        question: "Can I request a specific service professional?",
        answer:
            "Yes. Repeat customers can request top-rated preferred professionals during checkout subject to their schedule availability.",
      ),
      _FaqItemData(
        question: "How can I contact support?",
        answer:
            "You can reach our 24/7 customer support team via email at support@plenora.com or by calling +1 800 555-PLENORA directly from the Support section.",
      ),
      _FaqItemData(
        question: "How do I view my previous bookings?",
        answer:
            "All your active and past home service appointments are saved in the 'My Bookings' tab, accessible from the bottom navigation bar or Profile settings.",
      ),
      _FaqItemData(
        question: "How do I delete my account?",
        answer:
            "Go to Profile & Settings → Account Actions → tap 'Delete Account'. A confirmation dialog will appear explaining that your data will be permanently removed upon explicit confirmation.",
      ),
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(24),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Frequently Asked Questions",
                      style: AppTypography.headlineMedium.copyWith(fontSize: 19),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 22),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(faqItems.length, (index) {
                      final item = faqItems[index];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                setDialogState(() {
                                  item.isExpanded = !item.isExpanded;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.question,
                                        style: AppTypography.titleMedium.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      item.isExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: item.isExpanded
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                child: Text(
                                  item.answer,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12.5,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                              crossFadeState: item.isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 250),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: "Close",
                    onPressed: () => Navigator.pop(context),
                    height: 44,
                    borderRadius: 22,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExpandableLegalDialog({
    required String title,
    required String previewText,
    required String fullText,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        bool isExpanded = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(24),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.headlineMedium.copyWith(fontSize: 19),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 22),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isExpanded ? fullText : previewText,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isExpanded ? "Read Less" : "Read More",
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: "Close",
                    onPressed: () => Navigator.pop(context),
                    height: 44,
                    borderRadius: 22,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surface,
        title: Text(title, style: AppTypography.headlineMedium),
        content: Text(
          content,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          PrimaryButton(
            text: "Got It",
            onPressed: () => Navigator.pop(context),
            height: 40,
            borderRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    String? assetIcon,
    IconData? icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color color = AppColors.textPrimary,
    Color iconColor = AppColors.primary,
    bool showChevron = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: SizedBox(
          width: 26,
          height: 26,
          child: Center(
            child: assetIcon != null
                ? Image.asset(
                    assetIcon,
                    width: 22,
                    height: 22,
                    color: iconColor,
                    errorBuilder: (context, error, stackTrace) => Icon(
                        icon ?? Icons.settings_rounded,
                        color: iconColor,
                        size: 22),
                  )
                : Icon(icon ?? Icons.settings_rounded,
                    color: iconColor, size: 22),
          ),
        ),
        minLeadingWidth: 26,
        title: Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: showChevron
            ? const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              )
            : null,
      ),
    );
  }

  Widget _buildSettingsSectionCard({
    required String sectionTitle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Profile & Settings", style: AppTypography.headlineLarge),
          const SizedBox(height: 16),

          // 1. Profile Header Card
          Container(
            padding: const EdgeInsets.all(18),
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
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Image.asset(
                      "assets/icons/profile-icon.png",
                      width: 40,
                      height: 40,
                      color: AppColors.primary,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: AppTypography.titleLarge.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userEmail,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 22),
                  onPressed: _showEditProfileDialog,
                  tooltip: "Edit Profile",
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Account Section
          _buildSettingsSectionCard(
            sectionTitle: "Account",
            children: [
              _buildSettingsTile(
                assetIcon: "assets/icons/mybookings-icon.png",
                icon: Icons.calendar_month_outlined,
                title: "My Bookings",
                subtitle: "View and track scheduled services",
                onTap: () => setState(() => _currentNavIndex = 1),
              ),
              const Divider(height: 1, indent: 38),
              _buildSettingsTile(
                assetIcon: "assets/icons/addresses-icon.png",
                icon: Icons.location_on_outlined,
                title: "Saved Addresses",
                subtitle: "Manage home & office service locations",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedAddressesScreen(),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 38),
              _buildSettingsTile(
                assetIcon: "assets/icons/paymentmethods-icon.png",
                icon: Icons.payment_outlined,
                title: "Payment Methods",
                subtitle: "Manage saved cards & payment options",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentMethodsScreen(),
                  ),
                ),
              ),
            ],
          ),

          // 3. Support Section
          _buildSettingsSectionCard(
            sectionTitle: "Support",
            children: [
              _buildSettingsTile(
                assetIcon: "assets/icons/help_support-icon.png",
                icon: Icons.help_outline_rounded,
                title: "Help & Support",
                subtitle: "24/7 customer assistant & active ticket resolution",
                onTap: () => _showInfoDialog(
                  "Help & Support",
                  "Need assistance with a booking or technician? Our support team is available 24/7 to resolve any issues.",
                ),
              ),
              const Divider(height: 1, indent: 38),
              _buildSettingsTile(
                assetIcon: "assets/icons/contact_us-icon.png",
                icon: Icons.mail_outline_rounded,
                title: "Contact Us",
                subtitle: "Email support@plenora.com or call +1 800-555-PLENORA",
                onTap: () => _showInfoDialog(
                  "Contact Us",
                  "Email: support@plenora.com\nPhone: +1 800 555-PLENORA\nHours: Mon - Sun (8:00 AM - 10:00 PM)",
                ),
              ),
              const Divider(height: 1, indent: 38),
              _buildSettingsTile(
                assetIcon: "assets/icons/faq-icon.png",
                icon: Icons.question_answer_outlined,
                title: "Frequently Asked Questions",
                subtitle: "Answers to common questions about services & pricing",
                onTap: _showFaqDialog,
              ),
            ],
          ),

          // 4. Legal Section
          _buildSettingsSectionCard(
            sectionTitle: "Legal",
            children: [
              _buildSettingsTile(
                assetIcon: "assets/icons/terms_conditions-icon.png",
                icon: Icons.description_outlined,
                title: "Terms & Conditions",
                subtitle: "Read our comprehensive terms of service agreement",
                onTap: () => _showExpandableLegalDialog(
                  title: "Terms & Conditions",
                  previewText: _termsPreview,
                  fullText: _termsFullText,
                ),
              ),
              const Divider(height: 1, indent: 38),
              _buildSettingsTile(
                assetIcon: "assets/icons/privacy_policy-icon.png",
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                subtitle: "Learn how we protect and process your personal data",
                onTap: () => _showExpandableLegalDialog(
                  title: "Privacy Policy",
                  previewText: _privacyPreview,
                  fullText: _privacyFullText,
                ),
              ),
              const Divider(height: 1, indent: 38),
              _buildSettingsTile(
                assetIcon: "assets/icons/about-icon.png",
                icon: Icons.info_outline_rounded,
                title: "About Plenora",
                subtitle: "Version 1.2.4 (Build ${AppDateTimeUtils.getCurrentYearString()})",
                onTap: () => _showInfoDialog(
                  "About Plenora",
                  "Plenora Cleaning & Home Services v1.2.4\nDesigned for premium, hassle-free home care.",
                ),
              ),
            ],
          ),

          // 5. Account Actions Section
          _buildSettingsSectionCard(
            sectionTitle: "Account Actions",
            children: [
              _buildSettingsTile(
                assetIcon: "assets/icons/logout-icon.png",
                icon: Icons.logout_rounded,
                title: "Log Out",
                subtitle: "Sign out of your Plenora account",
                iconColor: Colors.deepOrange,
                color: Colors.deepOrange,
                showChevron: false,
                onTap: _showLogoutConfirmation,
              ),
              const Divider(height: 1, indent: 38),
              _buildSettingsTile(
                assetIcon: "assets/icons/delete_account-icon.png",
                icon: Icons.delete_forever_rounded,
                title: "Delete Account",
                subtitle: "Permanently delete account and all data",
                iconColor: Colors.redAccent,
                color: Colors.redAccent,
                showChevron: false,
                onTap: _showDeleteAccountConfirmation,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryItem {
  final String name;
  final String iconUrl;
  final IconData iconData;
  final String? assetPath;

  const CategoryItem({
    required this.name,
    required this.iconUrl,
    required this.iconData,
    this.assetPath,
  });
}
