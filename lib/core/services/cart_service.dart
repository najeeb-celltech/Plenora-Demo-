import 'package:flutter/material.dart';

class CartItem {
  final String title;
  final String description;
  final String price;
  final double priceNumeric;
  final double rating;
  final String imageUrl;
  final String category;
  int quantity;

  CartItem({
    required this.title,
    required this.description,
    required this.price,
    required this.priceNumeric,
    required this.rating,
    required this.imageUrl,
    required this.category,
    this.quantity = 1,
  });
}

class CartService {
  static final ValueNotifier<List<CartItem>> itemsNotifier =
      ValueNotifier<List<CartItem>>([]);
  static final ValueNotifier<double> discountNotifier =
      ValueNotifier<double>(0.0);
  static final ValueNotifier<String?> couponCodeNotifier =
      ValueNotifier<String?>(null);

  static double parsePrice(String priceStr) {
    final cleaned = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 29.0;
  }

  static void addService({
    required String title,
    required String description,
    required String price,
    required double rating,
    required String imageUrl,
    String category = "Cleaning",
  }) {
    final currentItems = List<CartItem>.from(itemsNotifier.value);
    final index = currentItems.indexWhere((item) => item.title == title);

    if (index >= 0) {
      currentItems[index].quantity += 1;
    } else {
      currentItems.add(
        CartItem(
          title: title,
          description: description,
          price: price,
          priceNumeric: parsePrice(price),
          rating: rating,
          imageUrl: imageUrl,
          category: category,
          quantity: 1,
        ),
      );
    }
    itemsNotifier.value = currentItems;
  }

  static void removeService(String title) {
    final currentItems = List<CartItem>.from(itemsNotifier.value);
    currentItems.removeWhere((item) => item.title == title);
    itemsNotifier.value = currentItems;
    if (currentItems.isEmpty) {
      removeCoupon();
    }
  }

  static bool applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return false;

    if (cleanCode == "PLENORA10" || cleanCode == "SAVE10") {
      discountNotifier.value = 10.0;
      couponCodeNotifier.value = cleanCode;
      return true;
    } else if (cleanCode == "PLENORA50" || cleanCode == "HALF") {
      final subtotal = subtotalPrice;
      discountNotifier.value = (subtotal * 0.5);
      couponCodeNotifier.value = cleanCode;
      return true;
    } else {
      // 15% discount for any valid promo code entered
      final subtotal = subtotalPrice;
      discountNotifier.value = (subtotal * 0.15);
      couponCodeNotifier.value = cleanCode;
      return true;
    }
  }

  static void removeCoupon() {
    discountNotifier.value = 0.0;
    couponCodeNotifier.value = null;
  }

  static void clearCart() {
    itemsNotifier.value = [];
    removeCoupon();
  }

  static double get subtotalPrice {
    double total = 0;
    for (var item in itemsNotifier.value) {
      total += item.priceNumeric * item.quantity;
    }
    return total;
  }

  static double get totalPrice {
    final subtotal = subtotalPrice;
    final discount = discountNotifier.value;
    final total = subtotal - discount;
    return total < 0 ? 0.0 : total;
  }

  static int get totalCount {
    int count = 0;
    for (var item in itemsNotifier.value) {
      count += item.quantity;
    }
    return count;
  }
}
