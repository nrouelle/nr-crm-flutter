import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;
  final Color? titleColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
    this.titleColor,
  });

  // Factory pour l'état vide des prospects
  factory EmptyStateWidget.prospects({
    VoidCallback? onAddProspect,
  }) {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: 'Aucun prospect trouvé',
      subtitle: 'Ajoutez votre premier prospect pour commencer',
      buttonText: 'Ajouter un prospect',
      onButtonPressed: onAddProspect,
      iconColor: const Color(0xFF219ebc),
      titleColor: const Color(0xFF023047),
    );
  }

  // Factory pour l'état vide de recherche
  factory EmptyStateWidget.searchResults({
    required String searchTerm,
    VoidCallback? onClearSearch,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Aucun résultat',
      subtitle: 'Aucun prospect trouvé pour "$searchTerm"',
      buttonText: 'Effacer la recherche',
      onButtonPressed: onClearSearch,
      iconColor: Colors.grey,
      titleColor: Colors.grey,
    );
  }

  // Factory pour l'état vide des interactions
  factory EmptyStateWidget.interactions({
    VoidCallback? onAddInteraction,
  }) {
    return EmptyStateWidget(
      icon: Icons.chat_bubble_outline,
      title: 'Aucune interaction',
      subtitle: 'Ajoutez votre première interaction avec ce prospect',
      buttonText: 'Ajouter une interaction',
      onButtonPressed: onAddInteraction,
      iconColor: const Color(0xFFffb703),
      titleColor: const Color(0xFF023047),
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
            // Icône
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor ?? Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Sous-titre
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            // Bouton d'action (optionnel)
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.add),
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