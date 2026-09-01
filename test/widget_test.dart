import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plenora/core/services/cart_service.dart';
import 'package:plenora/core/widgets/custom_input_field.dart';
import 'package:plenora/features/auth/screens/login_screen.dart';
import 'package:plenora/features/auth/screens/signup_screen.dart';
import 'package:plenora/features/home/screens/home_screen.dart';
import 'package:plenora/features/services/screens/cleaning_services_screen.dart';
import 'package:plenora/features/services/screens/electrical_services_screen.dart';
import 'package:plenora/features/services/screens/painting_services_screen.dart';
import 'package:plenora/features/services/screens/appliance_services_screen.dart';
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

  testWidgets('SignUpScreen validation displays inline messages without layout overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state - no errors
    expect(find.text('Please enter your name'), findsNothing);
    expect(find.text('Please enter your email'), findsNothing);
    expect(find.text('Please enter your password'), findsNothing);

    // Tap "Sign Up" button with empty fields
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify validation errors appear
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    // Test entering text clears the name error
    await tester.enterText(find.byType(TextField).at(0), 'Jane Doe');
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name'), findsNothing);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('LoginScreen validation displays inline messages without layout overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state - no errors
    expect(find.text('Please enter your email'), findsNothing);
    expect(find.text('Please enter your password'), findsNothing);

    // Tap "Login" button with empty fields
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify validation errors appear
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    // Test invalid email validation
    await tester.enterText(find.byType(TextField).at(0), 'invalidemail');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Auth screens responsiveness with error messages on small (320px) screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;

    // Test SignUp with errors on 320px
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your name'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Test Login with errors on 320px
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Input fields maintain exact fixed height without layout shift when errors appear',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Measure height of all 3 CustomInputField widgets before error
    final fieldFinder = find.byType(CustomInputField);
    expect(fieldFinder, findsNWidgets(3));

    final sizeBefore0 = tester.getSize(fieldFinder.at(0));
    final sizeBefore1 = tester.getSize(fieldFinder.at(1));
    final sizeBefore2 = tester.getSize(fieldFinder.at(2));

    // Tap "Sign Up" to trigger validation errors
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Measure height of all 3 CustomInputField widgets after error
    final sizeAfter0 = tester.getSize(fieldFinder.at(0));
    final sizeAfter1 = tester.getSize(fieldFinder.at(1));
    final sizeAfter2 = tester.getSize(fieldFinder.at(2));

    // Height should be identical (0px layout shift)
    expect(sizeAfter0.height, equals(sizeBefore0.height));
    expect(sizeAfter1.height, equals(sizeBefore1.height));
    expect(sizeAfter2.height, equals(sizeBefore2.height));

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('CleaningServicesScreen filters services correctly on tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 2000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: CleaningServicesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state: "All" selected -> all 5 services displayed
    expect(find.text('Kitchen Sparkle Service'), findsOneWidget);
    expect(find.text('Bathroom Cleaning'), findsOneWidget);
    expect(find.text('Carpet Cleaning'), findsOneWidget);
    expect(find.text('Full House Deep Sanitation'), findsOneWidget);
    expect(find.text('Window & Glass Restoration'), findsOneWidget);

    // Tap "Top Rated" filter
    await tester.tap(find.text('Top Rated'));
    await tester.pumpAndSettle();
    expect(find.text('Bathroom Cleaning'), findsOneWidget);
    expect(find.text('Carpet Cleaning'), findsOneWidget);
    expect(find.text('Full House Deep Sanitation'), findsOneWidget);
    expect(find.text('Kitchen Sparkle Service'), findsNothing);

    // Tap "Under ₹999" filter
    await tester.tap(find.text('Under ₹999'));
    await tester.pumpAndSettle();
    expect(find.text('Bathroom Cleaning'), findsOneWidget);
    expect(find.text('Carpet Cleaning'), findsOneWidget);
    expect(find.text('Kitchen Sparkle Service'), findsOneWidget);
    expect(find.text('Window & Glass Restoration'), findsOneWidget);
    expect(find.text('Full House Deep Sanitation'), findsNothing);

    // Tap "Nearby" filter
    await tester.tap(find.text('Nearby'));
    await tester.pumpAndSettle();
    expect(find.text('Kitchen Sparkle Service'), findsOneWidget);
    expect(find.text('Bathroom Cleaning'), findsOneWidget);
    expect(find.text('Window & Glass Restoration'), findsOneWidget);
    expect(find.text('Full House Deep Sanitation'), findsNothing);

    // Tap "All" filter to restore all services
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Full House Deep Sanitation'), findsOneWidget);
    expect(find.text('Kitchen Sparkle Service'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('ElectricalServicesScreen filters services correctly on tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 2000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: ElectricalServicesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state: "All" selected
    expect(find.text('Wiring & Circuit Repair'), findsOneWidget);
    expect(find.text('Light Fixture Installation'), findsOneWidget);
    expect(find.text('Outlet & Switch Upgrade'), findsOneWidget);
    expect(find.text('EV Charger & Panel Setup'), findsOneWidget);
    expect(find.text('Appliance Short Circuit Fix'), findsOneWidget);

    // Tap "Top Rated" filter
    await tester.tap(find.text('Top Rated'));
    await tester.pumpAndSettle();
    expect(find.text('Wiring & Circuit Repair'), findsOneWidget);
    expect(find.text('EV Charger & Panel Setup'), findsOneWidget);
    expect(find.text('Appliance Short Circuit Fix'), findsOneWidget);
    expect(find.text('Outlet & Switch Upgrade'), findsNothing);

    // Tap "Emergency" filter
    await tester.tap(find.text('Emergency'));
    await tester.pumpAndSettle();
    expect(find.text('Wiring & Circuit Repair'), findsOneWidget);
    expect(find.text('Outlet & Switch Upgrade'), findsOneWidget);
    expect(find.text('Appliance Short Circuit Fix'), findsOneWidget);
    expect(find.text('Light Fixture Installation'), findsNothing);

    // Tap "Under ₹999" filter
    await tester.tap(find.text('Under ₹999'));
    await tester.pumpAndSettle();
    expect(find.text('Outlet & Switch Upgrade'), findsOneWidget);
    expect(find.text('Appliance Short Circuit Fix'), findsOneWidget);
    expect(find.text('Light Fixture Installation'), findsOneWidget);
    expect(find.text('Wiring & Circuit Repair'), findsOneWidget);
    expect(find.text('EV Charger & Panel Setup'), findsNothing);

    // Tap "All" to restore
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('EV Charger & Panel Setup'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('PaintingServicesScreen filters services correctly on tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 2000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: PaintingServicesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state: "All"
    expect(find.text('Interior Room Painting'), findsOneWidget);
    expect(find.text('Exterior Wall Coating'), findsOneWidget);
    expect(find.text('Accent Wall Design'), findsOneWidget);
    expect(find.text('Cabinet & Wood Polishing'), findsOneWidget);
    expect(find.text('Weatherproof Terrace Paint'), findsOneWidget);

    // Tap "Interior"
    await tester.tap(find.text('Interior'));
    await tester.pumpAndSettle();
    expect(find.text('Interior Room Painting'), findsOneWidget);
    expect(find.text('Accent Wall Design'), findsOneWidget);
    expect(find.text('Cabinet & Wood Polishing'), findsOneWidget);
    expect(find.text('Exterior Wall Coating'), findsNothing);
    expect(find.text('Weatherproof Terrace Paint'), findsNothing);

    // Tap "Exterior"
    await tester.tap(find.text('Exterior'));
    await tester.pumpAndSettle();
    expect(find.text('Exterior Wall Coating'), findsOneWidget);
    expect(find.text('Weatherproof Terrace Paint'), findsOneWidget);
    expect(find.text('Interior Room Painting'), findsNothing);

    // Tap "Top Rated"
    await tester.tap(find.text('Top Rated'));
    await tester.pumpAndSettle();
    expect(find.text('Interior Room Painting'), findsOneWidget);
    expect(find.text('Accent Wall Design'), findsOneWidget);
    expect(find.text('Weatherproof Terrace Paint'), findsOneWidget);
    expect(find.text('Cabinet & Wood Polishing'), findsNothing);

    // Tap "All"
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Exterior Wall Coating'), findsOneWidget);
    expect(find.text('Cabinet & Wood Polishing'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('ApplianceServicesScreen filters services correctly on tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 2000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: ApplianceServicesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state: "All"
    expect(find.text('Refrigerator & Freezer Repair'), findsOneWidget);
    expect(find.text('Washing Machine & Dryer Care'), findsOneWidget);
    expect(find.text('Oven & Stove Servicing'), findsOneWidget);
    expect(find.text('Dishwasher Repair & Clean'), findsOneWidget);
    expect(find.text('AC Maintenance & Gas Refill'), findsOneWidget);

    // Tap "Top Rated"
    await tester.tap(find.text('Top Rated'));
    await tester.pumpAndSettle();
    expect(find.text('Refrigerator & Freezer Repair'), findsOneWidget);
    expect(find.text('Dishwasher Repair & Clean'), findsOneWidget);
    expect(find.text('AC Maintenance & Gas Refill'), findsOneWidget);
    expect(find.text('Oven & Stove Servicing'), findsNothing);

    // Tap "Same Day"
    await tester.tap(find.text('Same Day'));
    await tester.pumpAndSettle();
    expect(find.text('Refrigerator & Freezer Repair'), findsOneWidget);
    expect(find.text('Washing Machine & Dryer Care'), findsOneWidget);
    expect(find.text('AC Maintenance & Gas Refill'), findsOneWidget);
    expect(find.text('Oven & Stove Servicing'), findsNothing);

    // Tap "Under ₹999"
    await tester.tap(find.text('Under ₹999'));
    await tester.pumpAndSettle();
    expect(find.text('Oven & Stove Servicing'), findsOneWidget);
    expect(find.text('Washing Machine & Dryer Care'), findsOneWidget);
    expect(find.text('Dishwasher Repair & Clean'), findsOneWidget);
    expect(find.text('AC Maintenance & Gas Refill'), findsOneWidget);
    expect(find.text('Refrigerator & Freezer Repair'), findsOneWidget);

    // Tap "All"
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Refrigerator & Freezer Repair'), findsOneWidget);
    expect(find.text('Oven & Stove Servicing'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
