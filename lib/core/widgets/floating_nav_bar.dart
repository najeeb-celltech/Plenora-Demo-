import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../theme/app_colors.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 20,
            spreadRadius: 2,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartService.itemsNotifier,
        builder: (context, cartItems, child) {
          final cartCount = CartService.totalCount;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                  0, "assets/icons/home-icon.png", Icons.home_rounded),
              _buildNavItem(1, "assets/icons/mybookings-icon.png",
                  Icons.calendar_month_rounded),
              _buildNavItem(
                2,
                "assets/icons/servicecart-icon.png",
                Icons.shopping_bag_outlined,
                badgeCount: cartCount,
              ),
              _buildNavItem(
                  3, "assets/icons/profile-icon.png", Icons.person_outline_rounded),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, String assetPath, IconData fallbackIcon,
      {int badgeCount = 0}) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                assetPath,
                width: 22,
                height: 22,
                color:
                    isSelected ? AppColors.textWhite : AppColors.textSecondary,
                errorBuilder: (context, error, stackTrace) => Icon(
                  fallbackIcon,
                  size: 22,
                  color: isSelected
                      ? AppColors.textWhite
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
