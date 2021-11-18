import 'package:cloud_firestore/cloud_firestore.dart';

class Weight {
  String id;
  double weight;
  Timestamp dateCreated;
  Weight(this.id, this.weight, this.dateCreated);
}
