import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospects_provider.dart';
import '../widgets/prospect_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'add_prospect_page.dart';
import 'prospect_detail_page.dart';

class ProspectsPage extends ConsumerStatefulWidget {
  const ProspectsPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<ProspectsPage> createState() => _ProspectsPageState();
}

class _ProspectsPageState extends ConsumerState<ProspectsPage> {
  @override
  void initState() {
    super.initState();
    // Initialiser les données de test si nécessaire via Riverpod
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(prospectsNotifierProvider.notifier).initialiserDonneesTest();
    });
  }

  // Actions pour les cartes prospects
  void _callProspect(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'appeler $phoneNumber'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _emailProspect(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'ouvrir l\'email pour $email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editProspect(Prospect prospect) {
    // TODO: Naviguer vers la page d'édition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'édition à implémenter'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteProspect(Prospect prospect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le prospect'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${prospect.nomComplet} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(prospectsNotifierProvider.notifier)
                  .supprimerProspect(prospect.id!);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                        ? '${prospect.nomComplet} supprimé avec succès'
                        : 'Erreur lors de la suppression',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liste des Prospects',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF023047),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final prospectsAsync = ref.watch(prospectsStreamProvider);

                  return prospectsAsync.when(
                    data: (prospects) {
                      if (prospects.isEmpty) {
                        return EmptyStateWidget.prospects(
                          onAddProspect: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddProspectPage(),
                              ),
                            );
                          },
                        );
                      }

                      return ListView.builder(
                        itemCount: prospects.length,
                        itemBuilder: (context, index) {
                          final prospect = prospects[index];
                          return ProspectCard(
                            prospect: prospect,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProspectDetailPage(
                                    prospect: prospect,
                                  ),
                                ),
                              );
                            },
                            onCall: () => _callProspect(prospect.telephone),
                            onEmail: () => _emailProspect(prospect.email),
                            onEdit: () => _editProspect(prospect),
                            onDelete: () => _deleteProspect(prospect),
                          );
                        },
                      );
                    },
                    loading: () => LoadingWidget.prospects(),
                    error: (error, stackTrace) {
                      return CustomErrorWidget.prospects(
                        errorMessage: error.toString(),
                        onRetry: () {
                          ref.invalidate(prospectsStreamProvider);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProspectPage(),
            ),
          );
        },
        tooltip: 'Ajouter un prospect',
        child: const Icon(Icons.add),
      ),
    );
  }
}