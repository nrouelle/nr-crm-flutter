import 'package:cloud_firestore/cloud_firestore.dart';

class Prospect {
  final String? id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String? linkedin;
  final DateTime dateCreation;
  final DateTime dateModification;

  Prospect({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    this.linkedin,
    DateTime? dateCreation,
    DateTime? dateModification,
  })  : dateCreation = dateCreation ?? DateTime.now(),
        dateModification = dateModification ?? DateTime.now();

  // Conversion vers Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'linkedin': linkedin,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
    };
  }

  // Création depuis Firestore DocumentSnapshot
  factory Prospect.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Prospect(
      id: doc.id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      linkedin: data['linkedin'],
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateModification: (data['dateModification'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Création depuis Map
  factory Prospect.fromMap(Map<String, dynamic> data, String id) {
    return Prospect(
      id: id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      linkedin: data['linkedin'],
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateModification: (data['dateModification'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Copie avec modifications
  Prospect copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? linkedin,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Prospect(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      linkedin: linkedin ?? this.linkedin,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? DateTime.now(),
    );
  }

  // Nom complet
  String get nomComplet => '$prenom $nom';

  // Initiales pour avatar
  String get initiales => '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}';

  @override
  String toString() {
    return 'Prospect(id: $id, nom: $nom, prenom: $prenom, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Prospect && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}