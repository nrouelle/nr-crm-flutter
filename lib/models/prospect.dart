import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/validation_utils.dart';
import '../utils/sanitization_utils.dart';

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

  // Factory avec validation et sanitisation
  factory Prospect.create({
    String? id,
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    String? linkedin,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    // Sanitiser les données d'entrée
    final sanitizedData = SanitizationUtils.sanitizeProspectData(
      nom: nom,
      prenom: prenom,
      email: email,
      telephone: telephone,
      linkedin: linkedin,
    );

    // Valider les données sanitisées
    final nomError = ValidationUtils.validateName(sanitizedData['nom'], 'nom');
    if (nomError != null) {
      throw ArgumentError('Nom invalide: $nomError');
    }

    final prenomError = ValidationUtils.validateName(sanitizedData['prenom'], 'prénom');
    if (prenomError != null) {
      throw ArgumentError('Prénom invalide: $prenomError');
    }

    final emailError = ValidationUtils.validateEmail(sanitizedData['email']);
    if (emailError != null) {
      throw ArgumentError('Email invalide: $emailError');
    }

    final phoneError = ValidationUtils.validatePhone(sanitizedData['telephone']);
    if (phoneError != null) {
      throw ArgumentError('Téléphone invalide: $phoneError');
    }

    if (sanitizedData['linkedin'] != null && sanitizedData['linkedin']!.isNotEmpty) {
      final linkedinError = ValidationUtils.validateLinkedIn(sanitizedData['linkedin']);
      if (linkedinError != null) {
        throw ArgumentError('LinkedIn invalide: $linkedinError');
      }
    }

    // Normaliser les données
    final normalizedNom = ValidationUtils.normalizeName(sanitizedData['nom']!);
    final normalizedPrenom = ValidationUtils.normalizeName(sanitizedData['prenom']!);
    final normalizedEmail = ValidationUtils.normalizeEmail(sanitizedData['email']!);
    final normalizedPhone = ValidationUtils.normalizePhoneNumber(sanitizedData['telephone']!);

    return Prospect(
      id: id,
      nom: normalizedNom,
      prenom: normalizedPrenom,
      email: normalizedEmail,
      telephone: normalizedPhone,
      linkedin: sanitizedData['linkedin'],
      dateCreation: dateCreation,
      dateModification: dateModification,
    );
  }

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

  // Création depuis Firestore DocumentSnapshot avec sanitisation
  factory Prospect.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Sanitiser les données venant de Firestore
    final nom = SanitizationUtils.sanitizeName(data['nom'] ?? '');
    final prenom = SanitizationUtils.sanitizeName(data['prenom'] ?? '');
    final email = SanitizationUtils.sanitizeEmail(data['email'] ?? '');
    final telephone = SanitizationUtils.sanitizePhoneNumber(data['telephone'] ?? '');
    final linkedin = data['linkedin'] != null ? SanitizationUtils.sanitizeUrl(data['linkedin']) : null;

    return Prospect(
      id: doc.id,
      nom: nom,
      prenom: prenom,
      email: email,
      telephone: telephone,
      linkedin: linkedin,
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateModification: (data['dateModification'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Création depuis Map avec sanitisation
  factory Prospect.fromMap(Map<String, dynamic> data, String id) {
    // Sanitiser les données venant de la Map
    final nom = SanitizationUtils.sanitizeName(data['nom'] ?? '');
    final prenom = SanitizationUtils.sanitizeName(data['prenom'] ?? '');
    final email = SanitizationUtils.sanitizeEmail(data['email'] ?? '');
    final telephone = SanitizationUtils.sanitizePhoneNumber(data['telephone'] ?? '');
    final linkedin = data['linkedin'] != null ? SanitizationUtils.sanitizeUrl(data['linkedin']) : null;

    return Prospect(
      id: id,
      nom: nom,
      prenom: prenom,
      email: email,
      telephone: telephone,
      linkedin: linkedin,
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