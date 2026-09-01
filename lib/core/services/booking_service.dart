import 'package:flutter/material.dart';

class BookedService {
  final String id;
  final String title;
  final String price;
  final String date;
  final String time;
  final String imageUrl;
  final String status;
  final String? address;
  final String? paymentMethod;
  final DateTime bookedAt;

  BookedService({
    required this.id,
    required this.title,
    required this.price,
    required this.date,
    required this.time,
    required this.imageUrl,
    this.status = "CONFIRMED",
    this.address,
    this.paymentMethod,
    required this.bookedAt,
  });
}

class BookingService {
  static final ValueNotifier<List<BookedService>> bookingsNotifier =
      ValueNotifier<List<BookedService>>([]);

  static void addBooking({
    required String title,
    required String price,
    required String date,
    required String time,
    required String imageUrl,
    String status = "CONFIRMED",
    String? address,
    String? paymentMethod,
  }) {
    final currentBookings = List<BookedService>.from(bookingsNotifier.value);
    currentBookings.insert(
      0,
      BookedService(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        price: price,
        date: date,
        time: time,
        imageUrl: imageUrl,
        status: status,
        address: address,
        paymentMethod: paymentMethod,
        bookedAt: DateTime.now(),
      ),
    );
    bookingsNotifier.value = currentBookings;
  }

  static void cancelBooking(String id) {
    final currentBookings = List<BookedService>.from(bookingsNotifier.value);
    final index = currentBookings.indexWhere((b) => b.id == id);
    if (index >= 0) {
      final old = currentBookings[index];
      currentBookings[index] = BookedService(
        id: old.id,
        title: old.title,
        price: old.price,
        date: old.date,
        time: old.time,
        imageUrl: old.imageUrl,
        status: "CANCELLED",
        address: old.address,
        paymentMethod: old.paymentMethod,
        bookedAt: old.bookedAt,
      );
      bookingsNotifier.value = currentBookings;
    }
  }

  static void clearBookings() {
    bookingsNotifier.value = [];
  }
}
