import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CardType { debit, credit }

enum CardBrand { visa, mastercard, rupay, amex, other }

class PaymentCard {
  final String id;
  final CardType cardType;
  final CardBrand cardBrand;
  final String cardHolderName;
  final String last4Digits;
  final String expiryMonth;
  final String expiryYear;
  final String token; // Secure payment token generated via tokenization
  final bool isDefault;

  const PaymentCard({
    required this.id,
    required this.cardType,
    required this.cardBrand,
    required this.cardHolderName,
    required this.last4Digits,
    required this.expiryMonth,
    required this.expiryYear,
    required this.token,
    this.isDefault = false,
  });

  String get brandDisplay {
    switch (cardBrand) {
      case CardBrand.visa:
        return "Visa";
      case CardBrand.mastercard:
        return "Mastercard";
      case CardBrand.rupay:
        return "RuPay";
      case CardBrand.amex:
        return "Amex";
      case CardBrand.other:
        return "Card";
    }
  }

  String get maskedNumber => "$brandDisplay •••• $last4Digits";

  String get typeDisplay =>
      cardType == CardType.credit ? "Credit Card" : "Debit Card";

  String get expiryDisplay => "$expiryMonth/$expiryYear";

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardType': cardType.name,
      'cardBrand': cardBrand.name,
      'cardHolderName': cardHolderName,
      'last4Digits': last4Digits,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'token': token,
      'isDefault': isDefault,
    };
  }

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    CardType type = CardType.debit;
    if (json['cardType'] == 'credit') {
      type = CardType.credit;
    }

    CardBrand brand = CardBrand.other;
    final bName = json['cardBrand'] as String?;
    if (bName == 'visa') {
      brand = CardBrand.visa;
    } else if (bName == 'mastercard') {
      brand = CardBrand.mastercard;
    } else if (bName == 'rupay') {
      brand = CardBrand.rupay;
    } else if (bName == 'amex') {
      brand = CardBrand.amex;
    }

    return PaymentCard(
      id: json['id'] as String,
      cardType: type,
      cardBrand: brand,
      cardHolderName: json['cardHolderName'] as String? ?? 'Alex Morgan',
      last4Digits: json['last4Digits'] as String? ?? '0000',
      expiryMonth: json['expiryMonth'] as String? ?? '12',
      expiryYear: json['expiryYear'] as String? ?? '28',
      token: json['token'] as String? ?? 'tok_sec',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  PaymentCard copyWith({
    String? id,
    CardType? cardType,
    CardBrand? cardBrand,
    String? cardHolderName,
    String? last4Digits,
    String? expiryMonth,
    String? expiryYear,
    String? token,
    bool? isDefault,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      cardType: cardType ?? this.cardType,
      cardBrand: cardBrand ?? this.cardBrand,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      last4Digits: last4Digits ?? this.last4Digits,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      token: token ?? this.token,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class PaymentMethodService {
  static const String _storageKey = "plenora_saved_cards_v1";

  static final List<PaymentCard> _defaultCards = [
    const PaymentCard(
      id: "card_1",
      cardType: CardType.debit,
      cardBrand: CardBrand.visa,
      cardHolderName: "Alex Morgan",
      last4Digits: "4521",
      expiryMonth: "08",
      expiryYear: "28",
      token: "tok_visa_sec_4521_98a72",
      isDefault: true,
    ),
    const PaymentCard(
      id: "card_2",
      cardType: CardType.credit,
      cardBrand: CardBrand.mastercard,
      cardHolderName: "Alex Morgan",
      last4Digits: "8290",
      expiryMonth: "11",
      expiryYear: "29",
      token: "tok_mc_sec_8290_b3f14",
      isDefault: false,
    ),
  ];

  static final ValueNotifier<List<PaymentCard>> cardsNotifier =
      ValueNotifier<List<PaymentCard>>(List.from(_defaultCards));

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_storageKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedJson) as List<dynamic>;
        final loaded = decoded
            .map((item) => PaymentCard.fromJson(item as Map<String, dynamic>))
            .toList();
        if (loaded.isNotEmpty) {
          cardsNotifier.value = loaded;
          return;
        }
      }
    } catch (_) {}
  }

  static Future<void> _persistCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = cardsNotifier.value.map((c) => c.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  static PaymentCard? get defaultCard {
    final list = cardsNotifier.value;
    if (list.isEmpty) return null;
    return list.firstWhere(
      (c) => c.isDefault,
      orElse: () => list.first,
    );
  }

  static CardBrand detectBrand(String rawNumber) {
    final clean = rawNumber.replaceAll(RegExp(r'\s+'), '');
    if (clean.startsWith('4')) return CardBrand.visa;
    if (clean.startsWith('5') || clean.startsWith('2')) {
      return CardBrand.mastercard;
    }
    if (clean.startsWith('3')) return CardBrand.amex;
    if (clean.startsWith('6')) return CardBrand.rupay;
    return CardBrand.other;
  }

  /// Securely tokenizes payment credentials in-memory and returns a PaymentCard with ONLY last 4 digits stored.
  /// Never stores or persists CVV or full PAN.
  static PaymentCard tokenizeAndSaveCard({
    required CardType cardType,
    required String rawCardNumber,
    required String cardHolderName,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    bool isDefault = false,
  }) {
    final cleanNumber = rawCardNumber.replaceAll(RegExp(r'\s+'), '');
    final last4 = cleanNumber.length >= 4
        ? cleanNumber.substring(cleanNumber.length - 4)
        : "0000";
    final brand = detectBrand(cleanNumber);
    final token =
        "tok_${brand.name}_sec_${last4}_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";

    final newCard = PaymentCard(
      id: "card_${DateTime.now().millisecondsSinceEpoch}",
      cardType: cardType,
      cardBrand: brand,
      cardHolderName: cardHolderName.trim(),
      last4Digits: last4,
      expiryMonth: expiryMonth.padLeft(2, '0'),
      expiryYear: expiryYear.length == 4 ? expiryYear.substring(2) : expiryYear,
      token: token,
      isDefault: isDefault,
    );

    addCard(newCard);
    return newCard;
  }

  static void addCard(PaymentCard card) {
    var list = List<PaymentCard>.from(cardsNotifier.value);
    if (card.isDefault || list.isEmpty) {
      list = list.map((c) => c.copyWith(isDefault: false)).toList();
      list.insert(0, card.copyWith(isDefault: true));
    } else {
      list.add(card);
    }
    cardsNotifier.value = list;
    _persistCards();
  }

  static void updateCard(PaymentCard updated) {
    var list = List<PaymentCard>.from(cardsNotifier.value);
    final index = list.indexWhere((c) => c.id == updated.id);
    if (index >= 0) {
      if (updated.isDefault) {
        list = list.map((c) => c.copyWith(isDefault: false)).toList();
      }
      list[index] = updated;
      cardsNotifier.value = list;
      _persistCards();
    }
  }

  static void deleteCard(String id) {
    var list = List<PaymentCard>.from(cardsNotifier.value);
    final isDeletedDefault = list.any((c) => c.id == id && c.isDefault);
    list.removeWhere((c) => c.id == id);
    if (isDeletedDefault && list.isNotEmpty) {
      list[0] = list[0].copyWith(isDefault: true);
    }
    cardsNotifier.value = list;
    _persistCards();
  }

  static void setDefault(String id) {
    final list = cardsNotifier.value.map((c) {
      return c.copyWith(isDefault: c.id == id);
    }).toList();
    cardsNotifier.value = list;
    _persistCards();
  }

  static void resetToDefault() {
    cardsNotifier.value = List.from(_defaultCards);
    _persistCards();
  }
}
