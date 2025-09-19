import '../utils/app_logger.dart';

class SanitizationUtils {
  // Caractères potentiellement dangereux à filtrer
  static final _dangerousChars = RegExp(r'[<>"&\x00-\x1f\x7f-\x9f]');
  static final _sqlInjectionPatterns = RegExp(
    r'(\b(ALTER|CREATE|DELETE|DROP|EXEC(UTE)?|INSERT|MERGE|SELECT|UPDATE|UNION|USE)\b)|(\-\-|\/\*|\*\/|;)',
    caseSensitive: false,
  );
  static final _scriptPatterns = RegExp(
    r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
    caseSensitive: false,
  );

  // Sanitisation générale de texte
  static String sanitizeText(String? input) {
    if (input == null || input.isEmpty) return '';

    String sanitized = input.trim();

    // Supprimer les caractères de contrôle et dangereux
    sanitized = sanitized.replaceAll(_dangerousChars, '');

    // Supprimer les balises HTML/script
    sanitized = sanitized.replaceAll(_scriptPatterns, '');
    sanitized = _removeHtmlTags(sanitized);

    // Limiter la longueur
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
      AppLogger.warning('Texte tronqué lors de la sanitisation: longueur dépassée');
    }

    // Supprimer les espaces multiples
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    return sanitized.trim();
  }

  // Sanitisation spécifique pour les noms
  static String sanitizeName(String? input) {
    if (input == null || input.isEmpty) return '';

    String sanitized = input.trim();

    // Garder uniquement les lettres, espaces, tirets et apostrophes
    sanitized = sanitized.replaceAll(RegExp(r"[^a-zA-ZÀ-ÿ\s\-'\.]"), '');

    // Supprimer les espaces multiples
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Limiter la longueur
    if (sanitized.length > 50) {
      sanitized = sanitized.substring(0, 50);
    }

    return sanitized.trim();
  }

  // Sanitisation pour les emails
  static String sanitizeEmail(String? input) {
    if (input == null || input.isEmpty) return '';

    String sanitized = input.trim().toLowerCase();

    // Garder uniquement les caractères valides pour un email
    sanitized = sanitized.replaceAll(RegExp(r'[^a-z0-9@._\-]'), '');

    // Supprimer les points multiples
    sanitized = sanitized.replaceAll(RegExp(r'\.{2,}'), '.');

    // Limiter la longueur
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }

    return sanitized;
  }

  // Sanitisation pour les numéros de téléphone
  static String sanitizePhoneNumber(String? input) {
    if (input == null || input.isEmpty) return '';

    String sanitized = input.trim();

    // Garder uniquement les chiffres, espaces, tirets, parenthèses et le signe +
    sanitized = sanitized.replaceAll(RegExp(r'[^\d\s\-\.\(\)\+]'), '');

    // Limiter la longueur
    if (sanitized.length > 20) {
      sanitized = sanitized.substring(0, 20);
    }

    return sanitized.trim();
  }

  // Sanitisation pour les URLs
  static String sanitizeUrl(String? input) {
    if (input == null || input.isEmpty) return '';

    String sanitized = input.trim().toLowerCase();

    // Vérifier que l'URL commence par http ou https
    if (!sanitized.startsWith('http://') && !sanitized.startsWith('https://')) {
      if (sanitized.startsWith('www.') || sanitized.contains('.')) {
        sanitized = 'https://$sanitized';
      } else {
        return ''; // URL invalide
      }
    }

    // Supprimer les caractères dangereux
    sanitized = sanitized.replaceAll(RegExp(r'[<>"`]'), '');

    // Limiter la longueur
    if (sanitized.length > 200) {
      sanitized = sanitized.substring(0, 200);
    }

    return sanitized;
  }

  // Sanitisation pour les mots de passe (sans modification mais avec vérification)
  static String sanitizePassword(String? input) {
    if (input == null || input.isEmpty) return '';

    String sanitized = input;

    // Supprimer uniquement les caractères de contrôle
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1f\x7f-\x9f]'), '');

    // Limiter la longueur
    if (sanitized.length > 128) {
      sanitized = sanitized.substring(0, 128);
    }

    return sanitized;
  }

  // Vérification de sécurité pour détecter les tentatives d'injection
  static bool containsSuspiciousContent(String input) {
    if (input.isEmpty) return false;

    // Vérifier les patterns SQL injection
    if (_sqlInjectionPatterns.hasMatch(input)) {
      AppLogger.warning('Tentative d\'injection SQL détectée: $input');
      return true;
    }

    // Vérifier les scripts
    if (_scriptPatterns.hasMatch(input)) {
      AppLogger.warning('Tentative d\'injection de script détectée: $input');
      return true;
    }

    // Vérifier les caractères de contrôle excessifs
    final controlChars = RegExp(r'[\x00-\x1f\x7f-\x9f]').allMatches(input);
    if (controlChars.length > 2) {
      AppLogger.warning('Nombre excessif de caractères de contrôle détecté');
      return true;
    }

    return false;
  }

  // Sanitisation complète d'un prospect
  static Map<String, String> sanitizeProspectData({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    String? linkedin,
  }) {
    final sanitizedData = <String, String>{};

    // Vérifier le contenu suspect avant sanitisation
    final inputs = [nom, prenom, email, telephone, linkedin ?? ''];
    for (final input in inputs) {
      if (containsSuspiciousContent(input)) {
        throw Exception('Contenu suspect détecté dans les données du prospect');
      }
    }

    // Sanitiser chaque champ
    sanitizedData['nom'] = sanitizeName(nom);
    sanitizedData['prenom'] = sanitizeName(prenom);
    sanitizedData['email'] = sanitizeEmail(email);
    sanitizedData['telephone'] = sanitizePhoneNumber(telephone);

    if (linkedin != null && linkedin.isNotEmpty) {
      sanitizedData['linkedin'] = sanitizeUrl(linkedin);
    }

    // Vérifier que les champs obligatoires ne sont pas vides après sanitisation
    if (sanitizedData['nom']!.isEmpty ||
        sanitizedData['prenom']!.isEmpty ||
        sanitizedData['email']!.isEmpty ||
        sanitizedData['telephone']!.isEmpty) {
      throw Exception('Des champs obligatoires sont vides après sanitisation');
    }

    AppLogger.debug('Données prospect sanitisées avec succès');
    return sanitizedData;
  }

  // Fonction utilitaire pour supprimer les balises HTML
  static String _removeHtmlTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Échapper les caractères spéciaux pour l'affichage sécurisé
  static String escapeForDisplay(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  // Nettoyer les caractères invisibles et espaces non-breaking
  static String cleanInvisibleChars(String input) {
    return input
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '') // Zero-width chars
        .replaceAll(RegExp(r'[\u00A0\u2007\u202F]'), ' ') // Non-breaking spaces
        .replaceAll(RegExp(r'\s+'), ' ') // Multiple spaces
        .trim();
  }
}