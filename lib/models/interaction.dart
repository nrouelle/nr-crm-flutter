import 'package:cloud_firestore/cloud_firestore.dart';

class Interaction {
  final String? id;
  final String prospectId;
  final String commentaire;
  final DateTime date;
  final DateTime dateCreation;

  Interaction({
    this.id,
    required this.prospectId,
    required this.commentaire,
    required this.date,
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  // Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'prospectId': prospectId,
      'commentaire': commentaire,
      'date': Timestamp.fromDate(date),
      'dateCreation': Timestamp.fromDate(dateCreation),
    };
  }

  // Création depuis Firestore DocumentSnapshot
  factory Interaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Interaction(
      id: doc.id,
      prospectId: data['prospectId'] ?? '',
      commentaire: data['commentaire'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Création depuis Map
  factory Interaction.fromMap(Map<String, dynamic> data, String id) {
    return Interaction(
      id: id,
      prospectId: data['prospectId'] ?? '',
      commentaire: data['commentaire'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Copie avec modifications
  Interaction copyWith({
    String? id,
    String? prospectId,
    String? commentaire,
    DateTime? date,
    DateTime? dateCreation,
  }) {
    return Interaction(
      id: id ?? this.id,
      prospectId: prospectId ?? this.prospectId,
      commentaire: commentaire ?? this.commentaire,
      date: date ?? this.date,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  @override
  String toString() {
    return 'Interaction(id: $id, prospectId: $prospectId, commentaire: $commentaire, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Interaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}