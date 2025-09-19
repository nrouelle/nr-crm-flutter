import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prospect.dart';
import '../providers/auth_provider.dart';
import '../providers/prospects_provider.dart';
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
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucun prospect trouvé',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Ajoutez votre premier prospect',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: prospects.length,
                        itemBuilder: (context, index) {
                          final prospect = prospects[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF219ebc),
                                child: Text(
                                  prospect.initiales,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                prospect.nomComplet,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prospect.email),
                                  const SizedBox(height: 4),
                                  Text(
                                    prospect.telephone,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.arrow_forward_ios),
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
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur lors du chargement',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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