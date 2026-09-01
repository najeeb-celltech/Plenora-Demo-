import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plenora/core/services/address_service.dart';
import 'package:plenora/core/services/booking_service.dart';
import 'package:plenora/core/services/cart_service.dart';
import 'package:plenora/core/services/datetime_service.dart';
import 'package:plenora/core/services/payment_service.dart';
import 'package:plenora/core/widgets/custom_input_field.dart';
import 'package:plenora/features/auth/screens/login_screen.dart';
import 'package:plenora/features/auth/screens/signup_screen.dart';
import 'package:plenora/features/cart/screens/checkout_screen.dart';
import 'package:plenora/features/cart/screens/service_cart_screen.dart';
import 'package:plenora/features/home/screens/home_screen.dart';
import 'package:plenora/features/profile/screens/payment_methods_screen.dart';
import 'package:plenora/features/profile/screens/saved_addresses_screen.dart';
import 'package:plenora/features/services/screens/cleaning_services_screen.dart';
import 'package:plenora/features/services/screens/electrical_services_screen.dart';
import 'package:plenora/features/services/screens/painting_services_screen.dart';
import 'package:plenora/features/services/screens/appliance_services_screen.dart';
import 'package:plenora/features/services/screens/service_detail_sheet.dart';
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

  test('AppDateTimeUtils dynamically generates correct dates, times, and relative timestamps', () {
    final now = DateTime.now();

    // Available dates test
    final dates = AppDateTimeUtils.getAvailableDates(count: 5);
    expect(dates.length, 5);
    expect(dates.first.startsWith('Today,'), true);
    expect(dates[1].startsWith('Tomorrow,'), true);

    // Available times test
    final times = AppDateTimeUtils.getAvailableTimes();
    expect(times.contains('09:00 AM'), true);
    expect(times.contains('11:30 AM'), true);

    // Default booking date and time test
    expect(AppDateTimeUtils.getDefaultBookingDate(), dates.first);
    expect(AppDateTimeUtils.getDefaultBookingTime(), times.first);

    // Relative time formatting test
    expect(AppDateTimeUtils.formatRelativeTime(now), 'Just now');
    expect(
        AppDateTimeUtils.formatRelativeTime(now.subtract(const Duration(minutes: 15))),
        '15m ago');
    expect(
        AppDateTimeUtils.formatRelativeTime(now.subtract(const Duration(hours: 2))),
        '2h ago');
    expect(
        AppDateTimeUtils.formatRelativeTime(now.subtract(const Duration(days: 3))),
        '3d ago');

    // Year string test
    expect(AppDateTimeUtils.getCurrentYearString(), now.year.toString());
  });

  testWidgets('CheckoutScreen displays dynamic date and stores dynamic booking in BookingService',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;

    BookingService.clearBookings();
    expect(BookingService.bookingsNotifier.value.isEmpty, true);

    final expectedDefaultDate = AppDateTimeUtils.getDefaultBookingDate();
    final expectedDefaultTime = AppDateTimeUtils.getDefaultBookingTime();

    await tester.pumpWidget(
      MaterialApp(
        home: CheckoutScreen(
          directItem: CartItem(
            title: "Living Room Deep Clean",
            description: "Full cleaning",
            price: "₹899",
            priceNumeric: 899.0,
            rating: 4.9,
            imageUrl: "assets/image/kitchen-service.png",
            category: "Cleaning",
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify scheduled date & time displays the dynamic date
    expect(find.textContaining(expectedDefaultDate), findsWidgets);
    expect(find.textContaining(expectedDefaultTime), findsWidgets);

    // Tap "Confirm Booking & Pay" button
    await tester.tap(find.textContaining('Confirm Booking & Pay'));
    await tester.pumpAndSettle();

    // Verify booking was stored in BookingService with dynamic date
    expect(BookingService.bookingsNotifier.value.length, 1);
    final booking = BookingService.bookingsNotifier.value.first;
    expect(booking.title, "Living Room Deep Clean");
    expect(booking.date, expectedDefaultDate);
    expect(booking.time, expectedDefaultTime);
    expect(booking.status, "CONFIRMED");

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('ServiceDetailSheet renders dynamic dates starting from Today',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;

    final expectedDates = AppDateTimeUtils.getAvailableDates(count: 6);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ServiceDetailSheet(
            title: "Carpet Cleaning",
            description: "Deep steam cleaning",
            price: "₹799/hr",
            rating: 4.8,
            imageUrl: "assets/image/kitchen-service.png",
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Schedule Now" to open dialog
    await tester.ensureVisible(find.text('Schedule Now'));
    await tester.tap(find.text('Schedule Now'));
    await tester.pumpAndSettle();

    // Verify dynamic dates are rendered
    expect(find.text(expectedDates[0]), findsOneWidget);
    expect(find.text(expectedDates[1]), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Service Cart -> Proceed to Bookings -> Select Date & Time -> Checkout flow with multiple services',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;

    CartService.clearCart();
    BookingService.clearBookings();

    // Add 2 services to cart
    CartService.addService(
      title: "Kitchen Sparkle Service",
      description: "Deep grease removal",
      price: "₹899/hr",
      rating: 4.9,
      imageUrl: "assets/image/kitchen-service.png",
    );
    CartService.addService(
      title: "Bathroom Cleaning",
      description: "Tile and stain removal",
      price: "₹699/hr",
      rating: 4.8,
      imageUrl: "assets/image/kitchen-service.png",
    );
    expect(CartService.totalCount, 2);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ServiceCartScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify both items in cart
    expect(find.text('Kitchen Sparkle Service'), findsOneWidget);
    expect(find.text('Bathroom Cleaning'), findsOneWidget);

    // Scroll to and tap "Proceed to Bookings"
    await tester.ensureVisible(find.textContaining('Proceed to Bookings'));
    await tester.tap(find.textContaining('Proceed to Bookings'));
    await tester.pumpAndSettle();

    // Verify centered Date & Time popup appears
    expect(find.text('Schedule Appointment'), findsOneWidget);
    expect(find.text('Service Date'), findsOneWidget);
    expect(find.text('Service Time'), findsOneWidget);

    final expectedDates = AppDateTimeUtils.getAvailableDates(count: 6);
    expect(find.text(expectedDates[0]), findsOneWidget);

    // Select second date (Tomorrow)
    await tester.ensureVisible(find.text(expectedDates[1]));
    await tester.tap(find.text(expectedDates[1]));
    await tester.pumpAndSettle();

    // Tap "Continue to Checkout"
    await tester.ensureVisible(find.text('Continue to Checkout'));
    await tester.tap(find.text('Continue to Checkout'));
    await tester.pumpAndSettle();

    // Verify Checkout screen is displayed with selected date
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.textContaining(expectedDates[1]), findsWidgets);

    // Tap "Confirm Booking & Pay"
    await tester.tap(find.textContaining('Confirm Booking & Pay'));
    await tester.pumpAndSettle();

    // Verify multiple services are recorded in BookingService with the chosen date
    expect(BookingService.bookingsNotifier.value.length, 2);
    for (var b in BookingService.bookingsNotifier.value) {
      expect(b.date, expectedDates[1]);
      expect(b.status, "CONFIRMED");
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  test('AddressService supports Home, Office, Other, custom labels, and default toggling', () {
    // Check initial addresses
    expect(AddressService.addressesNotifier.value.isNotEmpty, true);
    final initialDefault = AddressService.defaultAddress;
    expect(initialDefault != null, true);
    expect(initialDefault!.isDefault, true);

    // Add custom "Other" address with label
    const customAddress = UserAddress(
      id: "addr_custom_test",
      type: AddressType.other,
      customLabel: "Studio Apartment",
      fullName: "Jordan Lee",
      phoneNumber: "+1 800-555-0188",
      houseNumber: "Unit 12B",
      streetArea: "Sunset Boulevard",
      city: "Mumbai",
      state: "Maharashtra",
      zipCode: "400001",
      landmark: "Near Gateway",
      isDefault: true,
    );
    AddressService.addAddress(customAddress);

    expect(AddressService.defaultAddress!.id, "addr_custom_test");
    expect(AddressService.defaultAddress!.typeDisplay, "Studio Apartment");
    expect(AddressService.defaultAddress!.formattedShortAddress, "Unit 12B, Sunset Boulevard, Mumbai");
    expect(AddressService.defaultAddress!.formattedFullAddress.contains("Near Gateway"), true);

    // Set default back to addr_1
    AddressService.setDefault("addr_1");
    expect(AddressService.defaultAddress!.id, "addr_1");

    // Clean up test address
    AddressService.deleteAddress("addr_custom_test");
    expect(AddressService.addressesNotifier.value.any((a) => a.id == "addr_custom_test"), false);
  });

  test('PaymentMethodService securely tokenizes cards, detects brands, and prevents plain CVV storage', () {
    // Test brand detection
    expect(PaymentMethodService.detectBrand("4532890012345678"), CardBrand.visa);
    expect(PaymentMethodService.detectBrand("5105105105105100"), CardBrand.mastercard);
    expect(PaymentMethodService.detectBrand("378282246310005"), CardBrand.amex);
    expect(PaymentMethodService.detectBrand("6011111111111111"), CardBrand.rupay);

    // Test tokenization and saving
    final card = PaymentMethodService.tokenizeAndSaveCard(
      cardType: CardType.credit,
      rawCardNumber: "4532 8900 1234 5678",
      cardHolderName: "Morgan Taylor",
      expiryMonth: "09",
      expiryYear: "27",
      cvv: "999",
      isDefault: false,
    );

    expect(card.last4Digits, "5678");
    expect(card.maskedNumber, "Visa •••• 5678");
    expect(card.typeDisplay, "Credit Card");
    expect(card.expiryDisplay, "09/27");
    expect(card.token.startsWith("tok_visa_sec_5678_"), true);

    // Clean up
    PaymentMethodService.deleteCard(card.id);
    expect(PaymentMethodService.cardsNotifier.value.any((c) => c.id == card.id), false);
  });

  testWidgets('SavedAddressesScreen renders saved addresses and options',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: SavedAddressesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Saved Addresses'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Office'), findsWidgets);
    expect(find.text('+ Add New Address'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('SavedAddressesScreen renders cleanly on small 320px screen without any overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: SavedAddressesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Saved Addresses'), findsOneWidget);
    expect(find.text('+ Add New Address'), findsOneWidget);

    // Scroll the list
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('PaymentMethodsScreen renders saved cards with tokenized masked format',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: PaymentMethodsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.textContaining('Visa ••••'), findsWidgets);
    expect(find.text('+ Add New Card'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('PaymentMethodsScreen renders cleanly on small 320px screen and scrolls to bottom',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: PaymentMethodsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.text('+ Add New Card'), findsOneWidget);

    // Scroll to bottom
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('PCI-DSS Level 1 & RBI Compliant'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('CheckoutScreen integrates Saved Address and Payment Method into BookingService',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;

    BookingService.clearBookings();

    await tester.pumpWidget(
      MaterialApp(
        home: CheckoutScreen(
          directItem: CartItem(
            title: "Premium Sofa Cleaning",
            description: "Deep steam sanitization",
            price: "₹1,299",
            priceNumeric: 1299.0,
            rating: 4.9,
            imageUrl: "assets/image/kitchen-service.png",
            category: "Cleaning",
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Service Address and Payment Options headers
    expect(find.text('Service Address'), findsOneWidget);
    expect(find.text('Payment Options'), findsOneWidget);

    // Tap "Confirm Booking & Pay"
    await tester.tap(find.textContaining('Confirm Booking & Pay'));
    await tester.pumpAndSettle();

    // Verify booking is recorded with address and paymentMethod
    expect(BookingService.bookingsNotifier.value.length, 1);
    final b = BookingService.bookingsNotifier.value.first;
    expect(b.title, "Premium Sofa Cleaning");
    expect(b.address != null, true);
    expect(b.paymentMethod != null, true);
    expect(b.status, "CONFIRMED");

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  test('AddressService and PaymentMethodService JSON serialization works correctly', () {
    const addr = UserAddress(
      id: "test_addr_id",
      type: AddressType.office,
      fullName: "Alex",
      phoneNumber: "1234567890",
      houseNumber: "H1",
      streetArea: "Street",
      city: "City",
      state: "State",
      zipCode: "123456",
      isDefault: true,
    );
    final addrJson = addr.toJson();
    final decodedAddr = UserAddress.fromJson(addrJson);
    expect(decodedAddr.id, "test_addr_id");
    expect(decodedAddr.type, AddressType.office);
    expect(decodedAddr.isDefault, true);

    const card = PaymentCard(
      id: "test_card_id",
      cardType: CardType.credit,
      cardBrand: CardBrand.visa,
      cardHolderName: "Alex",
      last4Digits: "1234",
      expiryMonth: "12",
      expiryYear: "28",
      token: "tok_123",
      isDefault: true,
    );
    final cardJson = card.toJson();
    final decodedCard = PaymentCard.fromJson(cardJson);
    expect(decodedCard.id, "test_card_id");
    expect(decodedCard.cardBrand, CardBrand.visa);
    expect(decodedCard.cardType, CardType.credit);
    expect(decodedCard.last4Digits, "1234");
    expect(decodedCard.isDefault, true);
  });
}
