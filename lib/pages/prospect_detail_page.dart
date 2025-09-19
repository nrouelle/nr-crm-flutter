import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prospect.dart';
import '../models/interaction.dart';
import '../services/interaction_service.dart';
import 'add_interaction_page.dart';

class ProspectDetailPage extends StatefulWidget {
  final Prospect prospect;

  const ProspectDetailPage({super.key, required this.prospect});

  @override
  State<ProspectDetailPage> createState() => _ProspectDetailPageState();
}

class _ProspectDetailPageState extends State<ProspectDetailPage> {
  final InteractionService _interactionService = InteractionService();

  void _copyToClipboard(BuildContext context, String text, String type) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type copié dans le presse-papiers'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prospect.nomComplet),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => AddInteractionPage(
                    prospectId: widget.prospect.id!,
                    prospectNom: widget.prospect.nomComplet,
                  ),
                ),
              );
              if (result == true && mounted) {
                setState(() {});
              }
            },
            tooltip: 'Ajouter une interaction',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité de modification à implémenter'),
                ),
              );
            },
            tooltip: 'Modifier',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF023047),
                    child: Text(
                      '${widget.prospect.prenom[0]}${widget.prospect.nom[0]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.prospect.nomComplet,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Informations de contact
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations de contact',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF023047),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildContactItem(
                      context,
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: widget.prospect.email,
                      onTap: () => _copyToClipboard(context, widget.prospect.email, 'Email'),
                    ),
                    const Divider(),

                    // Téléphone
                    _buildContactItem(
                      context,
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: widget.prospect.telephone,
                      onTap: () => _copyToClipboard(context, widget.prospect.telephone, 'Téléphone'),
                    ),

                    if (widget.prospect.linkedin != null && widget.prospect.linkedin!.isNotEmpty) ...[
                      const Divider(),
                      // LinkedIn
                      _buildContactItem(
                        context,
                        icon: Icons.link_outlined,
                        label: 'LinkedIn',
                        value: widget.prospect.linkedin!,
                        onTap: () => _copyToClipboard(context, widget.prospect.linkedin!, 'Lien LinkedIn'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions rapides
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions rapides',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF023047),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: Icons.phone,
                            label: 'Appeler',
                            color: Colors.green,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Appel vers ${widget.prospect.nomComplet}'),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            icon: Icons.email,
                            label: 'Email',
                            color: Colors.blue,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Email à ${widget.prospect.nomComplet}'),
                                ),
                              );
                            },
                          ),
                        ),
                        if (widget.prospect.linkedin != null && widget.prospect.linkedin!.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              context,
                              icon: Icons.link,
                              label: 'LinkedIn',
                              color: Colors.indigo,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ouverture de LinkedIn...'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Interactions
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Interactions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF023047),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final result = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (context) => AddInteractionPage(
                                  prospectId: widget.prospect.id!,
                                  prospectNom: widget.prospect.nomComplet,
                                ),
                              ),
                            );
                            if (result == true && mounted) {
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<Interaction>>(
                      stream: _interactionService.obtenirInteractionsProspect(widget.prospect.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Text(
                              'Erreur lors du chargement des interactions: ${snapshot.error}',
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          );
                        }

                        final interactions = snapshot.data ?? [];

                        if (interactions.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Aucune interaction pour le moment',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ajoutez une interaction pour commencer le suivi',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: interactions.map((interaction) => _buildInteractionItem(interaction)).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF023047), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.copy, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionItem(Interaction interaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec date
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${interaction.date.day.toString().padLeft(2, '0')}/${interaction.date.month.toString().padLeft(2, '0')}/${interaction.date.year} à ${interaction.date.hour.toString().padLeft(2, '0')}:${interaction.date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Supprimer l\'interaction'),
                        content: const Text('Êtes-vous sûr de vouloir supprimer cette interaction ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      try {
                        await _interactionService.supprimerInteraction(interaction.id!);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Interaction supprimée'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Commentaire
          Text(
            interaction.commentaire,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}