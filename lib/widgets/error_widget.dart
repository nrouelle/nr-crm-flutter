import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onRetry;
  final Color? iconColor;
  final bool showDetails;
  final String? details;

  const CustomErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.buttonText,
    this.onRetry,
    this.iconColor,
    this.showDetails = false,
    this.details,
  });

  // Factory pour les erreurs de chargement des prospects
  factory CustomErrorWidget.prospects({
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Erreur de chargement',
      message: errorMessage ?? 'Impossible de charger les prospects',
      icon: Icons.error_outline,
      iconColor: Colors.red,
      buttonText: 'Réessayer',
      onRetry: onRetry,
    );
  }

  // Factory pour les erreurs de connexion
  factory CustomErrorWidget.connection({
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Problème de connexion',
      message: 'Vérifiez votre connexion internet et réessayez',
      icon: Icons.wifi_off,
      iconColor: Colors.orange,
      buttonText: 'Réessayer',
      onRetry: onRetry,
    );
  }

  // Factory pour les erreurs d'authentification
  factory CustomErrorWidget.auth({
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Erreur d\'authentification',
      message: errorMessage ?? 'Impossible de vous connecter',
      icon: Icons.lock_outline,
      iconColor: Colors.red,
      buttonText: 'Réessayer',
      onRetry: onRetry,
    );
  }

  // Factory pour les erreurs génériques
  factory CustomErrorWidget.generic({
    required String errorMessage,
    VoidCallback? onRetry,
    bool showDetails = false,
  }) {
    return CustomErrorWidget(
      title: 'Une erreur s\'est produite',
      message: 'Nous rencontrons un problème technique',
      icon: Icons.warning_outlined,
      iconColor: Colors.orange,
      buttonText: 'Réessayer',
      onRetry: onRetry,
      showDetails: showDetails,
      details: errorMessage,
    );
  }

  // Factory pour les erreurs de permission
  factory CustomErrorWidget.permission({
    required String action,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Permission refusée',
      message: 'Vous n\'avez pas les droits pour $action',
      icon: Icons.block,
      iconColor: Colors.red,
      buttonText: 'Retour',
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône d'erreur
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.red).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: iconColor ?? Colors.red,
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF023047),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Détails de l'erreur (optionnel)
            if (showDetails && details != null) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text(
                  'Détails techniques',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        details!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Bouton d'action
            if (buttonText != null && onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(buttonText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF219ebc),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher une erreur inline (dans une liste par exemple)
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red[800],
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ],
      ),
    );
  }
}