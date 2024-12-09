import 'package:flutter/material.dart';

enum TransportationType {
  public,
  car;

  String get displayName {
    switch (this) {
      case TransportationType.public:
        return '대중교통';
      case TransportationType.car:
        return '자동차';
    }
  }

  IconData get icon {
    switch (this) {
      case TransportationType.public:
        return Icons.directions_bus;
      case TransportationType.car:
        return Icons.directions_car;
    }
  }
}