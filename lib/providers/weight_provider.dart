import 'package:flutter/material.dart';
import '../models/weight.dart';

class WeightProvider with ChangeNotifier {
  final List<Weight> _items = [
    Weight('1', 76.99, DateTime.now().toIso8601String()),
    Weight('2', 79.99, DateTime.now().toIso8601String()),
    Weight('3', 72.99, DateTime.now().toIso8601String()),
    Weight('4', 74.99, DateTime.now().toIso8601String()),
  ];

  List<Weight> get items {
    return [..._items];
  }

  void deletProduct(String id) {}
}
