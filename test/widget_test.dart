import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plenora/core/services/cart_service.dart';
import 'package:plenora/features/home/screens/home_screen.dart';
import 'package:plenora/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PlenoraApp());
    await tester.pumpAndSettle();
    expect(find.byType(PlenoraApp), findsOneWidget);
  });

  testWidgets(
      'HomeScreen responsiveness test on small, standard, and large screens with zero layout overflow',
      (WidgetTester tester) async {
    dynamic exception;

    // 1. Small phone screen test (320 x 568 - iPhone SE width)
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    exception = tester.takeException();
    if (exception != null) {
      expect(exception.toString(), isNot(contains('overflowed')));
    }

    // 2. Standard phone screen test (375 x 812 - iPhone X width)
    tester.view.physicalSize = const Size(375, 812);
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    exception = tester.takeException();
    if (exception != null) {
      expect(exception.toString(), isNot(contains('overflowed')));
    }

    // 3. Large phone screen test (412 x 915 - Pixel width)
    tester.view.physicalSize = const Size(412, 915);
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    exception = tester.takeException();
    if (exception != null) {
      expect(exception.toString(), isNot(contains('overflowed')));
    }

    // Reset view
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  test('CartService unit tests for INR pricing, discounts, and item management', () {
    CartService.clearCart();
    expect(CartService.totalCount, 0);
    expect(CartService.subtotalPrice, 0.0);
    expect(CartService.totalPrice, 0.0);

    // Format INR test
    expect(CartService.formatInr(799), '₹799');
    expect(CartService.formatInr(1499), '₹1,499');
    expect(CartService.formatInr(25000), '₹25,000');

    // Add service test
    CartService.addService(
      title: "Carpet Cleaning",
      description: "Deep steam clean",
      price: "₹799/hr",
      rating: 4.9,
      imageUrl: "assets/image/kitchen-service.png",
    );
    expect(CartService.totalCount, 1);
    expect(CartService.subtotalPrice, 799.0);
    expect(CartService.totalPrice, 799.0);

    // Apply coupon test
    final applied = CartService.applyCoupon("PLENORA10");
    expect(applied, true);
    expect(CartService.discountNotifier.value, 150.0);
    expect(CartService.totalPrice, 649.0);

    // Clear cart test
    CartService.clearCart();
    expect(CartService.totalCount, 0);
    expect(CartService.totalPrice, 0.0);
  });
}
