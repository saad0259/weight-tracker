import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/weight.dart';
import '../constants/firebase_constants.dart' as FB;

class WeightProvider with ChangeNotifier {
  final List<Weight> _items = [];

  List<Weight> get items {
    return [..._items];
  }

  Future<void> fetchAndSetData() async {
    if (FB.firebaseAuth.currentUser?.uid == null) {
      return;
    }

    _items.clear();

    await FB.firebaseFirestore
        .collection('weightData')
        .orderBy('createdAt', descending: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['userId'] == FB.firebaseAuth.currentUser!.uid) {
          _items.add(Weight(doc.id, doc['weight'], doc['createdAt']));
        }
      }
    });

    notifyListeners();
  }

  String findById(String id) {
    final item = _items.firstWhere((element) => element.id == id);
    return item.weight.toString();
  }

  Future<void> addWeightEntry(String inputWeight) async {
    double weight = double.parse(inputWeight);

    if (FB.firebaseAuth.currentUser?.uid == null) {
      return;
    }
    try {
      final weightEntry =
          await FB.firebaseFirestore.collection('weightData').add({
        'userId': FB.firebaseAuth.currentUser!.uid,
        'weight': weight,
        'createdAt': Timestamp.now(),
      }); // add in firestore

      final newEntry = Weight(weightEntry.id, weight, Timestamp.now());
      _items.insert(0, newEntry); // add local

    } catch (e) {
      print('could not add because: $e');
    }
    notifyListeners();
  }

  Future<void> updateWeight(String id, String inputWeight) async {
    double weight = double.parse(inputWeight);
    final entryIndex = _items.indexWhere((element) => element.id == id);
    if (entryIndex >= 0) {
      try {
        await FB.firebaseFirestore
            .collection('weightData')
            .doc(id)
            .update({'weight': weight});

        _items[entryIndex].weight = weight;
      } catch (e) {
        print('could not update because: $e');
      }
    } else {
      print('Element not found');
    }
    notifyListeners();
  }

  Future<void> deletWeight(String id) async {
    final _existingIndex = _items.indexWhere((element) => element.id == id);

    try {
      await FB.firebaseFirestore
          .collection('weightData')
          .doc(id)
          .delete(); // remove firebase
      _items.removeAt(_existingIndex); // remove local
    } catch (e) {
      print('delete failed because: $e');
    }

    notifyListeners();
  }

  void clearList() {
    _items.clear();
    notifyListeners();
  }
}
