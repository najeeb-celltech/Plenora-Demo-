import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'primary_button.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final double rating;
  final String imageUrl;
  final VoidCallback onBookNow;
  final VoidCallback? onViewDetails;
  final bool isHorizontalCompact;

  const ServiceCard({
    super.key,
    required this.title,
    this.description = '',
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.onBookNow,
    this.onViewDetails,
    this.isHorizontalCompact = false,
  });

  Widget _buildImageWidget({required double iconSize}) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.cleaning_services_rounded,
          color: AppColors.primary,
          size: iconSize,
        ),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.cleaning_services_rounded,
        color: AppColors.primary,
        size: iconSize,
      ),
    );
  }

  void _addToCart(BuildContext context) {
    CartService.addService(
      title: title,
      description: description,
      price: price,
      rating: rating,
      imageUrl: imageUrl,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added '$title' to Service Cart!"),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isHorizontalCompact) {
      // Popular services card with full multi-line title visibility & compact Add to Service button
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Exact 80x80 Image Container Box - Image scaled up slightly within bounds
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.primaryLight,
                child: Transform.scale(
                  scale: 1.15,
                  child: _buildImageWidget(iconSize: 34),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info Column - Full multi-line service name visibility without truncation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.starYellow,
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style:
                            AppTypography.ratingText.copyWith(fontSize: 11.5),
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '• Verified',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Starting $price',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Sleek & Slightly Larger Add to Service Button (Height 30dp, FittedBox scaled)
            Flexible(
              fit: FlexFit.loose,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: PrimaryButton(
                  text: 'Add to Service',
                  onPressed: () => _addToCart(context),
                  height: 30,
                  borderRadius: 15,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  leadingIcon: Icons.add_shopping_cart_rounded,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Detailed Full Card (Screen 3 format - Borderless)
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Squircle Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 84,
                  height: 84,
                  color: AppColors.primaryLight,
                  child: _buildImageWidget(iconSize: 38),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleLarge.copyWith(fontSize: 15.5),
                      softWrap: true,
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          price,
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.starBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.starYellow,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: AppTypography.ratingText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Action buttons row (View Details & Add to Service)
          Row(
            children: [
              if (onViewDetails != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    ),
                    icon: const Icon(
                      Icons.remove_red_eye_outlined,
                      size: 15,
                      color: AppColors.textPrimary,
                    ),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'View Details',
                        style: AppTypography.buttonText.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              if (onViewDetails != null) const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(
                  text: 'Add to Service',
                  onPressed: () => _addToCart(context),
                  height: 36,
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  leadingIcon: Icons.add_shopping_cart_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
