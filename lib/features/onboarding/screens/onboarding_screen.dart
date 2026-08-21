import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/screens/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = const [
    OnboardingSlideData(
      title: "Trusted Home Services\nat Your Fingertips",
      subtitle:
          "Book verified professionals for cleaning, appliance repair, electrical service, painting, and more anytime, anywhere.",
      imageUrl:
          "https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=800&auto=format&fit=crop",
    ),
    OnboardingSlideData(
      title: "Expert Cleaners\nat Your Doorstep",
      subtitle:
          "Trained, background-checked professionals ready to transform your living space into a spotless sanctuary.",
      imageUrl:
          "https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?q=80&w=800&auto=format&fit=crop",
    ),
    OnboardingSlideData(
      title: "Hassle-Free &\nInstant Booking",
      subtitle:
          "Pick your preferred time slot, view transparent pricing, and enjoy 100% satisfaction guaranteed service.",
      imageUrl:
          "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=800&auto=format&fit=crop",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToSignUp();
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignUpScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Exact colors from uploaded reference image
    const Color topBgColor = Color(0xFF006342); // Solid emerald background
    const Color cardBgColor = Color(0xFF00482B); // Darker emerald bottom card
    const Color subtitleColor = Color(0xFFD4E7DE); // Light green-tinted subtitle

    return Scaffold(
      backgroundColor: topBgColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Top Half: Hero Image Container over Green Background
                Expanded(
                  flex: 11,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Top solid background with PageView slider for imagery
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: _slides.length,
                        itemBuilder: (context, index) {
                          return Container(
                            color: topBgColor,
                            width: double.infinity,
                            height: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 48.0),
                                    child: Image.network(
                                      _slides[index].imageUrl,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Center(
                                        child: Icon(
                                          Icons.cleaning_services_rounded,
                                          size: 110,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Skip button in top corner
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 16,
                        right: 20,
                        child: GestureDetector(
                          onTap: _navigateToSignUp,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Skip",
                              style: AppTypography.buttonText.copyWith(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Half: Dark Emerald Card Container (Matches reference image)
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Swappable Text Content (Title & Subtitle)
                      SizedBox(
                        height: 155,
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _slides.length,
                          itemBuilder: (context, index) {
                            final slide = _slides[index];
                            return Column(
                              children: [
                                Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.headlineOnboarding
                                      .copyWith(
                                    fontSize: 25,
                                    height: 1.25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    slide.subtitle,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: subtitleColor,
                                      fontSize: 14,
                                      height: 1.45,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Slide Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (index) {
                          final isActive = _currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.white38,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      // Bottom White Pill Capsule Bar (Matches Reference Image)
                      Container(
                        height: 66,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x15000000),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Inner Green Button ("Get Started")
                            Expanded(
                              child: GestureDetector(
                                onTap: _onNext,
                                child: Container(
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: cardBgColor,
                                    borderRadius: BorderRadius.circular(34),
                                  ),
                                  child: Text(
                                    _currentPage == _slides.length - 1
                                        ? "Get Started"
                                        : "Continue",
                                    style: AppTypography.buttonText.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Right Arrow Icon
                            GestureDetector(
                              onTap: _onNext,
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.textPrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class OnboardingSlideData {
  final String title;
  final String subtitle;
  final String imageUrl;

  const OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}
