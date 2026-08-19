import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/floating_nav_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/service_card.dart';
import '../../auth/screens/login_screen.dart';
import '../../services/screens/cleaning_services_screen.dart';
import '../../services/screens/service_detail_sheet.dart';
import 'notifications_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<NotificationItemData> _notifications = [
    NotificationItemData(
      id: "1",
      title: "50% Off Special Discount!",
      message:
          "Enjoy 50% off on your first carpet deep cleaning booking today.",
      time: "10m ago",
      icon: Icons.local_offer_rounded,
      iconColor: Colors.amber,
      isRead: false,
    ),
    NotificationItemData(
      id: "2",
      title: "Booking Confirmed",
      message:
          "Your Premium Home Cleaning is scheduled for tomorrow at 10:00 AM.",
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.primary,
      time: "1h ago",
      isRead: false,
    ),
    NotificationItemData(
      id: "3",
      title: "New Appliance Specialist Nearby",
      message:
          "Verified appliance repair experts are now available in your area.",
      icon: Icons.home_repair_service_rounded,
      iconColor: Colors.blueAccent,
      time: "3h ago",
      isRead: true,
    ),
    NotificationItemData(
      id: "4",
      title: "Welcome to Plenora!",
      message:
          "Explore top-rated home cleaning, electrical, painting, and appliance services.",
      icon: Icons.auto_awesome_rounded,
      iconColor: Colors.purpleAccent,
      time: "1d ago",
      isRead: true,
    ),
  ];

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
      "price": "\$29/hr",
      "rating": 4.9,
      "imageUrl":
          "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=300&auto=format&fit=crop",
    },
    {
      "title": "Kitchen Service",
      "category": "Cleaning",
      "description":
          "Grease removal, cabinet polishing, and thorough appliance scrubbing.",
      "price": "\$35/hr",
      "rating": 4.8,
      "imageUrl": "assets/image/kitchen-service.png",
    },
    {
      "title": "Bathroom Cleaning",
      "category": "Cleaning",
      "description":
          "Tile gunk scrubbing, mirror shine, and anti-bacterial disinfections.",
      "price": "\$25/hr",
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
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentNavIndex,
          children: [
            _buildHomeContent(),
            _buildBookingsTab(),
            _buildMessagesTab(),
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
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
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
                      builder: (context) => const CleaningServicesScreen(),
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
                price: service["price"],
                rating: service["rating"],
                imageUrl: service["imageUrl"],
                isHorizontalCompact: true,
                onBookNow: () => _openServiceModal(service),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("My Bookings", style: AppTypography.headlineLarge),
          const SizedBox(height: 8),
          Text(
            "Track active and past home service appointments.",
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 24),
          // Active Booking Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "CONFIRMED",
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      "\$29/hr",
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Premium Home Cleaning",
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      "Tomorrow, 10:00 AM",
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Messages", style: AppTypography.headlineLarge),
          const SizedBox(height: 8),
          Text(
            "Direct chat with assigned service professionals.",
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(
                "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&auto=format&fit=crop",
              ),
            ),
            title: Text("Sarah Jenkins", style: AppTypography.titleMedium),
            subtitle: Text("I will arrive at 10:00 AM with cleaning equipment.",
                style: AppTypography.bodySmall),
            trailing: Text("10:42 AM", style: AppTypography.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Profile Settings", style: AppTypography.headlineLarge),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(
                  "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop",
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Palash Sharma", style: AppTypography.titleLarge),
                  Text("palash@example.com", style: AppTypography.bodyMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Logout Options Section Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Account",
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    await AuthService.logout();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Log Out",
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                      ],
                    ),
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
