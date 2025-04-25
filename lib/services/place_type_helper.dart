// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import '../models/place_model.dart';

class PlaceTypeHelper {
  // Place types
  static const String TYPE_EDUCATIONAL = 'educational';
  static const String TYPE_HEALTHCARE = 'healthcare';
  static const String TYPE_RESTAURANT = 'restaurant';
  static const String TYPE_SHOPPING = 'shopping';
  static const String TYPE_HOTEL = 'hotel';
  static const String TYPE_RELIGIOUS = 'religious';
  static const String TYPE_PARK = 'park';
  static const String TYPE_GOVERNMENT = 'government';
  static const String TYPE_OTHER = 'other';

  // Determine place type from PlaceModel
  static String getPlaceType(PlaceModel place) {
    final String name = place.placeName.toLowerCase();
    final Map<String, dynamic>? props = place.properties;

    // Check for educational institutions
    if (_matchesEducational(name, props)) {
      return TYPE_EDUCATIONAL;
    }

    // Check for healthcare facilities
    if (_matchesHealthcare(name, props)) {
      return TYPE_HEALTHCARE;
    }

    // Check for restaurants and cafes
    if (_matchesRestaurant(name, props)) {
      return TYPE_RESTAURANT;
    }

    // Check for shopping places
    if (_matchesShopping(name, props)) {
      return TYPE_SHOPPING;
    }

    // Check for hotels
    if (_matchesHotel(name, props)) {
      return TYPE_HOTEL;
    }

    // Check for religious places
    if (_matchesReligious(name, props)) {
      return TYPE_RELIGIOUS;
    }

    // Check for parks and recreational areas
    if (_matchesPark(name, props)) {
      return TYPE_PARK;
    }

    // Check for government buildings
    if (_matchesGovernment(name, props)) {
      return TYPE_GOVERNMENT;
    }

    // Default to other
    return TYPE_OTHER;
  }

  // Get icon for place type
  static IconData getIconForPlaceType(String placeType) {
    switch (placeType) {
      case TYPE_EDUCATIONAL:
        return Icons.school;
      case TYPE_HEALTHCARE:
        return Icons.local_hospital;
      case TYPE_RESTAURANT:
        return Icons.restaurant;
      case TYPE_SHOPPING:
        return Icons.shopping_bag;
      case TYPE_HOTEL:
        return Icons.hotel;
      case TYPE_RELIGIOUS:
        return Icons.mosque;
      case TYPE_PARK:
        return Icons.park;
      case TYPE_GOVERNMENT:
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }

  // Helper method to check if a place is an educational institution
  static bool _matchesEducational(String name, Map<String, dynamic>? props) {
    // Check name for educational keywords
    final bool nameContainsEducation =
        name.contains('جامعة') ||
        name.contains('كلية') ||
        name.contains('معهد') ||
        name.contains('مدرسة');

    // Check properties if available
    bool propertiesIndicateEducation = false;
    if (props != null) {
      final String category = props['category'] ?? '';
      final String type = props['type'] ?? '';

      propertiesIndicateEducation =
          category.contains('education') ||
          category.contains('college') ||
          category.contains('university') ||
          type.contains('education') ||
          type.contains('college') ||
          type.contains('university');
    }

    return nameContainsEducation || propertiesIndicateEducation;
  }

  // Helper method to check if a place is a healthcare facility
  static bool _matchesHealthcare(String name, Map<String, dynamic>? props) {
    // Check name for healthcare keywords
    final bool nameContainsHealthcare =
        name.contains('مستشفى') ||
        name.contains('عيادة') ||
        name.contains('مركز صحي') ||
        name.contains('مركز طبي');

    // Check properties if available
    bool propertiesIndicateHealthcare = false;
    if (props != null) {
      final String category = props['category'] ?? '';

      propertiesIndicateHealthcare =
          category.contains('hospital') ||
          category.contains('health') ||
          category.contains('clinic') ||
          category.contains('medical');
    }

    return nameContainsHealthcare || propertiesIndicateHealthcare;
  }

  // Helper method to check if a place is a restaurant or cafe
  static bool _matchesRestaurant(String name, Map<String, dynamic>? props) {
    // Check name for restaurant keywords
    final bool nameContainsRestaurant =
        name.contains('مطعم') ||
        name.contains('كافيه') ||
        name.contains('كافية') ||
        name.contains('مقهى');

    // Check properties if available
    bool propertiesIndicateRestaurant = false;
    if (props != null) {
      final String category = props['category'] ?? '';

      propertiesIndicateRestaurant =
          category.contains('restaurant') ||
          category.contains('food') ||
          category.contains('cafe') ||
          category.contains('coffee');
    }

    return nameContainsRestaurant || propertiesIndicateRestaurant;
  }

  // Helper method to check if a place is a shopping place
  static bool _matchesShopping(String name, Map<String, dynamic>? props) {
    // Check name for shopping keywords
    final bool nameContainsShopping =
        name.contains('مول') ||
        name.contains('سوق') ||
        name.contains('متجر') ||
        name.contains('محل');

    // Check properties if available
    bool propertiesIndicateShopping = false;
    if (props != null) {
      final String category = props['category'] ?? '';

      propertiesIndicateShopping =
          category.contains('shop') ||
          category.contains('mall') ||
          category.contains('store') ||
          category.contains('retail');
    }

    return nameContainsShopping || propertiesIndicateShopping;
  }

  // Helper method to check if a place is a hotel
  static bool _matchesHotel(String name, Map<String, dynamic>? props) {
    // Check name for hotel keywords
    final bool nameContainsHotel =
        name.contains('فندق') || name.contains('نزل');

    // Check properties if available
    bool propertiesIndicateHotel = false;
    if (props != null) {
      final String category = props['category'] ?? '';

      propertiesIndicateHotel =
          category.contains('hotel') ||
          category.contains('lodging') ||
          category.contains('hostel');
    }

    return nameContainsHotel || propertiesIndicateHotel;
  }

  // Helper method to check if a place is a religious building
  static bool _matchesReligious(String name, Map<String, dynamic>? props) {
    // Check name for religious keywords
    final bool nameContainsReligious =
        name.contains('مسجد') ||
        name.contains('جامع') ||
        name.contains('كنيسة') ||
        name.contains('معبد');

    // Check properties if available
    bool propertiesIndicateReligious = false;
    if (props != null) {
      final String category = props['category'] ?? '';

      propertiesIndicateReligious =
          category.contains('mosque') ||
          category.contains('church') ||
          category.contains('temple') ||
          category.contains('worship') ||
          category.contains('religious');
    }

    return nameContainsReligious || propertiesIndicateReligious;
  }

  // Helper method to check if a place is a park or recreational area
  static bool _matchesPark(String name, Map<String, dynamic>? props) {
    // Check name for park keywords
    final bool nameContainsPark =
        name.contains('حديقة') ||
        name.contains('منتزه') ||
        name.contains('ملعب');

    // Check properties if available
    bool propertiesIndicatePark = false;
    if (props != null) {
      final String category = props['category'] ?? '';

      propertiesIndicatePark =
          category.contains('park') ||
          category.contains('garden') ||
          category.contains('playground') ||
          category.contains('recreation');
    }

    return nameContainsPark || propertiesIndicatePark;
  }

  // Helper method to check if a place is a government building
  static bool _matchesGovernment(String name, Map<String, dynamic>? props) {
    // Check name for government keywords
    final bool nameContainsGovernment =
        name.contains('وزارة') ||
        name.contains('مجلس') ||
        name.contains('محكمة') ||
        name.contains('بلدية') ||
        name.contains('حكومي');

    // Check properties if available
    bool propertiesIndicateGovernment = false;
    if (props != null) {
      final String category = props['category'] ?? '';

      propertiesIndicateGovernment =
          category.contains('government') ||
          category.contains('municipal') ||
          category.contains('court') ||
          category.contains('ministry') ||
          category.contains('civic');
    }

    return nameContainsGovernment || propertiesIndicateGovernment;
  }
}
