import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AddressType { home, office, other }

class UserAddress {
  final String id;
  final AddressType type;
  final String? customLabel;
  final String fullName;
  final String phoneNumber;
  final String houseNumber;
  final String streetArea;
  final String city;
  final String state;
  final String zipCode;
  final String? landmark;
  final bool isDefault;

  const UserAddress({
    required this.id,
    required this.type,
    this.customLabel,
    required this.fullName,
    required this.phoneNumber,
    required this.houseNumber,
    required this.streetArea,
    required this.city,
    required this.state,
    required this.zipCode,
    this.landmark,
    this.isDefault = false,
  });

  String get typeDisplay {
    switch (type) {
      case AddressType.home:
        return "Home";
      case AddressType.office:
        return "Office";
      case AddressType.other:
        return (customLabel != null && customLabel!.trim().isNotEmpty)
            ? customLabel!.trim()
            : "Other";
    }
  }

  String get formattedShortAddress {
    return "$houseNumber, $streetArea, $city";
  }

  String get formattedFullAddress {
    final parts = <String>[
      houseNumber,
      streetArea,
      if (landmark != null && landmark!.trim().isNotEmpty)
        "Near ${landmark!.trim()}",
      "$city, $state - $zipCode",
    ];
    return parts.join(", ");
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'customLabel': customLabel,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'houseNumber': houseNumber,
      'streetArea': streetArea,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'landmark': landmark,
      'isDefault': isDefault,
    };
  }

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    AddressType addressType = AddressType.home;
    if (json['type'] == 'office') {
      addressType = AddressType.office;
    } else if (json['type'] == 'other') {
      addressType = AddressType.other;
    }

    return UserAddress(
      id: json['id'] as String,
      type: addressType,
      customLabel: json['customLabel'] as String?,
      fullName: json['fullName'] as String? ?? 'Alex Morgan',
      phoneNumber: json['phoneNumber'] as String? ?? '+1 800-555-0199',
      houseNumber: json['houseNumber'] as String? ?? '',
      streetArea: json['streetArea'] as String? ?? '',
      city: json['city'] as String? ?? 'New Delhi',
      state: json['state'] as String? ?? 'Delhi',
      zipCode: json['zipCode'] as String? ?? '110016',
      landmark: json['landmark'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  UserAddress copyWith({
    String? id,
    AddressType? type,
    String? customLabel,
    String? fullName,
    String? phoneNumber,
    String? houseNumber,
    String? streetArea,
    String? city,
    String? state,
    String? zipCode,
    String? landmark,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id ?? this.id,
      type: type ?? this.type,
      customLabel: customLabel ?? this.customLabel,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      houseNumber: houseNumber ?? this.houseNumber,
      streetArea: streetArea ?? this.streetArea,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      landmark: landmark ?? this.landmark,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class AddressService {
  static const String _storageKey = "plenora_saved_addresses_v1";

  static final List<UserAddress> _defaultAddresses = [
    const UserAddress(
      id: "addr_1",
      type: AddressType.home,
      fullName: "Alex Morgan",
      phoneNumber: "+1 800-555-0199",
      houseNumber: "124 Green Park",
      streetArea: "Block B",
      city: "New Delhi",
      state: "Delhi",
      zipCode: "110016",
      landmark: "Near Metro Gate 2",
      isDefault: true,
    ),
    const UserAddress(
      id: "addr_2",
      type: AddressType.office,
      fullName: "Alex Morgan",
      phoneNumber: "+1 800-555-0199",
      houseNumber: "Tower 4",
      streetArea: "Cyber City, Sector 24",
      city: "Gurugram",
      state: "Haryana",
      zipCode: "122002",
      landmark: "Opposite DLF Cyber Hub",
      isDefault: false,
    ),
  ];

  static final ValueNotifier<List<UserAddress>> addressesNotifier =
      ValueNotifier<List<UserAddress>>(List.from(_defaultAddresses));

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
            .map((item) => UserAddress.fromJson(item as Map<String, dynamic>))
            .toList();
        if (loaded.isNotEmpty) {
          addressesNotifier.value = loaded;
          return;
        }
      }
    } catch (_) {}
  }

  static Future<void> _persistAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = addressesNotifier.value.map((a) => a.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  static UserAddress? get defaultAddress {
    final list = addressesNotifier.value;
    if (list.isEmpty) return null;
    return list.firstWhere(
      (a) => a.isDefault,
      orElse: () => list.first,
    );
  }

  static void addAddress(UserAddress address) {
    var list = List<UserAddress>.from(addressesNotifier.value);
    if (address.isDefault || list.isEmpty) {
      list = list.map((a) => a.copyWith(isDefault: false)).toList();
      list.insert(0, address.copyWith(isDefault: true));
    } else {
      list.add(address);
    }
    addressesNotifier.value = list;
    _persistAddresses();
  }

  static void updateAddress(UserAddress updated) {
    var list = List<UserAddress>.from(addressesNotifier.value);
    final index = list.indexWhere((a) => a.id == updated.id);
    if (index >= 0) {
      if (updated.isDefault) {
        list = list.map((a) => a.copyWith(isDefault: false)).toList();
      }
      list[index] = updated;
      addressesNotifier.value = list;
      _persistAddresses();
    }
  }

  static void deleteAddress(String id) {
    var list = List<UserAddress>.from(addressesNotifier.value);
    final isDeletedDefault = list.any((a) => a.id == id && a.isDefault);
    list.removeWhere((a) => a.id == id);
    if (isDeletedDefault && list.isNotEmpty) {
      list[0] = list[0].copyWith(isDefault: true);
    }
    addressesNotifier.value = list;
    _persistAddresses();
  }

  static void setDefault(String id) {
    final list = addressesNotifier.value.map((a) {
      return a.copyWith(isDefault: a.id == id);
    }).toList();
    addressesNotifier.value = list;
    _persistAddresses();
  }

  static void resetToDefault() {
    addressesNotifier.value = List.from(_defaultAddresses);
    _persistAddresses();
  }
}
