import 'package:form_validator/form_validator.dart';

class ValidationUtils {
  // Validation pour les emails
  static String? validateEmail(String? value) {
    return ValidationBuilder()
        .required('L\'email est requis')
        .email('Format d\'email invalide')
        .maxLength(100, 'L\'email ne peut pas dépasser 100 caractères')
        .build()(value);
  }

  // Validation pour les noms (nom et prénom)
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Le $fieldName est requis';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'Le $fieldName doit contenir au moins 2 caractères';
    }

    if (trimmedValue.length > 50) {
      return 'Le $fieldName ne peut pas dépasser 50 caractères';
    }

    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s\-'\.]+$").hasMatch(trimmedValue)) {
      return 'Le $fieldName ne peut contenir que des lettres, espaces, tirets et apostrophes';
    }

    return null;
  }

  // Validation pour les numéros de téléphone français
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }

    // Nettoyer le numéro (enlever espaces, tirets, etc.)
    final cleanedPhone = value.replaceAll(RegExp(r'[\s\-\.\(\)]+'), '');

    // Vérifier les formats français
    final phoneRegex = RegExp(r'^(?:\+33|0)[1-9](?:[0-9]{8})$');

    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'Format de téléphone invalide (ex: 06 12 34 56 78 ou +33 6 12 34 56 78)';
    }

    return null;
  }

  // Validation pour les URLs LinkedIn
  static String? validateLinkedIn(String? value) {
    if (value == null || value.isEmpty) {
      return null; // LinkedIn est optionnel
    }

    final trimmedValue = value.trim();

    // Vérification basique d'URL
    final uri = Uri.tryParse(trimmedValue);
    if (uri == null || !uri.hasAbsolutePath) {
      return 'Format d\'URL invalide';
    }

    // Vérification spécifique LinkedIn
    if (!RegExp(r'^https?://(?:www\.)?linkedin\.com/in/[a-zA-Z0-9\-]+/?$').hasMatch(trimmedValue)) {
      return 'L\'URL doit être un profil LinkedIn valide';
    }

    return null;
  }

  // Validation générale pour les champs texte
  static String? validateText(String? value, String fieldName, {
    int minLength = 1,
    int maxLength = 255,
    bool required = true,
  }) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Le $fieldName est requis';
    }

    if (value != null && value.isNotEmpty) {
      final trimmedValue = value.trim();

      if (trimmedValue.length < minLength) {
        return 'Le $fieldName doit contenir au moins $minLength caractère(s)';
      }

      if (trimmedValue.length > maxLength) {
        return 'Le $fieldName ne peut pas dépasser $maxLength caractères';
      }
    }

    return null;
  }

  // Vérification de la force d'un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une minuscule, une majuscule et un chiffre';
    }

    return null;
  }

  // Validation pour la confirmation de mot de passe
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  // Vérification si un email est dans un format professionnel
  static bool isProfessionalEmail(String email) {
    final personalDomains = [
      'gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com',
      'free.fr', 'orange.fr', 'sfr.fr', 'wanadoo.fr', 'laposte.net'
    ];

    final domain = email.split('@').last.toLowerCase();
    return !personalDomains.contains(domain);
  }

  // Vérification si un numéro de téléphone est un mobile français
  static bool isFrenchMobile(String phone) {
    final cleanedPhone = phone.replaceAll(RegExp(r'[\s\-\.\(\)]+'), '');
    return RegExp(r'^(?:\+33|0)[67](?:[0-9]{8})$').hasMatch(cleanedPhone);
  }

  // Normalisation d'un nom (première lettre en majuscule)
  static String normalizeName(String name) {
    return name
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .where((word) => word.isNotEmpty)
        .join(' ');
  }

  // Normalisation d'un email (en minuscules)
  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  // Normalisation d'un numéro de téléphone français
  static String normalizePhoneNumber(String phone) {
    // Enlever tous les caractères non numériques sauf le +
    String cleaned = phone.replaceAll(RegExp(r'[^\d\+]'), '');

    // Si le numéro commence par +33, le convertir au format 0X
    if (cleaned.startsWith('+33')) {
      cleaned = '0${cleaned.substring(3)}';
    }

    // Formater en XX XX XX XX XX
    if (cleaned.length == 10 && cleaned.startsWith('0')) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
    }

    return phone; // Retourner le format original si pas de correspondance
  }
}